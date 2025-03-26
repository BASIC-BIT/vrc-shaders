Shader "Unlit/Audio LSD Shader V3"
{
    Properties
    {
        _SymmetryX ("Symmetry X", Range(1, 10)) = 3
        _SymmetryY ("Symmetry Y", Range(1, 10)) = 3
        _SymmetryZ ("Symmetry Z", Range(1, 10)) = 3
        _SymmetryTwist ("Symmetry Twist", Range(0, 1)) = 0.1
        _Folds ("Rotational Folds", Range(1, 12)) = 6
        _BoxSize ("Box Size", Vector) = (0.5, 0.5, 0.5, 0)
        _BoxPos ("Box Position", Vector) = (1, 0, 0, 0)
        _SphereRadius ("Sphere Radius", Range(0.1, 1)) = 0.3
        _ReflectionStrength ("Reflection Strength", Range(0, 1)) = 1
        _LayerDensity ("Layer Density", Range(1, 20)) = 5
        _BaseThickness ("Base Thickness", Range(0.01, 0.5)) = 0.1
        _ThicknessAudioInfluence ("Thickness Audio Influence", Range(0, 0.5)) = 0.05
        _Sigma ("Density Falloff", Range(0.01, 1)) = 0.1
        _DensityAudioInfluence ("Density Audio Influence", Range(0, 5)) = 1
        _Height ("Fog Height", Range(0, 5)) = 1
        _StepSize ("Step Size", Range(0.01, 0.5)) = 0.1
        _MaxSteps ("Max Steps", Range(10, 200)) = 100
        _MaxDistance ("Max Distance", Range(1, 50)) = 10
        _ColorSpectrum ("Color Spectrum", 2D) = "white" {}
        _ColorSpeed ("Color Speed", Range(0, 10)) = 1
        _ColorIntensity ("Color Intensity", Range(0, 2)) = 1
        _AudioColorInfluence ("Audio Color Influence", Range(0, 5)) = 1
        _LayerColorVariation ("Layer Color Variation", Range(0, 1)) = 0.5
        _HighColorShift ("High Freq Color Shift", Range(0, 1)) = 0.2
        _AudioBassInfluence ("Bass Influence", Range(0, 5)) = 1
        _AudioMidInfluence ("Mid Influence", Range(0, 5)) = 1
        _AudioHighInfluence ("High Influence", Range(0, 5)) = 1
        _ScaleAudioInfluence ("Scale Audio Influence", Range(0, 1)) = 0.2
        _BoxSizeScaleAudioInfluence ("Box Size Audio Scale", Range(0, 1)) = 0.1
        _SphereRadiusScaleAudioInfluence ("Sphere Radius Audio Scale", Range(0, 1)) = 0.1
        _VibrationScale ("Vibration Scale", Range(0, 1)) = 0.2
        _PulseFrequency ("Pulse Frequency", Range(0, 5)) = 1
        _AlphaDepthFactor ("Alpha Depth Factor", Range(0, 1)) = 0.2
        _AlphaOscillation ("Alpha Oscillation", Range(0, 10)) = 2
        _DepthColorShift ("Depth Color Shift", Range(0, 1)) = 0.1
        _DebugMode ("Debug Mode", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

            // If you are using the newer HLSL approach via AudioLink.cginc, these are likely declared there:
            // Texture2DArray _AudioTexture;
             SamplerState sampler_AudioTexture;

            sampler2D _ColorSpectrum;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            float _SymmetryX, _SymmetryY, _SymmetryZ, _SymmetryTwist, _Folds;
            float3 _BoxSize, _BoxPos;
            float _SphereRadius, _ReflectionStrength;
            float _LayerDensity, _BaseThickness, _ThicknessAudioInfluence, _LayerColorVariation;
            float _Sigma, _DensityAudioInfluence, _Height, _StepSize;
            float _ColorSpeed, _ColorIntensity, _AudioColorInfluence;
            float _AudioBassInfluence, _AudioMidInfluence, _AudioHighInfluence;
            float _AlphaDepthFactor, _AlphaOscillation, _DepthColorShift;
            float _VibrationScale, _PulseFrequency, _ScaleAudioInfluence, _DebugMode;
            float _MaxDistance, _BoxSizeScaleAudioInfluence, _SphereRadiusScaleAudioInfluence;
            int _MaxSteps;
            float _HighColorShift;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            float3 rotateY(float3 p, float angle)
            {
                float c = cos(angle), s = sin(angle);
                return float3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
            }

            float sdBox(float3 p, float3 b)
            {
                float3 d = abs(p) - b;
                return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
            }

            float sdSphere(float3 p, float r)
            {
                return length(p) - r;
            }

            float3 applyAdvancedSymmetry(float3 p)
            {
                p.x = frac(p.x * _SymmetryX) - 0.5;
                p.y = frac(p.y * _SymmetryY) - 0.5;
                p.z = frac(p.z * _SymmetryZ) - 0.5;
                // Note: rotating by p.z * _SymmetryTwist is somewhat unusual,
                // but we'll keep the original logic.
                p.xy = rotateY(p, p.z * _SymmetryTwist).xy;
                return p;
            }

            float sdUltraKaleidoscope(float3 p, float time, float bass, float mid, float high)
            {
                // Apply some vibration/pulse effects:
                p += sin(p * _LayerDensity + time * _PulseFrequency) * (bass + mid + high) * _VibrationScale;
                // Scale the space slightly by bass:
                p = p / (1 + bass * _ScaleAudioInfluence);

                p = applyAdvancedSymmetry(p);

                float angle = 2 * 3.1415926535 / _Folds;
                float minD = 1e10;

                // Scale the box size and sphere radius by audio:
                float3 boxSize = _BoxSize * (1 + bass * _BoxSizeScaleAudioInfluence);
                float sphereRadius = _SphereRadius * (1 + high * _SphereRadiusScaleAudioInfluence);

                // First set of box folds
                for (int k = 0; k < _Folds; k++)
                {
                    float3 rotatedP = rotateY(p, k * angle);
                    float d = sdBox(rotatedP - _BoxPos, boxSize);
                    minD = min(minD, d);
                }

                // Reflection pass with mirrored z
                float3 reflectedP = float3(p.x, p.y, -p.z);
                for (int j = 0; j < _Folds; j++)
                {
                    float3 rotatedP = rotateY(reflectedP, j * angle);
                    float d = sdBox(rotatedP - _BoxPos, boxSize);
                    minD = min(minD, d * _ReflectionStrength);
                }

                // Sphere
                float d_sphere = sdSphere(p, sphereRadius);
                minD = min(minD, d_sphere);

                // Thickness (like a shell) based on bass
                float thickness = _BaseThickness + bass * _ThicknessAudioInfluence;
                return minD - thickness;
            }

            float4 raymarch(float3 ro, float3 rd, float bass, float mid, float high)
            {
                float t = 0.0;
                float4 finalColor = float4(0, 0, 0, 0);
                float time = _Time.y;
                int stepCount = 0;

                [unroll(200)] while (stepCount < _MaxSteps && t < _MaxDistance)
                {
                    float3 p = ro + rd * t;
                    float d = sdUltraKaleidoscope(p, time, bass, mid, high);

                    // Adjust density
                    float density = exp(-d * d / _Sigma) * (1 + bass * _DensityAudioInfluence);

                    // Fog by height
                    density *= smoothstep(0, _Height, p.y);

                    // Color index from angle
                    float angle = atan2(p.z, p.x) / (2 * 3.1415926535);
                    angle += time * _ColorSpeed + bass * _AudioColorInfluence + mid * 0.5 + high * _HighColorShift;

                    // Sample color spectrum
                    float4 col = tex2D(_ColorSpectrum, float2(frac(angle), 0.5));
                    col.rgb *= _ColorIntensity;

                    // Contribute to final color
                    float4 contrib = col * density * _StepSize;
                    finalColor += contrib * (1 - finalColor.a);

                    if (finalColor.a > 0.99) break;

                    t += _StepSize;
                    stepCount += 1;
                }

                // Debug mode visualization
                if (_DebugMode > 0.5)
                {
                    return float4(0, stepCount / _MaxSteps, 0, 1);
                }

                return finalColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample AudioLink texture with SampleLevel (LOD=0)
                float bass = _AudioTexture.SampleLevel(sampler_AudioTexture, float2(0.0, 0.0), 0).r * _AudioBassInfluence;
                float mid  = _AudioTexture.SampleLevel(sampler_AudioTexture, float2(0.25, 0.0), 0).r * _AudioMidInfluence;
                float high = _AudioTexture.SampleLevel(sampler_AudioTexture, float2(0.5, 0.0), 0).r * _AudioHighInfluence;

                float3 ro = _WorldSpaceCameraPos;
                float3 rd = normalize(i.worldPos - ro);

                return raymarch(ro, rd, bass, mid, high);
            }
            ENDCG
        }
    }
}
