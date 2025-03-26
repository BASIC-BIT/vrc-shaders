Shader "Custom/AudioReactiveKaleidoscope"
{
    Properties
    {
        // Main parameters
        [Header(Base Settings)]
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _ColorVariation ("Color Variation", Range(0, 1)) = 0.5
        _Brightness ("Brightness", Range(0.1, 5.0)) = 1.0
        _Contrast ("Contrast", Range(0.1, 5.0)) = 1.0
        
        // Rotation speeds
        [Header(Rotation)]
        _RotationSpeedXY ("XY Rotation Speed", Range(-2, 2)) = 0.3
        _RotationSpeedXZ ("XZ Rotation Speed", Range(-2, 2)) = 0.45
        _RotationSpeedZY ("ZY Rotation Speed", Range(-2, 2)) = 0.3

        // Fractal parameters
        [Header(Fractal Structure)]
        _SymmetryCount ("Symmetry Count", Range(2, 16)) = 5
        _SymmetryOffset ("Symmetry Offset", Range(-5, 5)) = 2
        _FractalIterations ("Fractal Iterations", Range(1, 12)) = 8
        _IterationScale ("Iteration Scale", Range(1.0, 2.0)) = 1.4
        _BoxDimensions ("Box Dimensions", Vector) = (1, 0.3, 0.4, 0)
        _ZModFactor ("Z Modulation Factor", Range(1, 10)) = 5
        
        // Ray marching parameters
        [Header(Ray Marching)]
        _Iterations ("Ray March Iterations", Range(10, 200)) = 110
        _StepSize ("Step Size", Range(0.01, 2.0)) = 1.0
        _FractalScale ("Fractal Scale", Range(1, 50)) = 20
        
        // Animation parameters
        [Header(Animation)]
        _AnimationSpeed ("Animation Speed", Range(0, 2)) = 1.0
        _FractalAnimSpeed1 ("Fractal Animation Speed 1", Range(0, 2)) = 0.234
        _FractalAnimSpeed2 ("Fractal Animation Speed 2", Range(0, 2)) = 0.3
        _FractalAnimSpeed3 ("Fractal Animation Speed 3", Range(0, 2)) = 0.5
        _WaveScale1 ("Wave Scale 1", Range(0, 10)) = 3.0
        _WaveScale2 ("Wave Scale 2", Range(0, 10)) = 5.0
        
        // AudioLink parameters
        [Header(AudioLink)]
        [Toggle] _UseAudioLink ("Use AudioLink", Float) = 0
        _AudioLinkBassIntensity ("Bass Intensity", Range(0, 5)) = 1.0
        _AudioLinkMidIntensity ("Mid Intensity", Range(0, 5)) = 1.0
        _AudioLinkHighIntensity ("High Intensity", Range(0, 5)) = 1.0
        _AudioLinkBeatMultiplier ("Beat Multiplier", Range(0, 10)) = 1.0
        
        [Header(AudioLink Effect Mapping)]
        [Enum(None, 0, Symmetry, 1, Scale, 2, Rotation, 3, Color, 4)] _BassEffect ("Bass Effect", Int) = 1
        [Enum(None, 0, Symmetry, 1, Scale, 2, Rotation, 3, Color, 4)] _MidEffect ("Mid Effect", Int) = 2
        [Enum(None, 0, Symmetry, 1, Scale, 2, Rotation, 3, Color, 4)] _HighEffect ("High Effect", Int) = 3
        
        [Header(Color Effects)]
        _ColorCycleSpeed ("Color Cycle Speed", Range(0, 10)) = 0.1
        _PulseIntensity ("Pulse Intensity", Range(0, 1)) = 0.8
        _ColorBlendAmount ("Color Blend Amount", Range(0, 1)) = 0.5
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 rayOrigin : TEXCOORD1;
                float3 rayDir : TEXCOORD2;
            };
            
            // Define all the parameters
            float4 _MainColor;
            float _ColorVariation;
            float _Brightness;
            float _Contrast;
            float _RotationSpeedXY;
            float _RotationSpeedXZ;
            float _RotationSpeedZY;
            float _SymmetryCount;
            float _SymmetryOffset;
            int _FractalIterations;
            float _IterationScale;
            float4 _BoxDimensions;
            float _ZModFactor;
            int _Iterations;
            float _StepSize;
            float _FractalScale;
            float _AnimationSpeed;
            float _FractalAnimSpeed1;
            float _FractalAnimSpeed2;
            float _FractalAnimSpeed3;
            float _WaveScale1;
            float _WaveScale2;
            float _UseAudioLink;
            float _AudioLinkBassIntensity;
            float _AudioLinkMidIntensity;
            float _AudioLinkHighIntensity;
            float _AudioLinkBeatMultiplier;
            int _BassEffect;
            int _MidEffect;
            int _HighEffect;
            float _ColorCycleSpeed;
            float _PulseIntensity;
            float _ColorBlendAmount;

            // AudioLink texture
            sampler2D _AudioTexture;
            
            // Constants
            static const float PI = 3.14159265359;
            static const float PI2 = PI * 2.0;
            
            // Helper functions from the original shader
            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            float rand(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453 + _Time.y * _AnimationSpeed * 0.35);
            }
            
            float noise(float2 st)
            {
                float2 i = floor(st);
                float2 f = frac(st);
            
                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));
            
                // Cubic Hermine Curve
                float2 u = f*f*(3.0-2.0*f);
            
                // Mix
                return lerp(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
            }
            
            float3 hueCos(float h)
            {
                return cos((h)*6.3+float3(0,23,21))*0.5+0.5;
            }
            
            float2x2 rot(float a)
            {
                float s = sin(a), c = cos(a);
                return float2x2(c, s, -s, c);
            }
            
            float2 pmod(float2 p, float d)
            {
                float a = atan2(p.x, p.y) + PI / d;
                float n = PI2 / d;
                a = floor(a / n) * n;
                float2x2 rotMatrix = rot(-a);
                return mul(rotMatrix, p);
            }
            
            float sdBox(float3 p, float3 b)
            {
                float3 d = abs(p) - b;
                return length(max(d, 0.0)) + min(max(max(d.x, d.y), d.z), 0.0);
            }
            
            float sdSphere(float3 p, float r)
            {
                return length(p) - r;
            }
            
            // AudioLink utility functions
            float4 AudioLinkData(int2 xy)
            {
                if (_UseAudioLink < 0.5) return 0;
                return tex2Dlod(_AudioTexture, float4((xy + 0.5) / float2(128, 64), 0, 0));
            }
            
            // Get bass, mid, high audio values (0-1 range)
            float GetBass()
            {
                return AudioLinkData(int2(0, 0)).r * _AudioLinkBassIntensity;
            }
            
            float GetMid()
            {
                return AudioLinkData(int2(16, 0)).r * _AudioLinkMidIntensity;
            }
            
            float GetHigh()
            {
                return AudioLinkData(int2(48, 0)).r * _AudioLinkHighIntensity;
            }
            
            // Beat detection
            float DetectBeat()
            {
                float bass = GetBass();
                float threshold = 0.7;
                float beat = step(threshold, bass) * bass * _AudioLinkBeatMultiplier;
                return beat;
            }
            
            // Combine all the audio-reactive parameters
            void ApplyAudioLink(inout float symmetry, inout float scale, inout float rotation, inout float3 color)
            {
                if (_UseAudioLink < 0.5) return;
                
                float bassValue = GetBass();
                float midValue = GetMid();
                float highValue = GetHigh();
                float beatValue = DetectBeat();
                
                // Apply based on effect mapping
                // Bass effect
                if (_BassEffect == 1) symmetry += bassValue * 5; // Symmetry
                else if (_BassEffect == 2) scale += bassValue; // Scale
                else if (_BassEffect == 3) rotation += bassValue; // Rotation
                else if (_BassEffect == 4) color = lerp(color, float3(1,0,0) * bassValue, bassValue * 0.5); // Color effect
                
                // Mid effect
                if (_MidEffect == 1) symmetry += midValue * 5; // Symmetry
                else if (_MidEffect == 2) scale += midValue; // Scale
                else if (_MidEffect == 3) rotation += midValue; // Rotation
                else if (_MidEffect == 4) color = lerp(color, float3(0,1,0) * midValue, midValue * 0.5); // Color effect
                
                // High effect
                if (_HighEffect == 1) symmetry += highValue * 5; // Symmetry
                else if (_HighEffect == 2) scale += highValue; // Scale
                else if (_HighEffect == 3) rotation += highValue * 2; // Rotation
                else if (_HighEffect == 4) color = lerp(color, float3(0,0,1) * highValue, highValue * 0.5); // Color effect
                
                // Beat pulses - affects all
                symmetry += beatValue * 2;
                scale += beatValue;
                rotation += beatValue * PI * 0.1;
                color = lerp(color, float3(1,1,1), beatValue * 0.3);
            }
            
            float map(float3 p)
            {
                float time = _Time.y * _AnimationSpeed;
                float symmetry = _SymmetryCount;
                float scale = 1.0;
                float rotation = 1.0;
                float3 colorMod = float3(1,1,1);
                
                // Apply audio effects to parameters
                ApplyAudioLink(symmetry, scale, rotation, colorMod);
                
                // Apply modulated parameters to calculations
                p.xy = pmod(p.xy, symmetry);
                p.y -= _SymmetryOffset;
                
                // Apply rotation with modified speeds
                float rotSpeedXY = _RotationSpeedXY * rotation;
                float rotSpeedXZ = _RotationSpeedXZ * rotation;
                float rotSpeedZY = _RotationSpeedZY * rotation;
                
                p.xy = mul(rot(time * rotSpeedXY), p.xy);
                p.xz = mul(rot(time * rotSpeedXZ), p.xz);
                
                // Z-modulation
                p.z = fmod(p.z, 8.0) - 4.0;
                
                float3 boxDimensions = _BoxDimensions.xyz * scale;
                float d1 = sdBox(p, boxDimensions);
                
                // Fractal iterations
                for (int i = 0; i < _FractalIterations; i++)
                {
                    p = abs(p) - 1.0;
                    p.xy = mul(rot(time * rotSpeedXY), p.xy);
                    p.xz = mul(rot(time * rotSpeedXZ), p.xz);
                }
                
                d1 = min(d1, sdBox(p, boxDimensions));
                return d1;
            }
            
            float3 genNormal(float3 p)
            {
                float2 d = float2(0.001, 0.0);
                return normalize(float3(
                    map(p + d.xyy) - map(p - d.xyy),
                    map(p + d.yxy) - map(p - d.yxy),
                    map(p + d.yyx) - map(p - d.yyx)
                ));
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Calculate ray origin and direction for raymarch in fragment shader
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.rayOrigin = _WorldSpaceCameraPos;
                o.rayDir = normalize(worldPos - o.rayOrigin);
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                float time = _Time.y * _AnimationSpeed;
                float4 O = float4(0,0,0,1);
                
                // Set up for raymarching
                float3 r = float3(_ScreenParams.x, _ScreenParams.y, 0);
                float3 d = i.rayDir;
                
                // Audio reactive parameters
                float symmetry = _SymmetryCount;
                float scale = 1.0;
                float rotation = 1.0;
                float3 colorMod = _MainColor.rgb;
                
                // Apply audio effects to parameters
                ApplyAudioLink(symmetry, scale, rotation, colorMod);
                
                // Raymarch loop
                float g = 0.0;
                
                for (float i = 0.0; i < _Iterations; i++)
                {
                    float a, s, e;
                    float3 p = g * d * _StepSize;
                    
                    // Apply rotations
                    float rotXZ = time * _RotationSpeedXZ * rotation;
                    float rotXY = time * _RotationSpeedXY * rotation;
                    float rotZY = time * _RotationSpeedZY * rotation;
                    
                    p.xz = mul(rot(rotXZ), p.xz);
                    p.xy = mul(rot(rotXY), p.xy);
                    p.zy = mul(rot(rotZY), p.zy);
                    
                    float normal = map(p);
                    p.z *= _ZModFactor * cos(time);
                    
                    a = _FractalScale + normal;
                    p = fmod(p - a, a * 2.0) - a;
                    s = 3.0;
                    
                    for (int j = 0; j < _FractalIterations; j++)
                    {
                        p = 0.3 - abs(p);
                        
                        // Conditionals converted to smooth operations
                        float3 pzyx = p.zyx;
                        float3 pxzy = p.xzy;
                        
                        p = lerp(p, pzyx, step(p.x, p.z));
                        p = lerp(p, pxzy, step(p.z, p.y));
                        
                        // Animation parameters applied
                        e = _IterationScale + sin(time * _FractalAnimSpeed1) * 0.1;
                        s *= e;
                        
                        // Audio-reactive wave scales
                        float wave1 = _WaveScale1;
                        float wave2 = _WaveScale2;
                        
                        if (_UseAudioLink > 0.5) {
                            wave1 *= 1.0 + GetBass();
                            wave2 *= 1.0 + GetHigh();
                        }
                        
                        p = abs(p) * e - 
                            float3(
                                5.0 + cos(time * _FractalAnimSpeed2 + 0.5 * cos(time * _FractalAnimSpeed2)) * wave1,
                                70.0,
                                4.0 + cos(time * _FractalAnimSpeed3) * wave2
                            ) * normal;
                    }
                    
                    // Advance the ray
                    g += e = length(p.yx) / s;
                    
                    // Color accumulation with audio reactivity
                    float colorCycle = g * _ColorCycleSpeed;
                    if (_UseAudioLink > 0.5) {
                        colorCycle += GetMid() * 0.5;
                    }
                    
                    float pulse = sin(_PulseIntensity);
                    if (_UseAudioLink > 0.5) {
                        pulse += DetectBeat() * 0.5;
                    }
                    
                    // Final color blending
                    float3 baseColor = lerp(float3(1,1,1), hueCos(colorCycle), _ColorBlendAmount);
                    baseColor = lerp(baseColor, colorMod, _ColorVariation);
                    
                    O.xyz += baseColor * pulse * 1.0 / e / 8e3;
                }
                
                // Apply contrast and brightness
                O.xyz = pow(O.xyz * _Brightness, _Contrast);
                
                return O;
            }
            ENDCG
        }
    }
    
    // Custom UI for the shader
    CustomEditor "KaleidoscopeShaderGUI"
} 