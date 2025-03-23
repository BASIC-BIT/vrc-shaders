# Rainbow Heartburst Iris Shader Architecture

## Overview
This shader creates a vibrant eye effect with a heart-shaped pupil, rainbow concentric rings, infinite mirror depth effect, animated sunburst streaks, and audio reactivity through AudioLink.

## Core Structure
```hlsl
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
        
        // Main pass
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            
            // Implementation details following...
        }
        
        // Optional lens flare pass with additive blending 
        Pass {
            Blend One One // Additive blending for glow effects
            // Lens flare implementation
        }
    }
}
```

## Feature Implementation

### 1. Heart-Shaped Pupil
- Use signed distance field (SDF) heart function
- Control size and pulse based on AudioLink bass frequency
- Apply smoothing to prevent visual jitter

```hlsl
// SDF heart function
float heartSDF(float2 uv, float size) {
    uv = (uv - 0.5) * 2.0; // Center and scale
    float2 q = float2(abs(uv.x), uv.y);
    float d = length(q - float2(0.25, -0.3)) - 0.5;
    return d * (1.0/size); // Negative inside heart, positive outside
}

// In fragment shader
float pulseSize = 1.0 + _HeartPulseIntensity * AudioLinkData(ALPASS_FILTEREDBASS).r * 0.2;
float heartDistance = heartSDF(i.uv, pulseSize);
float heartMask = smoothstep(0.01, -0.01, heartDistance);
```

### 2. Rainbow Iris Rings
- Generate concentric rings based on distance from center
- Sample rainbow gradient texture with rotation animation
- Apply AudioLink-reactive sparkle effect

```hlsl
// In fragment shader:
float2 centeredUV = i.uv - 0.5;
float dist = length(centeredUV);
float ringCount = 8.0;
float ringIndex = frac(dist * ringCount);

// Rotation over time
float angle = atan2(centeredUV.y, centeredUV.x);
float rotationSpeed = _Time.y * _RingRotationSpeed;
float rotatedAngle = angle + rotationSpeed;

// Sample rainbow gradient
float2 rainbowUV = float2(ringIndex, 0.5);
fixed4 rainbowColor = tex2D(_RainbowGradientTex, rainbowUV);

// Audio-reactive sparkle
float sparkle = tex2D(_NoiseTexture, i.uv * 5.0 + _Time.y).r;
float sparkleIntensity = _IrisSparkleIntensity * AudioLinkData(ALPASS_FILTEREDHIGHMIDS).r;
rainbowColor += sparkle * sparkleIntensity;
```

### 3. Infinite Mirror Depth Effect
- Create layered heart shapes receding into depth
- Apply progressive blur to deeper layers
- Implement using multiple samples at different scales

```hlsl
// Initialize accumulation variables
float4 mirrorColor = float4(0,0,0,0);
float totalWeight = 0;

// Loop through multiple depth layers
for (int i = 0; i < 5; i++) {
    float depth = 1.0 - (i / 5.0) * _InfiniteDepthStrength;
    float2 scaledUV = (i.uv - 0.5) * depth + 0.5;
    
    // Heart mask for this layer
    float layerHeartDist = heartSDF(scaledUV, pulseSize);
    float layerMask = smoothstep(0.01, -0.01, layerHeartDist);
    
    // Calculate blur based on depth
    float blurAmount = i * _InfiniteBlurStrength * 0.05;
    float4 layerColor = SampleWithBlur(_RainbowGradientTex, scaledUV, blurAmount);
    
    // Accumulate with depth-based weight
    float weight = exp(-i * 0.5);
    mirrorColor += layerColor * layerMask * weight;
    totalWeight += weight * layerMask;
}

mirrorColor = totalWeight > 0 ? mirrorColor / totalWeight : mirrorColor;
```

### 4. Animated Parallax Sunburst Streaks
- Generate radial streaks from center
- Apply counter-rotation to multiple layers
- Use view-direction-based UV offsets for parallax

```hlsl
float4 sunburstColor = float4(0,0,0,0);

// Loop through sunburst layers
for (int j = 0; j < _SunburstLayerCount; j++) {
    // Different rotation speed for each layer
    float layerRotation = _Time.y * _SunburstRotationSpeed * (j % 2 == 0 ? 1 : -1);
    
    // Parallax offset based on view direction
    float parallaxAmount = 0.02 * (j+1) / _SunburstLayerCount;
    float2 parallaxOffset = i.viewDir.xy * parallaxAmount;
    float2 sunburstUV = i.uv + parallaxOffset;
    
    // Rotate UVs
    float2 rotatedUV = RotateUV(sunburstUV - 0.5, layerRotation) + 0.5;
    
    // Create radial streaks
    float angle = atan2(rotatedUV.y-0.5, rotatedUV.x-0.5);
    float streakMask = (sin(angle * 20.0) * 0.5 + 0.5);
    streakMask = pow(streakMask, 5.0) * exp(-length(rotatedUV - 0.5) * 5.0);
    
    // Add to final color
    sunburstColor += streakMask * 0.2;
}
```

### 5. Screen-Space Lens Flare and Glow
- Calculate emission based on pupil and streak intensity
- Apply screen-space bloom and soft flare

```hlsl
// In second pass (additive blending)
float emissionStrength = 0;

// Calculate emission from pupil
float heartGlow = (1.0 - heartMask) * 0.8;
emissionStrength += heartGlow;

// Add audio-reactive flare boost
float audioBoost = saturate((AudioLinkData(ALPASS_FILTEREDBASS).r - _FlareIntensityThreshold) / (1.0 - _FlareIntensityThreshold));
emissionStrength *= 1.0 + audioBoost * 2.0;

// Apply directional flare
float2 flareDir = normalize(i.uv - 0.5);
float flareStrength = pow(1.0 - length(i.uv - 0.5), 3.0) * audioBoost;
float4 flareColor = SampleWithBlur(_RainbowGradientTex, i.uv + flareDir * 0.1, 0.1) * flareStrength;

return fixed4(emissionStrength * _HeartPupilColor.rgb + flareColor.rgb, 0);
```

### 6. Environmental Lighting Reaction
- Sample ambient light and blend with shader colors

```hlsl
// Apply environmental lighting influence
fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
fixed3 environmentAdjustedColor = lerp(rainbowColor.rgb, rainbowColor.rgb * ambientLight * 2.0, _EnvironmentLightingAmount);
```

## AudioLink Integration
```hlsl
// Check if AudioLink is available
float audioLinkAvailable = AudioLinkIsAvailable();
if (!audioLinkAvailable) {
    // Fallback behavior when AudioLink isn't present
    bass = 0.5 + sin(_Time.y) * 0.1; // Simple animation fallback
}

// Get filtered audio data to avoid jitter
float4 audioData = AudioLinkData(ALPASS_FILTEREDAUDIOLINK);
float bass = audioData.r;
float lowMid = audioData.g;
float highMid = audioData.b;
float treble = audioData.a;

// Additional audio patterns available
float4 audioPattern = AudioLinkLerp(ALPASS_CCSTRIP + float2(frac(_Time.y * 0.1) * 128., 0));
```

## VRChat Expression Parameter Setup
```hlsl
// These are the properties that should be controlled via animation in Unity:
// _HeartPulseIntensity
// _RingRotationSpeed
// _IrisSparkleIntensity
// _InfiniteDepthStrength
// _InfiniteBlurStrength
// _SunburstLayerCount
// _SunburstRotationSpeed
// _FlareIntensityThreshold
// _EnvironmentLightingAmount
```

## Performance Considerations
- Limit loop iterations in infinite mirror and sunburst calculations
- Use pre-computed noise textures instead of procedural generation
- Add early-out checks for invisible areas
- Implement fallbacks for AudioLink to ensure shader works without it
- Keep shader complexity reasonable for VRChat performance

## Stereo/VR Considerations
- Ensure parallax and view-dependent effects work correctly in stereo rendering
- Avoid screen-space effects that don't account for stereo cameras
- Test in VR to validate 3D depth perception of layered effects 