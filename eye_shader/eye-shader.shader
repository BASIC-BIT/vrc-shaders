Shader "Custom/RainbowHeartburstIris" {
    Properties {
        [HideInInspector] _AnimatedToggle ("Animated Toggle", Float) = 0
        
        [Header(Animation Controls)]
        [Space(5)]
        _HeartPulseIntensity ("Heart Pulse Intensity", Range(0,1)) = 0.5
        _RingRotationSpeed ("Ring Rotation Speed", Range(0,1)) = 0.3
        
        [Space(10)]
        [Header(Global UV Controls)]
        _GlobalOffsetX ("Global Offset X", Range(-1, 1)) = 0
        _GlobalOffsetY ("Global Offset Y", Range(-1, 1)) = 0
        _GlobalScaleX ("Global Scale X", Range(0.5, 2)) = 1
        _GlobalScaleY ("Global Scale Y", Range(0.5, 2)) = 1
        
        [Space(10)]
        [Header(Heart Pupil)]
        [Toggle(_ENABLE_HEART)] _EnableHeart("Enable Heart Pupil", Float) = 1
        [Space(5)]
        [NoScaleOffset] _HeartTexture ("Heart Texture", 2D) = "white" {}
        _HeartTextureTiling ("Heart Tiling", Vector) = (1,1,0,0)
        _HeartPupilColor ("Heart Color", Color) = (0.1, 0.02, 0.05, 1)
        [Header(Heart HSV)]
        _HeartHue ("Heart Hue Shift", Range(0, 1)) = 0
        _HeartSaturation ("Heart Saturation", Range(0, 2)) = 1
        _HeartBrightness ("Heart Brightness", Range(0, 2)) = 1
        [Header(Heart Noise)]
        [Toggle] _EnableHeartNoise ("Enable Heart Noise", Float) = 0
        _HeartNoiseIntensity ("Noise Intensity", Range(0, 1)) = 0.2
        _HeartNoiseScale ("Noise Scale", Range(0.1, 10)) = 2
        _HeartNoiseSpeed ("Noise Speed", Range(0, 1)) = 0.2
        [Toggle] _HeartDynamicNoise ("Dynamic Noise", Float) = 0
        [Header(Heart Size and Position)]
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
        [NoScaleOffset] _RainbowGradientTex ("Rainbow Gradient", 2D) = "white" {}
        [Header(Rainbow HSV)]
        _RainbowHue ("Rainbow Hue Shift", Range(0, 1)) = 0
        _RainbowSaturation ("Rainbow Saturation", Range(0, 2)) = 1
        _RainbowBrightness ("Rainbow Brightness", Range(0, 2)) = 1
        [Header(Rainbow Pattern)]
        _RingCount ("Ring Count", Range(1, 20)) = 10
        _IrisSparkleIntensity ("Sparkle Intensity", Range(0, 1)) = 0.5
        
        [Space(10)]
        [Header(Iris Detail)]
        [Toggle(_ENABLE_IRIS_DETAIL)] _EnableIrisDetail("Enable Iris Detail", Float) = 1
        [Space(5)]
        [NoScaleOffset] _IrisTexture ("Iris Texture", 2D) = "white" {}
        _IrisTextureTiling ("Iris Tiling", Vector) = (1,1,0,0)
        _IrisTextureIntensity ("Texture Intensity", Range(0, 1)) = 0.5
        _IrisTextureContrast ("Texture Contrast", Range(0, 2)) = 1
        [Toggle] _IrisRadialPattern ("Radial Pattern Mode", Float) = 1
        _IrisPatternRotation ("Pattern Rotation", Range(0, 6.28)) = 0
        _IrisDetailParallax ("Detail Parallax", Range(0, 1)) = 0.2
        
        [Space(10)]
        [Header(Limbal Ring)]
        [Toggle(_ENABLE_LIMBAL_RING)] _EnableLimbalRing("Enable Limbal Ring", Float) = 1
        [Space(5)]
        _LimbalRingColor ("Ring Color", Color) = (0.05, 0.04, 0.03, 1)
        [Header(Limbal Ring HSV)]
        _LimbalRingHue ("Limbal Ring Hue Shift", Range(0, 1)) = 0
        _LimbalRingSaturation ("Limbal Ring Saturation", Range(0, 2)) = 1
        _LimbalRingBrightness ("Limbal Ring Brightness", Range(0, 2)) = 1
        [Header(Limbal Ring Size)]
        _LimbalRingWidth ("Ring Width", Range(0.01, 0.2)) = 0.05
        _LimbalRingSoftness ("Ring Softness", Range(0, 0.1)) = 0.02
        
        [Space(10)]
        [Header(Noise Effects)]
        [Toggle(_ENABLE_NOISE)] _EnableNoise("Enable Noise Effects", Float) = 1
        [Space(5)]
        [NoScaleOffset] _NoiseTexture ("Noise Texture", 2D) = "black" {}
        _NoiseTextureTiling ("Noise Tiling", Vector) = (1,1,0,0)
        _IrisNoiseIntensity ("Noise Intensity", Range(0, 1)) = 0.3
        _IrisNoiseScale ("Noise Scale", Range(0.1, 10)) = 4
        _NoiseFlowSpeed ("Flow Speed", Range(0, 1)) = 0.2
        [Toggle] _DynamicNoiseMovement ("Dynamic Flow Movement", Float) = 1
        _NoiseDistortionScale ("Flow Distortion Scale", Range(0.1, 10)) = 2
        _NoiseDistortionAmount ("Flow Distortion Amount", Range(0, 2)) = 0.5
        
        [Space(10)]
        [Header(Sparkle Effects)]
        [Toggle(_ENABLE_SPARKLE)] _EnableSparkle("Enable Sparkle Effects", Float) = 1
        [Space(5)]
        _SparkleColor ("Sparkle Color", Color) = (1, 1, 1, 1)
        [Header(Sparkle HSV)]
        _SparkleHue ("Sparkle Hue Shift", Range(0, 1)) = 0
        _SparkleSaturation ("Sparkle Saturation", Range(0, 2)) = 1
        _SparkleBrightness ("Sparkle Brightness", Range(0, 2)) = 1
        [Header(Sparkle Pattern)]
        _SparkleScale ("Sparkle Scale", Range(1, 50)) = 20
        _SparkleSpeed ("Sparkle Speed", Range(0, 5)) = 1
        _SparkleAmount ("Sparkle Amount", Range(0, 1)) = 0.5
        _SparkleSharpness ("Sparkle Sharpness", Range(1, 20)) = 5
        
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
        
        [Space(10)]
        [Header(Top Shading)]
        [Toggle(_ENABLE_TOP_SHADING)] _EnableTopShading("Enable Top Shading", Float) = 1
        [Space(5)]
        _TopShadingIntensity ("Intensity", Range(0, 1)) = 0.3
        _TopShadingHeight ("Height", Range(0, 1)) = 0.5
        _TopShadingSoftness ("Softness", Range(0.01, 0.5)) = 0.1
        
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
            #pragma shader_feature_local _ENABLE_TOP_SHADING
            #pragma shader_feature_local _ENABLE_RAINBOW
            #pragma shader_feature_local _ENABLE_NOISE
            #pragma shader_feature_local _ENABLE_SUNBURST
            #pragma shader_feature_local _ENABLE_MIRROR
            #pragma shader_feature_local _RESPOND_TO_LIGHT
            #pragma shader_feature_local _ENABLE_IRIS_DETAIL
            #pragma shader_feature_local _ENABLE_LIMBAL_RING
            #pragma shader_feature_local _ENABLE_SPARKLE
            
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            
            // Animation properties
            uniform float _HeartPulseIntensity;
            uniform float _RingRotationSpeed;
            
            // Heart pupil properties
            uniform float4 _HeartPupilColor;
            uniform sampler2D _HeartTexture;
            uniform float4 _HeartTextureTiling;
            uniform float _HeartPupilSize;
            uniform float _HeartPositionX;
            uniform float _HeartPositionY;
            uniform float _HeartBlendMode;
            uniform float _HeartGradientAmount;
            uniform float _HeartParallaxStrength;
            uniform float _HeartParallaxHeight;
            uniform float _HeartHue;
            uniform float _HeartSaturation;
            uniform float _HeartBrightness;
            uniform float _EnableHeartNoise;
            uniform float _HeartNoiseIntensity;
            uniform float _HeartNoiseScale;
            uniform float _HeartNoiseSpeed;
            uniform float _HeartDynamicNoise;
            
            // Rainbow iris properties
            uniform sampler2D _RainbowGradientTex;
            uniform float _RingCount;
            uniform float _IrisSparkleIntensity;
            uniform float _RainbowHue;
            uniform float _RainbowSaturation;
            uniform float _RainbowBrightness;
            
            // Iris detail properties
            uniform sampler2D _IrisTexture;
            uniform float4 _IrisTextureTiling;
            uniform float _IrisTextureIntensity;
            uniform float _IrisTextureContrast;
            uniform float _IrisRadialPattern;
            uniform float _IrisPatternRotation;
            uniform float _IrisDetailParallax;
            
            // Limbal ring properties
            uniform float4 _LimbalRingColor;
            uniform float _LimbalRingWidth;
            uniform float _LimbalRingSoftness;
            uniform float _LimbalRingHue;
            uniform float _LimbalRingSaturation;
            uniform float _LimbalRingBrightness;
            
            // Noise properties
            uniform sampler2D _NoiseTexture;
            uniform float4 _NoiseTextureTiling;
            uniform float _IrisNoiseIntensity;
            uniform float _IrisNoiseScale;
            uniform float _NoiseFlowSpeed;
            uniform float _DynamicNoiseMovement;
            uniform float _NoiseDistortionScale;
            uniform float _NoiseDistortionAmount;
            
            // Sparkle properties
            uniform float4 _SparkleColor;
            uniform float _SparkleScale;
            uniform float _SparkleSpeed;
            uniform float _SparkleAmount;
            uniform float _SparkleSharpness;
            uniform float _SparkleHue;
            uniform float _SparkleSaturation;
            uniform float _SparkleBrightness;
            
            // Infinite mirror properties
            uniform float _InfiniteDepthStrength;
            uniform float _InfiniteBlurStrength;
            uniform float _InfiniteLayerCount;
            uniform float _InfiniteParallaxStrength;
            
            
            // Top Shading properties
            uniform float _EnableTopShading;
            uniform float _TopShadingIntensity;
            uniform float _TopShadingHeight;
            uniform float _TopShadingSoftness;
            // Sunburst properties
            uniform float _SunburstLayerCount;
            uniform float _SunburstRotationSpeed;
            uniform float _SunburstIntensity;
            
            // Environment properties
            uniform float _EnvironmentLightingAmount;
            
            // Parallax controls
            uniform float _GlobalParallaxStrength;
            uniform float _RainbowParallaxStrength;
            
            // Global UV controls
            uniform float _GlobalOffsetX;
            uniform float _GlobalOffsetY;
            uniform float _GlobalScaleX;
            uniform float _GlobalScaleY;
            
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
            
            // Apply tiling and offset to UVs
            float2 ApplyTilingOffset(float2 uv, float4 tilingOffset) {
                return frac(uv * tilingOffset.xy) + tilingOffset.zw;
            }
            
            // Convert RGB to HSV
            float3 RGBtoHSV(float3 c) {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }
            
            // Convert HSV to RGB
            float3 HSVtoRGB(float3 c) {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            // Apply HSV adjustment to a color
            float3 AdjustHSV(float3 color, float hueShift, float satAdjust, float valueAdjust) {
                float3 hsv = RGBtoHSV(color);
                
                // Apply adjustments
                hsv.x = frac(hsv.x + hueShift); // Hue shift
                hsv.y = saturate(hsv.y * satAdjust); // Saturation
                hsv.z = saturate(hsv.z * valueAdjust); // Value/Brightness
                
                return HSVtoRGB(hsv);
            }
            
            // Forward declarations of functions used later
            float noise(float2 uv);
            float fractalNoise(float2 uv, int octaves);
            float2 flowDistortion(float2 uv, float time);
            
            // Modify the getHeartMask function to return both the mask and color
            float4 getHeartTexture(float2 uv, float size, float3 viewDir) {
                // Calculate parallax offset based on view direction and simulated height
                float2 parallaxOffset = float2(0,0);
                #if _ENABLE_HEART
                    parallaxOffset = viewDir.xy * _HeartParallaxStrength * _GlobalParallaxStrength * _HeartParallaxHeight;
                #endif
                
                // Adjust for position offset and apply parallax
                float2 heartUV = uv - float2(_HeartPositionX, _HeartPositionY) + parallaxOffset;
                
                // Apply heart-specific noise distortion if enabled
                if (_EnableHeartNoise > 0.5) {
                    float2 noiseOffset = float2(0, 0);
                    
                    if (_HeartDynamicNoise > 0.5) {
                        // Use flow distortion for organic movement (similar to iris noise)
                        noiseOffset = flowDistortion(heartUV, _Time.y * 0.5) * _HeartNoiseSpeed * 0.5;
                    } else {
                        // Use simple panning for basic movement
                        noiseOffset = float2(_Time.y, _Time.y * 0.7) * _HeartNoiseSpeed * 0.5;
                    }
                    
                    // Generate noise specifically for heart distortion
                    float2 heartNoiseUV = heartUV * _HeartNoiseScale + noiseOffset;
                    float heartNoise = fractalNoise(heartNoiseUV, 2);
                    
                    // Apply the noise to distort the heart UV coordinates
                    heartUV += (heartNoise - 0.5) * _HeartNoiseIntensity * 0.1;
                }
                
                // Scale the UVs for sizing (we need to work in 0-1 UV space)
                float2 scaledUV = (heartUV - 0.5) / size + 0.5;
                
                // We'll use the _HeartTextureTiling for custom scaling only, not for repeating
                scaledUV = scaledUV * _HeartTextureTiling.xy + _HeartTextureTiling.zw;
                
                // Sample the heart texture's color and alpha
                float4 heartTexture = float4(0,0,0,0);
                
                // Only sample if UVs are within 0-1 range - PREVENT TILING
                if (scaledUV.x >= 0 && scaledUV.x <= 1 && scaledUV.y >= 0 && scaledUV.y <= 1) {
                    heartTexture = tex2D(_HeartTexture, scaledUV);
                }
                
                return heartTexture;
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
            
            // Perlin-like noise functions
            float noise(float2 uv) {
                uv = ApplyTilingOffset(uv, _NoiseTextureTiling);
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
            
            // Dynamic distortion using flow fields
            float2 flowDistortion(float2 uv, float time) {
                // Generate flow field vectors using noise
                float2 flow;
                flow.x = fractalNoise(uv * _NoiseDistortionScale + float2(0, time * 0.1), 2) * 2.0 - 1.0;
                flow.y = fractalNoise(uv * _NoiseDistortionScale + float2(time * 0.15, 0), 2) * 2.0 - 1.0;
                
                // Normalize and scale
                flow = normalize(flow) * _NoiseDistortionAmount;
                
                return flow;
            }
            
            // Generate sparkles effect
            float generateSparkles(float2 uv, float time) {
                // Create several layers of noise at different scales for sparkle effect
                float n1 = fractalNoise(uv * _SparkleScale + float2(time * _SparkleSpeed, 0), 2);
                float n2 = fractalNoise(uv * (_SparkleScale * 0.75) - float2(0, time * _SparkleSpeed * 0.7), 2);
                float n3 = fractalNoise(uv * (_SparkleScale * 1.25) + float2(time * _SparkleSpeed * 0.3, time * _SparkleSpeed * 0.3), 2);
                
                // Combine noise layers for more interesting patterns
                float sparkle = n1 * n2 * n3;
                
                // Further enhance contrast and sharpness
                sparkle = saturate(pow(sparkle, _SparkleSharpness));
                
                // Use a higher threshold for more dramatic sparkles
                return step(1.0 - _SparkleAmount, sparkle);
            }
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // Apply global UV transformation with separate X and Y scaling
                float2 globalUV = v.uv;
                globalUV = (globalUV - 0.5) / float2(_GlobalScaleX, _GlobalScaleY) + 0.5;
                globalUV += float2(_GlobalOffsetX, _GlobalOffsetY);
                o.uv = globalUV;
                
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
                
                // ============= Dynamic Iris Noise with Flow Fields =============
                float2 centeredUV = i.uv - 0.5;
                float dist = length(centeredUV);
                float2 noiseUV = i.uv;
                float dynamicNoiseIntensity = 0;
                float irisNoise = 0.5;
                
                #if _ENABLE_NOISE
                // Create dynamic flowing noise using flow fields
                float2 flowOffset = float2(0, 0);
                
                if (_DynamicNoiseMovement > 0.5) {
                    // Use flow distortion for organic movement
                    flowOffset = flowDistortion(i.uv, _Time.y) * _NoiseFlowSpeed;
                } else {
                    // Use simple panning for basic movement
                    flowOffset = float2(_Time.y, _Time.y * 0.7) * _NoiseFlowSpeed;
                }
                
                // Apply flow to noise coordinates
                noiseUV = i.uv * _IrisNoiseScale + flowOffset;
                
                // Generate fractal noise
                irisNoise = fractalNoise(noiseUV, 3);
                
                // Audio-reactive noise intensity
                dynamicNoiseIntensity = _IrisNoiseIntensity * (1.0 + highMid * 0.3);
                #endif
                
                // ============= Rainbow Iris Rings =============
                float4 rainbowColor = float4(0,0,0,0);
                
                #if _ENABLE_RAINBOW
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
                
                // Apply HSV adjustments to rainbow color
                rainbowColor.rgb = AdjustHSV(rainbowColor.rgb, _RainbowHue, _RainbowSaturation, _RainbowBrightness);
                
                // Apply iris noise to color
                #if _ENABLE_NOISE
                float3 noiseColor = tex2D(_RainbowGradientTex, float2(irisNoise, 0.5)).rgb;
                noiseColor = AdjustHSV(noiseColor, _RainbowHue, _RainbowSaturation, _RainbowBrightness);
                rainbowColor.rgb = lerp(rainbowColor.rgb, noiseColor, dynamicNoiseIntensity * 0.2);
                #endif
                #else
                // Default color if rainbow is disabled
                rainbowColor = float4(0.1, 0.1, 0.2, 1.0);
                #endif
                
                // ============= Iris Detail Texture =============
                #if _ENABLE_IRIS_DETAIL
                // Create parallax offset for detail texture
                float2 detailParallaxOffset = i.viewDir.xy * _IrisDetailParallax * _GlobalParallaxStrength;
                float2 detailUV = i.uv + detailParallaxOffset;
                
                // For radial pattern, convert to polar coordinates and adjust
                if (_IrisRadialPattern > 0.5) {
                    float2 polarUV;
                    polarUV.x = atan2(detailUV.y - 0.5, detailUV.x - 0.5) / (2.0 * 3.14159) + 0.5; // Angle
                    polarUV.y = length(detailUV - 0.5) * 2.0; // Distance
                    
                    // Rotate the pattern
                    polarUV.x = frac(polarUV.x + _IrisPatternRotation / (2.0 * 3.14159));
                    
                    detailUV = polarUV;
                } else {
                    // For non-radial, just rotate the UVs
                    detailUV = RotateUV(detailUV - 0.5, _IrisPatternRotation) + 0.5;
                }
                
                // Apply tiling and offset
                detailUV = ApplyTilingOffset(detailUV, _IrisTextureTiling);
                
                // Sample detail texture and adjust contrast
                float4 irisDetail = tex2D(_IrisTexture, detailUV);
                irisDetail.rgb = saturate(((irisDetail.rgb - 0.5) * _IrisTextureContrast) + 0.5);
                
                // Blend with rainbow color
                rainbowColor.rgb = lerp(rainbowColor.rgb, rainbowColor.rgb * irisDetail.rgb, _IrisTextureIntensity);
                #endif
                
                // ============= Dynamic Sparkles =============
                float4 sparkleColor = float4(0,0,0,0);
                
                #if _ENABLE_SPARKLE
                // Audio-reactive sparkle intensity
                float audioSparkleIntensity = _IrisSparkleIntensity * (0.7 + highMid * 0.5);
                
                // Generate dynamic sparkles
                float sparkleEffect = generateSparkles(i.uv, _Time.y);
                
                // Create sparkle color with HSV adjustments
                float3 adjustedSparkleColor = AdjustHSV(_SparkleColor.rgb, _SparkleHue, _SparkleSaturation, _SparkleBrightness);
                
                // Scale by audio and make sparkles brighter
                sparkleColor.rgb = adjustedSparkleColor * sparkleEffect * audioSparkleIntensity * 3.0;
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
                    layerHeartMask = getHeartTexture(scaledUV, heartSize, i.viewDir).a;
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
                    
                    // Apply HSV adjustments to layer color
                    layerColor.rgb = AdjustHSV(layerColor.rgb, _RainbowHue, _RainbowSaturation, _RainbowBrightness);
                    
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
                    
                    // Apply HSV adjustments to streak color
                    streakColor.rgb = AdjustHSV(streakColor.rgb, _RainbowHue, _RainbowSaturation, _RainbowBrightness);
                    
                    sunburstColor += streakMask * streakColor * _SunburstIntensity;
                }
                #endif
                
                // ============= Limbal Ring (Iris Outline) =============
                float4 limbalRingColor = float4(0,0,0,0);
                float limbalRingMask = 0;
                
                #if _ENABLE_LIMBAL_RING
                // Create a soft ring mask (FIXED: inverted calculation to make larger values = wider ring)
                float ringDist = 0.5 - dist;
                limbalRingMask = smoothstep(0, _LimbalRingSoftness, ringDist) * 
                                 smoothstep(_LimbalRingWidth, _LimbalRingWidth - _LimbalRingSoftness, ringDist);
                
                // Apply HSV adjustments to limbal ring color
                float3 adjustedRingColor = AdjustHSV(_LimbalRingColor.rgb, _LimbalRingHue, _LimbalRingSaturation, _LimbalRingBrightness);
                limbalRingColor = float4(adjustedRingColor, _LimbalRingColor.a * limbalRingMask);
                #endif
                
                // ============= Heart-shaped Pupil =============
                float heartMask = 0;
                float4 heartColor = float4(0,0,0,0);
                float4 heartTexture = float4(0,0,0,0);
                
                #if _ENABLE_HEART
                // Calculate heart size including base size and pulse effect
                float heartSize = _HeartPupilSize * (1.0 + _HeartPulseIntensity * bass * 0.2);
                
                // Get heart texture and mask
                heartTexture = getHeartTexture(i.uv, heartSize, i.viewDir);
                heartMask = heartTexture.a;
                
                // Create a heart color that incorporates the texture
                heartColor = _HeartPupilColor * float4(heartTexture.rgb, 1.0);
                
                // Apply HSV adjustments to heart color
                heartColor.rgb = AdjustHSV(heartColor.rgb, _HeartHue, _HeartSaturation, _HeartBrightness);
                
                // Sample rainbow at heart position for gradient effect
                float2 heartGradientUV = float2(frac(_Time.y * 0.1), 0.5);
                float4 heartGradient = tex2D(_RainbowGradientTex, heartGradientUV);
                heartGradient.rgb = AdjustHSV(heartGradient.rgb, _HeartHue, _HeartSaturation, _HeartBrightness);
                
                // Blend heart color with gradient based on parameter
                heartColor.rgb = lerp(heartColor.rgb, heartGradient.rgb, _HeartGradientAmount);
                
                #endif
                
                // ============= Combine Effects =============
                // Start with base rainbow color
                float4 finalColor = rainbowColor;
                
                // Variables will be declared inside the #if block below
                
                // Blend in mirror effect if enabled
                #if _ENABLE_MIRROR
                finalColor = lerp(finalColor, mirrorColor, 0.5);
                #endif
                
                // Add sunburst streaks if enabled
                #if _ENABLE_SUNBURST
                finalColor.rgb += sunburstColor.rgb;
                #endif
                
                // Apply sparkle effect if enabled
                #if _ENABLE_SPARKLE
                finalColor.rgb += sparkleColor.rgb;
                #endif
                
                // Apply limbal ring (FIXED: now rendered after base iris but before heart pupil)
                #if _ENABLE_LIMBAL_RING
                finalColor.rgb = lerp(finalColor.rgb, limbalRingColor.rgb, limbalRingMask * _LimbalRingColor.a);
                #endif
                
                // Apply heart pupil if enabled (rendered last so it's always on top)
                #if _ENABLE_HEART
                // Apply heart to final color with transparency from heart color alpha
                float effectiveHeartOpacity = heartMask * heartColor.a;
                
                // Mix blending modes between overlay and normal alpha blending
                float4 overlayBlend = lerp(finalColor, heartColor, effectiveHeartOpacity);
                // Complete the alphaBlend calculation (assuming alpha comes from finalColor)
                float4 alphaBlend = float4(lerp(finalColor.rgb, heartColor.rgb, effectiveHeartOpacity), finalColor.a);
                
                // Choose between blend modes
                finalColor = lerp(alphaBlend, overlayBlend, _HeartBlendMode);
                #endif // End of _ENABLE_HEART block
                
                // ============= Apply Top Shading =============
                #if _ENABLE_TOP_SHADING
                // Calculate the start and end points for the smoothstep gradient
                half gradientStart = 1.0 - _TopShadingHeight; // UV.y where shading starts to fade in
                half gradientEnd = gradientStart + _TopShadingSoftness; // UV.y where shading is fully faded in
                
                // Calculate the shading factor (0 = full shadow, 1 = no shadow)
                // We invert the uv.y because typically UVs go 0 at bottom, 1 at top
                half shadingFactor = smoothstep(gradientStart, gradientEnd, 1.0 - i.uv.y);
                
                // Apply intensity (lerp from 1 down towards 0 based on intensity)
                shadingFactor = lerp(1.0, shadingFactor, _TopShadingIntensity);
                
                // Multiply the final color's RGB by the shading factor
                finalColor.rgb *= shadingFactor;
                #endif // End _ENABLE_TOP_SHADING
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