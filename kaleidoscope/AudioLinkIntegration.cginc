// AudioLinkIntegration.cginc
// Helper functions and utilities for integrating AudioLink into shaders

// AudioLink texture declaration
sampler2D _AudioTexture;

// AudioLink data access function
// xy: x=frequency bin (0-127), y=row (typically 0-7)
float4 AudioLinkData(int2 xy)
{
    return tex2Dlod(_AudioTexture, float4((xy + 0.5) / float2(128, 64), 0, 0));
}

// Sample specific bands - returns amplitude in 0-1 range
float GetBassAmplitude(float intensity)
{
    // Averages bins 0-8 for the bass range
    float bassSum = 0.0;
    for (int i = 0; i < 8; i++) {
        bassSum += AudioLinkData(int2(i, 0)).r;
    }
    return (bassSum / 8.0) * intensity;
}

float GetMidAmplitude(float intensity)
{
    // Averages bins 16-32 for mid range
    float midSum = 0.0;
    for (int i = 16; i < 32; i++) {
        midSum += AudioLinkData(int2(i, 0)).r;
    }
    return (midSum / 16.0) * intensity;
}

float GetHighAmplitude(float intensity)
{
    // Averages bins 48-64 for high range
    float highSum = 0.0;
    for (int i = 48; i < 64; i++) {
        highSum += AudioLinkData(int2(i, 0)).r;
    }
    return (highSum / 16.0) * intensity;
}

// History sampling for smoother reactivity
float GetSmoothedBass(float intensity, float smoothing)
{
    float currentBass = GetBassAmplitude(intensity);
    float historicalBass = AudioLinkData(int2(0, 1)).r * intensity; // Row 1 often contains history
    return lerp(currentBass, historicalBass, smoothing);
}

// Beat detection
float DetectBeat(float threshold, float multiplier)
{
    float bass = GetBassAmplitude(1.0);
    float bassHistory = AudioLinkData(int2(0, 1)).r;
    
    // Beat is detected when current bass exceeds history by threshold amount
    float beatIntensity = max(0, bass - bassHistory - threshold);
    return beatIntensity * multiplier;
}

// Visual pulse that reacts to beats
float BeatPulse(float threshold, float frequency, float decay)
{
    float beatValue = DetectBeat(threshold, 1.0);
    float timePulse = sin(_Time.y * frequency) * 0.5 + 0.5;
    
    // Combine for a pulse that's stronger on beats but continues with rhythm
    return max(beatValue, timePulse * decay);
}

// Color modulation based on audio frequencies
float3 AudioReactiveColor(float3 baseColor, float audioValue, float3 targetColor, float blendAmount)
{
    return lerp(baseColor, targetColor * audioValue, blendAmount * audioValue);
}

// Frequency-based hue shift
float AudioReactiveHueShift(float baseHue, float bassIntensity, float midIntensity, float highIntensity)
{
    float bassShift = GetBassAmplitude(1.0) * bassIntensity;
    float midShift = GetMidAmplitude(1.0) * midIntensity;
    float highShift = GetHighAmplitude(1.0) * highIntensity;
    
    return frac(baseHue + bassShift + midShift + highShift);
}

// Apply audio-reactive deformation to position
float3 AudioReactiveDeformation(float3 position, float bassIntensity, float midIntensity, float highIntensity)
{
    float3 deformedPos = position;
    
    // Bass affects overall scale
    float bassEffect = GetBassAmplitude(bassIntensity);
    deformedPos *= 1.0 + bassEffect * 0.2;
    
    // Mid frequencies create wave distortion
    float midEffect = GetMidAmplitude(midIntensity);
    deformedPos.xy += sin(deformedPos.z * 2.0) * midEffect * 0.1;
    
    // High frequencies add noise
    float highEffect = GetHighAmplitude(highIntensity);
    float noise = sin(deformedPos.x * 10.0) * sin(deformedPos.y * 10.0) * sin(deformedPos.z * 10.0);
    deformedPos += noise * highEffect * 0.05;
    
    return deformedPos;
}

// VU meter visualization helper (horizontal bar)
float VUMeter(float2 uv, float audioLevel, float4 color)
{
    float bar = step(uv.x, audioLevel) * step(uv.y, 0.05) * step(0, uv.y);
    return bar * color;
}

// Spectrum visualization helper (vertical bars)
float SpectrumBar(float2 uv, int band, float maxBands, float height)
{
    float bandWidth = 1.0 / maxBands;
    float bandStart = band * bandWidth;
    float level = AudioLinkData(int2(band * (128/maxBands), 0)).r * height;
    
    return step(bandStart, uv.x) * step(uv.x, bandStart + bandWidth * 0.8) * step(uv.y, level);
} 