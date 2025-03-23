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
        
        // Heart pupil controls
        _HeartPupilColor ("Heart Pupil Color", Color) = (0.1,0.02,0.05,0.8)
        _HeartTexture ("Heart Texture", 2D) = "white" {}
        _HeartPupilSize ("Heart Pupil Size", Range(0.1,2.0)) = 1.0
        _HeartPositionX ("Heart Position X", Range(-0.5,0.5)) = 0.0
        _HeartPositionY ("Heart Position Y", Range(-0.5,0.5)) = 0.0
        _HeartBlendMode ("Heart Blend Mode", Range(0,1)) = 0.5
        _HeartGradientAmount ("Heart Gradient Amount", Range(0,1)) = 0.2
        
        // Iris texture controls
        _IrisNoiseIntensity ("Iris Noise Intensity", Range(0,1)) = 0.3
        _IrisNoiseScale ("Iris Noise Scale", Range(1,20)) = 10.0
        _IrisNoiseSpeed ("Iris Noise Speed", Range(0,2)) = 0.5
        
        // Screen-space lens flare controls
        _FlareColor ("Flare Color", Color) = (1,0.8,0.4,1)
        _FlareSize ("Flare Size", Range(0,3)) = 1.0
        _FlareRays ("Flare Rays", Range(0,32)) = 8
        _FlareBloom ("Flare Bloom", Range(0,2)) = 0.5
        
        // Core textures and colors
        _RainbowGradientTex ("Rainbow Gradient", 2D) = "white" {}
        _NoiseTexture ("Noise Texture", 2D) = "black" {}
        
        // AudioLink texture (automatically populated by AudioLink system)
        _AudioLink ("AudioLink Texture", 2D) = "black" {}
    }
    
    SubShader {
        Tags {"Queue"="Transparent+1" "RenderType"="Transparent"}
        ZWrite Off
        Cull Back
        
        // Grab the screen behind the object into _GrabTexture
        GrabPass { "_GrabTexture" }
        
        // Main pass - iris and heart pupil
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            
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
            
            // Heart pupil properties
            uniform float4 _HeartPupilColor;
            uniform sampler2D _HeartTexture;
            uniform float _HeartPupilSize;
            uniform float _HeartPositionX;
            uniform float _HeartPositionY;
            uniform float _HeartBlendMode;
            uniform float _HeartGradientAmount;
            
            // Iris noise properties
            uniform float _IrisNoiseIntensity;
            uniform float _IrisNoiseScale;
            uniform float _IrisNoiseSpeed;
            
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
            
            // Get heart mask from texture
            float getHeartMask(float2 uv, float size) {
                // Adjust for position offset
                float2 heartUV = uv - float2(_HeartPositionX, _HeartPositionY);
                
                // Scale the UVs for sizing (we need to work in 0-1 UV space)
                float2 scaledUV = (heartUV - 0.5) / size + 0.5;
                
                // Sample the heart texture's alpha channel as the mask
                float heartMask = 0;
                
                // Only sample if UVs are within 0-1 range
                if (scaledUV.x >= 0 && scaledUV.x <= 1 && scaledUV.y >= 0 && scaledUV.y <= 1) {
                    heartMask = tex2D(_HeartTexture, scaledUV).a;
                }
                
                return heartMask;
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
            
            // Perlin-like noise function
            float noise(float2 uv) {
                return tex2D(_NoiseTexture, uv).r;
            }
            
            // Fractal noise for more detail
            float fractalNoise(float2 uv, int octaves) {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                for (int i = 0; i < octaves; i++) {
                    value += amplitude * noise(uv * frequency);
                    amplitude *= 0.5;
                    frequency *= 2.0;
                }
                
                return value;
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
                // Calculate heart size including base size and pulse effect
                float heartSize = _HeartPupilSize * (1.0 + _HeartPulseIntensity * bass * 0.2);
                
                // Get heart mask from texture
                float heartMask = getHeartMask(i.uv, heartSize);
                
                // ============= Dynamic Iris Noise =============
                // Create animated noise coordinates
                float2 noiseUV = i.uv * _IrisNoiseScale;
                noiseUV += _Time.y * _IrisNoiseSpeed;
                
                // Generate fractal noise
                float irisNoise = fractalNoise(noiseUV, 3);
                
                // Audio-reactive noise intensity
                float dynamicNoiseIntensity = _IrisNoiseIntensity * (1.0 + highMid * 0.3);
                
                // ============= Rainbow Iris Rings =============
                float2 centeredUV = i.uv - 0.5;
                float dist = length(centeredUV);
                float ringCount = 8.0;
                
                // Apply noise distortion to the distance calculation
                dist += (irisNoise - 0.5) * dynamicNoiseIntensity * 0.1;
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
                
                // Apply iris noise to color
                float3 noiseColor = tex2D(_RainbowGradientTex, float2(irisNoise, 0.5)).rgb;
                rainbowColor.rgb = lerp(rainbowColor.rgb, noiseColor, dynamicNoiseIntensity * 0.2);
                
                // ============= Infinite Mirror Depth Effect =============
                float4 mirrorColor = float4(0,0,0,0);
                float totalWeight = 0;
                
                // Loop through multiple depth layers
                for (int layerIdx = 0; layerIdx < 5; layerIdx++) {
                    float depth = 1.0 - (layerIdx / 5.0) * _InfiniteDepthStrength;
                    float2 scaledUV = (i.uv - 0.5) * depth + 0.5;
                    
                    // Heart mask for this layer
                    float layerHeartMask = getHeartMask(scaledUV, heartSize);
                    
                    // Calculate blur based on depth
                    float blurAmount = layerIdx * _InfiniteBlurStrength * 0.05;
                    
                    // Use rings for the color but apply progressive blur
                    float layerDist = length(scaledUV - 0.5);
                    
                    // Apply noise to each layer differently
                    float layerNoise = fractalNoise(scaledUV * _IrisNoiseScale + float2(layerIdx * 0.1, 0), 2);
                    layerDist += (layerNoise - 0.5) * dynamicNoiseIntensity * 0.1 * (layerIdx + 1) / 5.0;
                    
                    float layerRingIndex = frac(layerDist * ringCount);
                    float2 layerRainbowUV = float2(layerRingIndex, 0.5);
                    float4 layerColor = SampleWithBlur(_RainbowGradientTex, layerRainbowUV, blurAmount);
                    
                    // Accumulate with depth-based weight
                    float weight = exp(-layerIdx * 0.5);
                    mirrorColor += layerColor * layerHeartMask * weight;
                    totalWeight += weight * layerHeartMask;
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
                    
                    // Add noise to streaks
                    float streakNoise = fractalNoise(rotatedUV * 8.0 + float2(0, j * 0.5), 2);
                    streakMask *= 0.8 + streakNoise * 0.4;
                    
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
                
                // Create a heart color that incorporates some of the rainbow gradient
                float4 heartColor = _HeartPupilColor;
                
                // Sample rainbow at heart position for gradient effect
                float2 heartGradientUV = float2(frac(_Time.y * 0.1), 0.5);
                float4 heartGradient = tex2D(_RainbowGradientTex, heartGradientUV);
                
                // Blend heart color with gradient based on parameter
                heartColor.rgb = lerp(heartColor.rgb, heartGradient.rgb, _HeartGradientAmount);
                
                // Apply heart to final color with transparency from heart color alpha
                float effectiveHeartOpacity = heartMask * heartColor.a;
                
                // Mix blending modes between overlay and normal alpha blending
                float4 overlayBlend = lerp(finalColor, heartColor, effectiveHeartOpacity);
                float4 alphaBlend = float4(
                    lerp(finalColor.rgb, heartColor.rgb, effectiveHeartOpacity),
                    finalColor.a
                );
                
                // Choose between blend modes
                finalColor = lerp(alphaBlend, overlayBlend, _HeartBlendMode);
                
                // ============= Apply Environment Lighting =============
                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * ambientLight * 2.0, _EnvironmentLightingAmount);
                
                // Keep alpha at 1 for the iris
                finalColor.a = 1.0;
                
                return finalColor;
            }
            ENDCG
        }
        
        // Screen-space lens flare pass using GrabPass
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
            uniform float _HeartPupilSize;
            uniform float _HeartPositionX;
            uniform float _HeartPositionY;
            uniform float _FlareIntensityThreshold;
            uniform float4 _HeartPupilColor;
            uniform sampler2D _HeartTexture;
            uniform sampler2D _RainbowGradientTex;
            uniform sampler2D _AudioLink;
            
            // Grab pass texture from previous pass
            uniform sampler2D _GrabTexture;
            
            // Screen space flare properties
            uniform float4 _FlareColor;
            uniform float _FlareSize;
            uniform float _FlareRays;
            uniform float _FlareBloom;
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            
            // Get heart mask from texture
            float getHeartMask(float2 uv, float size) {
                // Adjust for position offset
                float2 heartUV = uv - float2(_HeartPositionX, _HeartPositionY);
                
                // Scale the UVs for sizing (we need to work in 0-1 UV space)
                float2 scaledUV = (heartUV - 0.5) / size + 0.5;
                
                // Sample the heart texture's alpha channel as the mask
                float heartMask = 0;
                
                // Only sample if UVs are within 0-1 range
                if (scaledUV.x >= 0 && scaledUV.x <= 1 && scaledUV.y >= 0 && scaledUV.y <= 1) {
                    heartMask = tex2D(_HeartTexture, scaledUV).a;
                }
                
                return heartMask;
            }
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Calculate grab screen position for screen-space effects
                o.grabPos = ComputeGrabScreenPos(o.pos);
                
                // Get world position for calculating flare direction
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                return o;
            }
            
            // Create lens flare effect
            float4 createLensFlare(float2 uv, float2 center, float intensity, float4 baseColor) {
                // Distance from center
                float2 delta = uv - center;
                float dist = length(delta);
                
                // Normalize direction for ray calculation
                float2 dir = normalize(delta);
                
                // Basic bloom around eye center
                float bloom = exp(-dist * 10.0 / _FlareSize) * _FlareBloom * intensity;
                
                // Create rays emanating from center
                float rays = 0;
                if (dist > 0.1) { // Only show rays a bit away from center
                    float angle = atan2(dir.y, dir.x);
                    rays = pow(0.5 + 0.5 * sin(angle * _FlareRays), 5.0) * 
                          exp(-dist * 5.0 / _FlareSize) * intensity;
                }
                
                // Create halo rings
                float halo = 0;
                // Inner halo ring
                float innerRing = abs(dist * 5.0 - 1.0) * 5.0;
                halo += exp(-innerRing * innerRing) * 0.5;
                // Outer halo ring (fainter)
                float outerRing = abs(dist * 2.0 - 1.0) * 10.0;
                halo += exp(-outerRing * outerRing) * 0.3;
                
                // Adjust halo by intensity
                halo *= intensity * 0.5;
                
                // Sample rainbow gradient for color variation based on angle
                float hueOffset = atan2(dir.y, dir.x) / (2.0 * 3.14159);
                float4 rainbowColor = tex2D(_RainbowGradientTex, float2(frac(hueOffset + _Time.y * 0.1), 0.5));
                
                // Combine effects with color
                float4 flareColor = baseColor * bloom + 
                                   baseColor * rays * 0.5 + 
                                   rainbowColor * halo;
                
                return flareColor;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                // Basic animation for pulse effect
                float bass = 0.5 + sin(_Time.y) * 0.1; 
                
                // Calculate heart size including base size and pulse effect
                float heartSize = _HeartPupilSize * (1.0 + _HeartPulseIntensity * bass * 0.2);
                
                // Get heart mask from texture 
                float heartMask = getHeartMask(i.uv, heartSize);
                
                // Generate screen-space position for flare
                float2 grabUV = i.grabPos.xy / i.grabPos.w;
                
                // Calculate the center point of the eye in screen space
                // This is approximately the center of the UV coordinates (0.5, 0.5) projected to screen space
                float2 eyeCenter = i.grabPos.xy / i.grabPos.w;
                // Adjust for the relative position within the eye mesh
                eyeCenter += (0.5 - i.uv) * 0.01; // Small adjustment to center on iris
                
                // Audio-reactive intensity
                float flareIntensity = bass;
                
                // Flare brightness boost based on threshold
                float audioBoost = saturate((flareIntensity - _FlareIntensityThreshold) / (1.0 - _FlareIntensityThreshold));
                flareIntensity = 0.2 + audioBoost * 0.8; // Base intensity plus audio boost
                
                // Create screen space lens flare
                float4 flare = createLensFlare(grabUV, eyeCenter, flareIntensity, _FlareColor);
                
                // Heart glow (inverse of heart mask)
                float heartGlow = (1.0 - heartMask) * 0.8 * audioBoost;
                
                // Apply flare only outside the iris area
                float irisRadius = 0.5;
                float insideIris = saturate(1.0 - length(i.uv - 0.5) / irisRadius);
                // Gradually fade flare at iris boundary
                float flareMask = 1.0 - smoothstep(0.8, 1.0, insideIris);
                
                // Combine heart glow with flare
                float3 finalColor = flare.rgb * flareMask + 
                                    heartGlow * _HeartPupilColor.rgb * (1.0 - flareMask);
                
                // No alpha in additive blend mode
                return fixed4(finalColor, 0);
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
} 