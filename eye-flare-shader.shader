Shader "Custom/RainbowHeartburstEyeFlare" {
    Properties {
        [Header(Main Controls)]
        [Toggle(_ENABLE_FLARE)] _EnableFlare("Enable Lens Flare", Float) = 1
        
        [Space(10)]
        [Header(Eye Coordination)]
        _EyeIDs ("Active Eye IDs (0-7 bitmask)", Range(0,255)) = 3 // Default: both eyes (1+2=3)
        _FlareScale ("Flare Scale", Range(0.1,5)) = 1.5
        
        [Space(10)]
        [Header(Lens Flare Appearance)]
        _FlareColor ("Flare Color", Color) = (1,0.8,0.4,0.8)
        _FlareSize ("Flare Size", Range(0,5)) = 2.0
        _FlareRays ("Flare Rays", Range(0,32)) = 12
        _FlareRayLength ("Flare Ray Length", Range(0,5)) = 1.5
        _FlareBloom ("Flare Bloom", Range(0,2)) = 0.8
        
        [Space(10)]
        [Header(Animation)]
        _AnimationSpeed ("Animation Speed", Range(0,2)) = 0.5
        _AudioReactivity ("Audio Reactivity", Range(0,1)) = 0.7
        
        [Space(10)]
        [Header(Additional Effects)]
        [Toggle(_ENABLE_CHROMATIC)] _EnableChromatic("Enable Chromatic Aberration", Float) = 1
        _ChromaticAmount ("Chromatic Amount", Range(0,0.05)) = 0.01
        [Toggle(_ENABLE_FLICKER)] _EnableFlicker("Enable Subtle Flicker", Float) = 1
        _FlickerSpeed ("Flicker Speed", Range(0,10)) = 3.0
        
        // Reference to the rainbow gradient texture from the main shader
        [NoScaleOffset] _RainbowGradientTex ("Rainbow Gradient", 2D) = "white" {}
        
        // Hidden properties 
        [HideInInspector] _AudioLink ("AudioLink Texture", 2D) = "black" {}
    }
    
    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Overlay+100" "IgnoreProjector"="True" }
        Blend One One // Additive blending for glow effects
        ZWrite Off
        ZTest Always // Draw on top of everything
        Cull Front // Render only from the back side
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            // Feature toggles
            #pragma shader_feature_local _ENABLE_FLARE
            #pragma shader_feature_local _ENABLE_CHROMATIC
            #pragma shader_feature_local _ENABLE_FLICKER
            
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            
            // Eye coordination
            uniform float _EyeIDs;
            uniform float _FlareScale;
            
            // Flare appearance
            uniform float4 _FlareColor;
            uniform float _FlareSize;
            uniform float _FlareRays;
            uniform float _FlareRayLength;
            uniform float _FlareBloom;
            
            // Animation
            uniform float _AnimationSpeed;
            uniform float _AudioReactivity;
            
            // Effects
            uniform float _ChromaticAmount;
            uniform float _FlickerSpeed;
            
            // Textures
            uniform sampler2D _RainbowGradientTex;
            uniform sampler2D _AudioLink;
            
            // External data from eye shaders (up to 8 eyes)
            uniform float4 _EyeCenter0;
            uniform float4 _EyeCenter1;
            uniform float4 _EyeCenter2;
            uniform float4 _EyeCenter3;
            uniform float4 _EyeCenter4;
            uniform float4 _EyeCenter5;
            uniform float4 _EyeCenter6;
            uniform float4 _EyeCenter7;
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            v2f vert (appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                // Create a full-screen quad
                o.pos = float4(v.vertex.xy * 2.0, 0.5, 1.0);
                o.uv = v.uv;
                o.screenPos = ComputeScreenPos(o.pos);
                
                return o;
            }
            
            // Noise functions
            float hash(float2 p) {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            float2 hash2(float2 p) {
                float h1 = hash(p);
                return float2(h1, hash(p + h1));
            }
            
            float noise(float2 p) {
                float2 i = floor(p);
                float2 f = frac(p);
                
                // Cubic Hermite interpolation
                float2 u = f * f * (3.0 - 2.0 * f);
                
                // Mix 4 corner hashes
                return lerp(
                    lerp(hash(i), hash(i + float2(1.0, 0.0)), u.x),
                    lerp(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), u.x),
                    u.y
                );
            }
            
            // Create lens flare effect
            float4 createLensFlare(float2 uv, float2 center, float intensity, float4 baseColor) {
                // Distance from center
                float2 delta = uv - center;
                float dist = length(delta);
                
                // Normalize direction for ray calculation
                float2 dir = normalize(delta + 0.0001); // Add small value to avoid NaN
                
                // Basic bloom around eye center
                float bloom = exp(-dist * 10.0 / _FlareSize) * _FlareBloom * intensity;
                
                // Create rays emanating from center
                float rays = 0;
                if (dist > 0.01) { // Only show rays a bit away from center
                    float angle = atan2(dir.y, dir.x);
                    rays = pow(0.5 + 0.5 * sin(angle * _FlareRays), 5.0) * 
                          exp(-dist * 10.0 / (_FlareSize * _FlareRayLength)) * intensity;
                }
                
                // Create halo rings
                float halo = 0;
                // Inner halo ring
                float innerRing = abs(dist * 8.0 - 1.0) * 5.0;
                halo += exp(-innerRing * innerRing) * 0.5;
                // Outer halo ring (fainter)
                float outerRing = abs(dist * 3.0 - 1.0) * 10.0;
                halo += exp(-outerRing * outerRing) * 0.3;
                
                // Adjust halo by intensity
                halo *= intensity * 0.6;
                
                // Sample rainbow gradient for color variation based on angle
                float hueOffset = atan2(dir.y, dir.x) / (2.0 * 3.14159);
                float timeOffset = _Time.y * _AnimationSpeed * 0.1;
                float4 rainbowColor = tex2D(_RainbowGradientTex, float2(frac(hueOffset + timeOffset), 0.5));
                
                // Add subtle flicker
                #if _ENABLE_FLICKER
                float flicker = 0.9 + 0.1 * noise(float2(_Time.y * _FlickerSpeed, 0));
                bloom *= flicker;
                rays *= flicker;
                #endif
                
                // Combine effects with color
                float4 flareColor = baseColor * bloom + 
                                   baseColor * rays * 0.8 + 
                                   rainbowColor * halo;
                
                // Apply chromatic aberration
                #if _ENABLE_CHROMATIC
                float2 chromaticOffset = dir * _ChromaticAmount * (dist + 0.1);
                flareColor.r = flareColor.r * 1.1;
                flareColor.g = flareColor.g * 0.9;
                flareColor.b = flareColor.b * 1.2;
                #endif
                
                return flareColor;
            }
            
            // Check if a bit is set in _EyeIDs
            bool isEyeActive(int id) {
                return (((int)_EyeIDs >> id) & 1) != 0;
            }
            
            // Get eye center in screen space
            float2 getEyeScreenPos(int id) {
                float4 eyeCenter = float4(0,0,0,1);
                
                // Select the appropriate eye center based on ID
                if (id == 0) eyeCenter = _EyeCenter0;
                else if (id == 1) eyeCenter = _EyeCenter1;
                else if (id == 2) eyeCenter = _EyeCenter2;
                else if (id == 3) eyeCenter = _EyeCenter3;
                else if (id == 4) eyeCenter = _EyeCenter4;
                else if (id == 5) eyeCenter = _EyeCenter5;
                else if (id == 6) eyeCenter = _EyeCenter6;
                else if (id == 7) eyeCenter = _EyeCenter7;
                
                // Convert eye center world position to screen space
                float4 screenPos = ComputeScreenPos(mul(UNITY_MATRIX_VP, eyeCenter));
                return screenPos.xy / screenPos.w;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                #if !_ENABLE_FLARE
                return fixed4(0,0,0,0);
                #endif
                
                // AudioLink integration for intensity modulation
                float audioIntensity = 1.0;
                if (AudioLinkIsAvailable()) {
                    float4 audioData = AudioLinkData(ALPASS_FILTEREDAUDIOLINK);
                    audioIntensity = lerp(1.0, (audioData.r + audioData.g + audioData.b) / 3.0 * 1.5, _AudioReactivity);
                }
                
                // Initialize final color
                float4 finalColor = float4(0,0,0,0);
                
                // Current screen position
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                // Loop through all possible eyes (up to 8)
                for (int eyeId = 0; eyeId < 8; eyeId++) {
                    // Skip inactive eyes
                    if (!isEyeActive(eyeId)) continue;
                    
                    // Get screen position for this eye
                    float2 eyeScreenPos = getEyeScreenPos(eyeId);
                    
                    // Skip if eye position is invalid (zero)
                    if (length(eyeScreenPos) < 0.001) continue;
                    
                    // Calculate flare intensity based on audio
                    float flareIntensity = audioIntensity;
                    
                    // Generate lens flare for this eye
                    float4 eyeFlare = createLensFlare(screenUV, eyeScreenPos, flareIntensity, _FlareColor);
                    
                    // Add flare to final color (additive blending)
                    finalColor += eyeFlare * _FlareScale;
                }
                
                // Apply some tone mapping to prevent extreme brightness
                finalColor = pow(finalColor, 0.8);
                
                return finalColor;
            }
            ENDCG
        }
    }
    
    CustomEditor "RainbowHeartburstFlareGUI"
} 