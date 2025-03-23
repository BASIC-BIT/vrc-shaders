Shader "Custom/RainbowHeartburstIris" {
    Properties {
        [HideInInspector] _AnimatedToggle ("Animated Toggle", Float) = 0
        
        [Header(Animation Controls)]
        [Space(5)]
        _HeartPulseIntensity ("Heart Pulse Intensity", Range(0,1)) = 0.5
        _RingRotationSpeed ("Ring Rotation Speed", Range(0,1)) = 0.3
        
        [Space(10)]
        [Header(Heart Pupil)]
        [Toggle(_ENABLE_HEART)] _EnableHeart("Enable Heart Pupil", Float) = 1
        [Space(5)]
        _HeartTexture ("Heart Texture", 2D) = "white" {}
        _HeartPupilColor ("Heart Color", Color) = (0.1, 0.02, 0.05, 1)
        _HeartPupilSize ("Heart Size", Range(0.1, 0.5)) = 0.2
        _HeartPositionX ("Position X", Range(-0.5, 0.5)) = 0
        _HeartPositionY ("Position Y", Range(-0.5, 0.5)) = 0
        _HeartBlendMode ("Blend Mode (0=Alpha, 1=Overlay)", Range(0, 1)) = 0
        _HeartGradientAmount ("Gradient Amount", Range(0, 1)) = 0.3
        _HeartParallaxStrength ("Parallax Strength", Range(0, 1)) = 0.3
        _HeartParallaxHeight ("Parallax Height", Range(0, 0.2)) = 0.05
        
        [Space(10)]
        [Header(Rainbow Iris)]
        [Toggle(_ENABLE_RAINBOW)] _EnableRainbow("Enable Rainbow Iris", Float) = 1
        [Space(5)]
        _RainbowGradientTex ("Rainbow Gradient", 2D) = "white" {}
        _RingCount ("Ring Count", Range(1, 20)) = 10
        _IrisSparkleIntensity ("Sparkle Intensity", Range(0, 1)) = 0.5
        
        [Space(10)]
        [Header(Noise Effects)]
        [Toggle(_ENABLE_NOISE)] _EnableNoise("Enable Noise Effects", Float) = 1
        [Space(5)]
        _NoiseTexture ("Noise Texture", 2D) = "black" {}
        _IrisNoiseIntensity ("Noise Intensity", Range(0, 1)) = 0.3
        _IrisNoiseScale ("Noise Scale", Range(0.1, 10)) = 4
        _IrisNoiseSpeed ("Noise Animation Speed", Range(0, 1)) = 0.2
        
        [Space(10)]
        [Header(Sunburst Streaks)]
        [Toggle(_ENABLE_SUNBURST)] _EnableSunburst("Enable Sunburst Streaks", Float) = 1
        [Space(5)]
        _SunburstLayerCount ("Layer Count", Range(1, 5)) = 3
        _SunburstRotationSpeed ("Rotation Speed", Range(0, 1)) = 0.2
        _SunburstIntensity ("Streak Intensity", Range(0, 1)) = 0.3
        
        [Space(10)]
        [Header(Infinite Mirror)]
        [Toggle(_ENABLE_MIRROR)] _EnableMirror("Enable Infinite Mirror", Float) = 1
        [Space(5)]
        _InfiniteDepthStrength ("Depth Strength", Range(0, 1)) = 0.7
        _InfiniteBlurStrength ("Blur Strength", Range(0, 1)) = 0.5
        _InfiniteLayerCount ("Layer Count", Range(1, 8)) = 5
        _InfiniteParallaxStrength ("Parallax Strength", Range(0, 1)) = 0.3
        
        [Space(10)]
        [Header(Environment)]
        [Toggle(_RESPOND_TO_LIGHT)] _RespondToLight("Respond To Environment Light", Float) = 1
        [Space(5)]
        _EnvironmentLightingAmount ("Lighting Amount", Range(0, 1)) = 0.2
        
        // AudioLink texture (automatically populated by AudioLink system)
        [HideInInspector] _AudioLink ("AudioLink Texture", 2D) = "black" {}
        
        [Space(10)]
        [Header(Parallax Controls)]
        _GlobalParallaxStrength ("Global Parallax Strength", Range(0, 1)) = 0.5
        _RainbowParallaxStrength ("Rainbow Parallax Strength", Range(0, 1)) = 0.2
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
            
            // Feature toggles
            #pragma shader_feature_local _ENABLE_HEART
            #pragma shader_feature_local _ENABLE_RAINBOW
            #pragma shader_feature_local _ENABLE_NOISE
            #pragma shader_feature_local _ENABLE_SUNBURST
            #pragma shader_feature_local _ENABLE_MIRROR
            #pragma shader_feature_local _RESPOND_TO_LIGHT
            
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            
            // Animation properties
            uniform float _HeartPulseIntensity;
            uniform float _RingRotationSpeed;
            
            // Heart pupil properties
            uniform float4 _HeartPupilColor;
            uniform sampler2D _HeartTexture;
            uniform float _HeartPupilSize;
            uniform float _HeartPositionX;
            uniform float _HeartPositionY;
            uniform float _HeartBlendMode;
            uniform float _HeartGradientAmount;
            uniform float _HeartParallaxStrength;
            uniform float _HeartParallaxHeight;
            
            // Rainbow iris properties
            uniform sampler2D _RainbowGradientTex;
            uniform float _RingCount;
            uniform float _IrisSparkleIntensity;
            
            // Noise properties
            uniform sampler2D _NoiseTexture;
            uniform float _IrisNoiseIntensity;
            uniform float _IrisNoiseScale;
            uniform float _IrisNoiseSpeed;
            
            // Infinite mirror properties
            uniform float _InfiniteDepthStrength;
            uniform float _InfiniteBlurStrength;
            uniform float _InfiniteLayerCount;
            uniform float _InfiniteParallaxStrength;
            
            // Sunburst properties
            uniform float _SunburstLayerCount;
            uniform float _SunburstRotationSpeed;
            uniform float _SunburstIntensity;
            
            // Environment properties
            uniform float _EnvironmentLightingAmount;
            
            // Parallax controls
            uniform float _GlobalParallaxStrength;
            uniform float _RainbowParallaxStrength;
            
            // AudioLink texture
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
            
            // Get heart mask from texture with parallax effect
            float getHeartMask(float2 uv, float size, float3 viewDir) {
                // Calculate parallax offset based on view direction and simulated height
                float2 parallaxOffset = float2(0,0);
                #if _ENABLE_HEART
                    parallaxOffset = viewDir.xy * _HeartParallaxStrength * _GlobalParallaxStrength * _HeartParallaxHeight;
                #endif
                
                // Adjust for position offset and apply parallax
                float2 heartUV = uv - float2(_HeartPositionX, _HeartPositionY) + parallaxOffset;
                
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
                float heartMask = 0;
                
                #if _ENABLE_HEART
                // Calculate heart size including base size and pulse effect
                float heartSize = _HeartPupilSize * (1.0 + _HeartPulseIntensity * bass * 0.2);
                
                // Get heart mask from texture
                heartMask = getHeartMask(i.uv, heartSize, i.viewDir);
                #endif
                
                // ============= Dynamic Iris Noise =============
                float irisNoise = 0.5;
                float dynamicNoiseIntensity = 0;
                
                #if _ENABLE_NOISE
                // Create animated noise coordinates
                float2 noiseUV = i.uv * _IrisNoiseScale;
                noiseUV += _Time.y * _IrisNoiseSpeed;
                
                // Generate fractal noise
                irisNoise = fractalNoise(noiseUV, 3);
                
                // Audio-reactive noise intensity
                dynamicNoiseIntensity = _IrisNoiseIntensity * (1.0 + highMid * 0.3);
                #endif
                
                // ============= Rainbow Iris Rings =============
                float4 rainbowColor = float4(0,0,0,0);
                
                #if _ENABLE_RAINBOW
                float2 centeredUV = i.uv - 0.5;
                float dist = length(centeredUV);
                
                // Add slight parallax to rainbow rings
                float2 parallaxRainbowOffset = i.viewDir.xy * _RainbowParallaxStrength * _GlobalParallaxStrength * 0.1;
                float2 rainbowParallaxUV = centeredUV + parallaxRainbowOffset;
                float distWithParallax = length(rainbowParallaxUV);
                
                // Blend between normal and parallax-affected distance
                dist = lerp(dist, distWithParallax, _RainbowParallaxStrength);
                
                // Apply noise distortion to the distance calculation
                #if _ENABLE_NOISE
                dist += (irisNoise - 0.5) * dynamicNoiseIntensity * 0.1;
                #endif
                
                float ringIndex = frac(dist * _RingCount);
                
                // Rotation over time
                float angle = atan2(centeredUV.y, centeredUV.x);
                float rotationSpeed = _Time.y * _RingRotationSpeed;
                float rotatedAngle = angle + rotationSpeed;
                
                // Create a UV that rotates around the center
                float2 rotatedUV = RotateUV(centeredUV, rotationSpeed) + 0.5;
                
                // Sample rainbow gradient based on distance from center
                float2 rainbowUV = float2(ringIndex, 0.5);
                rainbowColor = tex2D(_RainbowGradientTex, rainbowUV);
                
                // Audio-reactive sparkle
                float sparkle = tex2D(_NoiseTexture, i.uv * 5.0 + _Time.y).r;
                float sparkleIntensity = _IrisSparkleIntensity * highMid;
                rainbowColor += sparkle * sparkleIntensity;
                
                // Apply iris noise to color
                #if _ENABLE_NOISE
                float3 noiseColor = tex2D(_RainbowGradientTex, float2(irisNoise, 0.5)).rgb;
                rainbowColor.rgb = lerp(rainbowColor.rgb, noiseColor, dynamicNoiseIntensity * 0.2);
                #endif
                #else
                // Default color if rainbow is disabled
                rainbowColor = float4(0.1, 0.1, 0.2, 1.0);
                #endif
                
                // ============= Infinite Mirror Depth Effect =============
                float4 mirrorColor = rainbowColor;
                
                #if _ENABLE_MIRROR
                mirrorColor = float4(0,0,0,0);
                float totalWeight = 0;
                
                // Get layer count based on parameter
                int layerCount = max(1, min(8, (int)_InfiniteLayerCount));
                
                // Calculate base view-direction parallax amount
                float baseParallaxAmount = _InfiniteParallaxStrength * _GlobalParallaxStrength;
                
                // Loop through multiple depth layers
                for (int layerIdx = 0; layerIdx < layerCount; layerIdx++) {
                    // Calculate depth scale and parallax strength for this layer
                    float layerDepth = 1.0 - (layerIdx / (float)layerCount) * _InfiniteDepthStrength;
                    
                    // Increase parallax effect for deeper layers
                    float layerParallaxStrength = baseParallaxAmount * (1.0 + layerIdx * 0.5);
                    
                    // Calculate parallax offset based on view direction and layer depth
                    float2 parallaxOffset = i.viewDir.xy * layerParallaxStrength * (1.0 - layerDepth);
                    
                    // Apply the parallax offset to the UV
                    float2 scaledUV = (i.uv - 0.5) * layerDepth + 0.5;
                    scaledUV += parallaxOffset;
                    
                    // Heart mask for this layer
                    float layerHeartMask = 0;
                    #if _ENABLE_HEART
                    float heartSize = _HeartPupilSize * (1.0 + _HeartPulseIntensity * bass * 0.2);
                    layerHeartMask = getHeartMask(scaledUV, heartSize, i.viewDir);
                    #endif
                    
                    // Calculate blur based on depth
                    float blurAmount = layerIdx * _InfiniteBlurStrength * 0.05;
                    
                    // Use rings for the color but apply progressive blur
                    float layerDist = length(scaledUV - 0.5);
                    
                    // Apply noise to each layer differently
                    #if _ENABLE_NOISE
                    float layerNoise = fractalNoise(scaledUV * _IrisNoiseScale + float2(layerIdx * 0.1, 0), 2);
                    layerDist += (layerNoise - 0.5) * dynamicNoiseIntensity * 0.1 * (layerIdx + 1) / (float)layerCount;
                    #endif
                    
                    float layerRingIndex = frac(layerDist * _RingCount);
                    float2 layerRainbowUV = float2(layerRingIndex, 0.5);
                    float4 layerColor = SampleWithBlur(_RainbowGradientTex, layerRainbowUV, blurAmount);
                    
                    // Accumulate with depth-based weight
                    float weight = exp(-layerIdx * 0.5);
                    mirrorColor += layerColor * layerHeartMask * weight;
                    totalWeight += weight * layerHeartMask;
                }
                
                // Normalize accumulated color
                if (totalWeight > 0) {
                    mirrorColor = mirrorColor / totalWeight;
                } else {
                    mirrorColor = rainbowColor;
                }
                #endif
                
                // ============= Animated Parallax Sunburst Streaks =============
                float4 sunburstColor = float4(0,0,0,0);
                
                #if _ENABLE_SUNBURST
                // Get integer count for sunburst layers
                int sunburstCount = max(1, min(5, (int)_SunburstLayerCount));
                
                // Loop through sunburst layers
                for (int j = 0; j < sunburstCount; j++) {
                    // Different rotation speed for each layer
                    float layerRotation = _Time.y * _SunburstRotationSpeed * (j % 2 == 0 ? 1 : -1);
                    
                    // Enhanced parallax offset based on view direction
                    float parallaxAmount = 0.02 * (j+1) / sunburstCount * _GlobalParallaxStrength;
                    float2 parallaxOffset = i.viewDir.xy * parallaxAmount;
                    float2 sunburstUV = i.uv + parallaxOffset;
                    
                    // Rotate UVs
                    float2 rotatedUV = RotateUV(sunburstUV - 0.5, layerRotation) + 0.5;
                    
                    // Create radial streaks
                    float streakAngle = atan2(rotatedUV.y-0.5, rotatedUV.x-0.5);
                    float streakMask = (sin(streakAngle * 20.0) * 0.5 + 0.5);
                    streakMask = pow(streakMask, 5.0) * exp(-length(rotatedUV - 0.5) * 5.0);
                    
                    // Add noise to streaks
                    #if _ENABLE_NOISE
                    float streakNoise = fractalNoise(rotatedUV * 8.0 + float2(0, j * 0.5), 2);
                    streakMask *= 0.8 + streakNoise * 0.4;
                    #endif
                    
                    // Add to final color with rainbow tint based on angle
                    float hue = frac(streakAngle / (2.0 * 3.14159) + _Time.y * 0.1);
                    float2 streakUV = float2(hue, 0.5);
                    float4 streakColor = tex2D(_RainbowGradientTex, streakUV);
                    
                    sunburstColor += streakMask * streakColor * _SunburstIntensity;
                }
                #endif
                
                // ============= Combine Effects =============
                // Start with base rainbow color
                float4 finalColor = rainbowColor;
                
                // Blend in mirror effect if enabled
                #if _ENABLE_MIRROR
                finalColor = lerp(finalColor, mirrorColor, 0.5);
                #endif
                
                // Add sunburst streaks if enabled
                #if _ENABLE_SUNBURST
                finalColor += sunburstColor;
                #endif
                
                // Apply heart pupil if enabled
                #if _ENABLE_HEART
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
                #endif
                
                // ============= Apply Environment Lighting =============
                #if _RESPOND_TO_LIGHT
                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * ambientLight * 2.0, _EnvironmentLightingAmount);
                #endif
                
                // Keep alpha at 1 for the iris
                finalColor.a = 1.0;
                
                return finalColor;
            }
            ENDCG
        }
    }
    
    CustomEditor "RainbowHeartburstIrisGUI"
    FallBack "Diffuse"
} 