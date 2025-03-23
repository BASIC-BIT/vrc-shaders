Shader "Custom/RainbowHeartburstIris" {
    Properties {
        // Animation and effect controls
        _HeartPulseIntensity ("Heart Pulse Intensity", Range(0,1)) = 0.5
        _RingRotationSpeed ("Ring Rotation Speed", Range(0,1)) = 0.3
        _IrisSparkleIntensity ("Iris Sparkle Intensity", Range(0,1)) = 0.5
        _InfiniteDepthStrength ("Infinite Depth Strength", Range(0,1)) = 0.7
        _InfiniteBlurStrength ("Infinite Blur Strength", Range(0,1)) = 0.5
        _SunburstLayerCount ("Sunburst Layer Count", Range(1,5)) = 3
        _SunburstRotationSpeed ("Sunburst Rotation Speed", Range(0,1)) = 0.2
        _FlareIntensityThreshold ("Flare Intensity Threshold", Range(0,1)) = 0.3
        _EnvironmentLightingAmount ("Environment Lighting Amount", Range(0,1)) = 0.2
        
        // Core textures and colors
        _HeartPupilColor ("Heart Pupil Color", Color) = (0.1,0.02,0.05,1)
        _RainbowGradientTex ("Rainbow Gradient", 2D) = "white" {}
        _NoiseTexture ("Noise Texture", 2D) = "black" {}
        
        // AudioLink texture (automatically populated by AudioLink system)
        _AudioLink ("AudioLink Texture", 2D) = "black" {}
    }
    
    SubShader {
        Tags {"Queue"="Transparent+1" "RenderType"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Back
        
        // Main pass
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            
            // Properties
            uniform float _HeartPulseIntensity;
            uniform float _RingRotationSpeed;
            uniform float _IrisSparkleIntensity;
            uniform float _InfiniteDepthStrength;
            uniform float _InfiniteBlurStrength;
            uniform float _SunburstLayerCount;
            uniform float _SunburstRotationSpeed;
            uniform float _FlareIntensityThreshold;
            uniform float _EnvironmentLightingAmount;
            uniform float4 _HeartPupilColor;
            uniform sampler2D _RainbowGradientTex;
            uniform sampler2D _NoiseTexture;
            uniform sampler2D _AudioLink;
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            
            // Helper function to rotate UV coordinates
            float2 RotateUV(float2 uv, float angle) {
                // Rotation matrix
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotMatrix = float2x2(c, -s, s, c);
                return mul(rotMatrix, uv);
            }
            
            // SDF heart function
            float heartSDF(float2 uv, float size) {
                uv = (uv - 0.5) * 2.0; // Center and scale
                float2 q = float2(abs(uv.x), uv.y);
                float d = length(q - float2(0.25, -0.3)) - 0.5;
                return d * (1.0/size); // Negative inside heart, positive outside
            }
            
            // Simple multi-tap blur function
            float4 SampleWithBlur(sampler2D tex, float2 uv, float blurAmount) {
                float4 color = float4(0,0,0,0);
                
                // Early out for no blur
                if (blurAmount < 0.001) {
                    return tex2D(tex, uv);
                }
                
                // 5 tap blur - center, top, bottom, left, right
                color += tex2D(tex, uv) * 0.5;
                color += tex2D(tex, uv + float2(blurAmount, 0)) * 0.125;
                color += tex2D(tex, uv - float2(blurAmount, 0)) * 0.125;
                color += tex2D(tex, uv + float2(0, blurAmount)) * 0.125;
                color += tex2D(tex, uv - float2(0, blurAmount)) * 0.125;
                
                return color;
            }
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Calculate view direction for parallax effects
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = worldPos;
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.viewDir = worldViewDir;
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                // ============= AudioLink Integration =============
                float audioLinkAvailable = AudioLinkIsAvailable();
                float bass = 0;
                float lowMid = 0;
                float highMid = 0;
                float treble = 0;
                
                if (audioLinkAvailable) {
                    // Get filtered audio data to avoid jitter
                    float4 audioData = AudioLinkData(ALPASS_FILTEREDAUDIOLINK);
                    bass = audioData.r;
                    lowMid = audioData.g;
                    highMid = audioData.b;
                    treble = audioData.a;
                } else {
                    // Fallback behavior when AudioLink isn't present
                    bass = 0.5 + sin(_Time.y) * 0.1; // Simple animation fallback
                    lowMid = 0.5 + sin(_Time.y * 1.5) * 0.1;
                    highMid = 0.5 + sin(_Time.y * 2.0) * 0.1;
                    treble = 0.5 + sin(_Time.y * 2.5) * 0.1;
                }
                
                // ============= Heart-shaped Pupil =============
                float pulseSize = 1.0 + _HeartPulseIntensity * bass * 0.2;
                float heartDistance = heartSDF(i.uv, pulseSize);
                float heartMask = smoothstep(0.01, -0.01, heartDistance);
                
                // ============= Rainbow Iris Rings =============
                float2 centeredUV = i.uv - 0.5;
                float dist = length(centeredUV);
                float ringCount = 8.0;
                float ringIndex = frac(dist * ringCount);
                
                // Rotation over time
                float angle = atan2(centeredUV.y, centeredUV.x);
                float rotationSpeed = _Time.y * _RingRotationSpeed;
                float rotatedAngle = angle + rotationSpeed;
                
                // Create a UV that rotates around the center
                float2 rotatedUV = RotateUV(centeredUV, rotationSpeed) + 0.5;
                
                // Sample rainbow gradient based on distance from center
                float2 rainbowUV = float2(ringIndex, 0.5);
                fixed4 rainbowColor = tex2D(_RainbowGradientTex, rainbowUV);
                
                // Audio-reactive sparkle
                float sparkle = tex2D(_NoiseTexture, i.uv * 5.0 + _Time.y).r;
                float sparkleIntensity = _IrisSparkleIntensity * highMid;
                rainbowColor += sparkle * sparkleIntensity;
                
                // ============= Infinite Mirror Depth Effect =============
                float4 mirrorColor = float4(0,0,0,0);
                float totalWeight = 0;
                
                // Loop through multiple depth layers
                for (int layerIdx = 0; layerIdx < 5; layerIdx++) {
                    float depth = 1.0 - (layerIdx / 5.0) * _InfiniteDepthStrength;
                    float2 scaledUV = (i.uv - 0.5) * depth + 0.5;
                    
                    // Heart mask for this layer
                    float layerHeartDist = heartSDF(scaledUV, pulseSize);
                    float layerMask = smoothstep(0.01, -0.01, layerHeartDist);
                    
                    // Calculate blur based on depth
                    float blurAmount = layerIdx * _InfiniteBlurStrength * 0.05;
                    
                    // Use rings for the color but apply progressive blur
                    float layerDist = length(scaledUV - 0.5);
                    float layerRingIndex = frac(layerDist * ringCount);
                    float2 layerRainbowUV = float2(layerRingIndex, 0.5);
                    float4 layerColor = SampleWithBlur(_RainbowGradientTex, layerRainbowUV, blurAmount);
                    
                    // Accumulate with depth-based weight
                    float weight = exp(-layerIdx * 0.5);
                    mirrorColor += layerColor * layerMask * weight;
                    totalWeight += weight * layerMask;
                }
                
                // Normalize accumulated color
                mirrorColor = totalWeight > 0 ? mirrorColor / totalWeight : mirrorColor;
                
                // ============= Animated Parallax Sunburst Streaks =============
                float4 sunburstColor = float4(0,0,0,0);
                
                // Get integer count for sunburst layers
                int sunburstCount = max(1, min(5, (int)_SunburstLayerCount));
                
                // Loop through sunburst layers
                for (int j = 0; j < sunburstCount; j++) {
                    // Different rotation speed for each layer
                    float layerRotation = _Time.y * _SunburstRotationSpeed * (j % 2 == 0 ? 1 : -1);
                    
                    // Parallax offset based on view direction
                    float parallaxAmount = 0.02 * (j+1) / sunburstCount;
                    float2 parallaxOffset = i.viewDir.xy * parallaxAmount;
                    float2 sunburstUV = i.uv + parallaxOffset;
                    
                    // Rotate UVs
                    float2 rotatedUV = RotateUV(sunburstUV - 0.5, layerRotation) + 0.5;
                    
                    // Create radial streaks
                    float streakAngle = atan2(rotatedUV.y-0.5, rotatedUV.x-0.5);
                    float streakMask = (sin(streakAngle * 20.0) * 0.5 + 0.5);
                    streakMask = pow(streakMask, 5.0) * exp(-length(rotatedUV - 0.5) * 5.0);
                    
                    // Add to final color with rainbow tint based on angle
                    float hue = frac(streakAngle / (2.0 * 3.14159) + _Time.y * 0.1);
                    float2 streakUV = float2(hue, 0.5);
                    float4 streakColor = tex2D(_RainbowGradientTex, streakUV);
                    
                    sunburstColor += streakMask * streakColor * 0.2;
                }
                
                // ============= Combine Effects =============
                // Start with base rainbow color
                float4 finalColor = rainbowColor;
                
                // Blend in mirror effect
                finalColor = lerp(finalColor, mirrorColor, 0.5);
                
                // Add sunburst streaks
                finalColor += sunburstColor;
                
                // Apply heart pupil (darkens the center)
                finalColor = lerp(finalColor, _HeartPupilColor, heartMask);
                
                // ============= Apply Environment Lighting =============
                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * ambientLight * 2.0, _EnvironmentLightingAmount);
                
                // Keep alpha at 1 for the iris
                finalColor.a = 1.0;
                
                return finalColor;
            }
            ENDCG
        }
        
        // Lens flare pass with additive blending
        Pass {
            Blend One One // Additive blending for glow effects
            ZWrite Off
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            // Properties
            uniform float _HeartPulseIntensity;
            uniform float _FlareIntensityThreshold;
            uniform float4 _HeartPupilColor;
            uniform sampler2D _RainbowGradientTex;
            uniform sampler2D _AudioLink;
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            // SDF heart function
            float heartSDF(float2 uv, float size) {
                uv = (uv - 0.5) * 2.0; // Center and scale
                float2 q = float2(abs(uv.x), uv.y);
                float d = length(q - float2(0.25, -0.3)) - 0.5;
                return d * (1.0/size); // Negative inside heart, positive outside
            }
            
            // Simple blur function for lens flare
            float4 SampleWithBlur(sampler2D tex, float2 uv, float blurAmount) {
                float4 color = float4(0,0,0,0);
                
                // 5 tap blur
                color += tex2D(tex, uv) * 0.5;
                color += tex2D(tex, uv + float2(blurAmount, 0)) * 0.125;
                color += tex2D(tex, uv - float2(blurAmount, 0)) * 0.125;
                color += tex2D(tex, uv + float2(0, blurAmount)) * 0.125;
                color += tex2D(tex, uv - float2(0, blurAmount)) * 0.125;
                
                return color;
            }
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                // Skip AudioLink in second pass to avoid dependency issues
                // Use simple animation for bass instead
                float bass = 0.5 + sin(_Time.y) * 0.1;
                
                // Calculate heart mask for reference
                float pulseSize = 1.0 + _HeartPulseIntensity * bass * 0.2;
                float heartDistance = heartSDF(i.uv, pulseSize);
                float heartMask = smoothstep(0.01, -0.01, heartDistance);
                
                // Calculate emission from pupil
                float heartGlow = (1.0 - heartMask) * 0.8;
                float emissionStrength = heartGlow;
                
                // Add flare boost based on threshold
                float audioBoost = saturate((bass - _FlareIntensityThreshold) / (1.0 - _FlareIntensityThreshold));
                emissionStrength *= 1.0 + audioBoost * 2.0;
                
                // Apply directional flare
                float2 flareDir = normalize(i.uv - 0.5);
                float flareStrength = pow(1.0 - saturate(length(i.uv - 0.5)), 3.0) * audioBoost;
                
                // Sample rainbow for flare color
                float angle = atan2(flareDir.y, flareDir.x) / (2.0 * 3.14159);
                float2 flareUV = float2(frac(angle + _Time.y * 0.1), 0.5);
                float4 flareColor = SampleWithBlur(_RainbowGradientTex, flareUV, 0.1) * flareStrength;
                
                // Only show flare outside the iris area
                float irisRadius = 0.5;
                float outsideIris = smoothstep(irisRadius - 0.05, irisRadius, length(i.uv - 0.5));
                
                // Final flare color (only visible outside the iris)
                float3 finalFlareColor = emissionStrength * _HeartPupilColor.rgb * outsideIris * 0.3;
                finalFlareColor += flareColor.rgb * outsideIris;
                
                // No alpha in additive blend mode
                return fixed4(finalFlareColor, 0);
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
} 