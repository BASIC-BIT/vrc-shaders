# Audio-Reactive Kaleidoscopic Fractal Shader for VRChat

This shader converts a ShaderToy GLSL volumetric fractal into a highly customizable, audio-reactive kaleidoscopic effect for VRChat worlds using Unity's built-in render pipeline.

![AudioReactiveKaleidoscope](https://i.imgur.com/example.jpg)
*(Replace with an actual screenshot of your shader)*

## Features

- **Fully converted from ShaderToy** - Complete conversion from GLSL to HLSL for Unity's built-in render pipeline
- **AudioLink integration** - Dynamic audio reactivity through VRChat's AudioLink system
- **Extensive customization** - Over 30 adjustable parameters with intuitive UI
- **Ray marching optimization** - Carefully optimized for VR performance
- **Preset system** - Multiple included presets for quick visual styles

## Installation

1. Ensure you have the [AudioLink](https://github.com/llealloo/vrc-udon-audio-link) package already imported in your VRChat world project
2. Import these shader files into your Unity project:
   - `Kaleidoscope.shader` - The main shader file
   - `AudioLinkIntegration.cginc` - Helper functions for AudioLink
   - `KaleidoscopeShaderGUI.cs` - Custom inspector UI (place in an Editor folder)
3. Create a material with the "Custom/AudioReactiveKaleidoscope" shader
4. Apply the material to a quad, skybox, or any other appropriate mesh in your world

## Usage

This shader works best when applied to:
- A full-screen quad as a background element
- A skybox for an immersive environment
- A sphere with inverted normals surrounding the player

For optimal performance, adjust the Ray March Iterations parameter based on your target platform.

### Shader Controls

The shader includes an extensive set of parameters organized in collapsible sections:

#### Base Settings
- **Main Color** - Base color tint
- **Color Variation** - Amount of color variation applied
- **Brightness** - Overall brightness multiplier
- **Contrast** - Final output contrast adjustment

#### Rotation
- **XY/XZ/ZY Rotation Speed** - Individual rotation speeds for each plane

#### Fractal Structure
- **Symmetry Count** - Number of kaleidoscopic repetitions
- **Symmetry Offset** - Offset applied to the symmetry
- **Fractal Iterations** - Recursive iteration depth
- **Iteration Scale** - Scale change per iteration
- **Box Dimensions** - Size of the base box primitives
- **Z Modulation Factor** - Z-axis distortion amount

#### Ray Marching
- **Ray March Iterations** - Maximum number of raymarching steps (performance critical)
- **Step Size** - Size of each ray step (smaller = better quality but slower)
- **Fractal Scale** - Overall scale of the fractal

#### Animation
- **Animation Speed** - Global time multiplier
- **Fractal Animation Speed 1/2/3** - Different animation frequencies
- **Wave Scale 1/2** - Amplitude of internal wave effects

#### AudioLink
- **Use AudioLink** - Toggle audio reactivity
- **Bass/Mid/High Intensity** - Sensitivity to different frequency ranges
- **Beat Multiplier** - Intensity of beat detection response
- **Effect Mapping** - Assign which audio band affects which parameter:
  - None - No effect
  - Symmetry - Modifies kaleidoscope symmetry count
  - Scale - Changes overall size
  - Rotation - Speeds up/slows rotation
  - Color - Applies color tinting

#### Color Effects
- **Color Cycle Speed** - Rate of color cycling through the spectrum
- **Pulse Intensity** - Visual pulsing strength
- **Color Blend Amount** - Blend factor between base and generated colors

## AudioLink Integration

The shader reacts to audio through VRChat's AudioLink system with multiple integration points:

1. **Frequency Band Mapping**
   - Bass frequencies (0-8 range in AudioLink) can affect symmetry, scale, rotation, or color
   - Mid frequencies (16-32 range) with customizable effect assignment
   - High frequencies (48-64 range) with customizable effect assignment

2. **Beat Detection**
   - Detects beats in the music for punctuated visual effects
   - Adjustable threshold and multiplier

3. **Frequency Visualization**
   - Color cycling speed can be modulated by mid frequencies
   - Wave amplitudes can expand with bass and high frequencies

For AudioLink to work, ensure an AudioLink prefab is present and active in your VRChat world.

## Presets

The shader includes several presets that can be applied via the custom inspector:

- **Psychedelic** - Vibrant colors with rapid rotation and high color cycling
- **Cosmic** - Deep space-like effect with slower movement and blue tones
- **Subtle Beat** - Gentle response focused on beat detection
- **Aggressive** - High-contrast, fast-moving with strong audio response

## Performance Considerations

This shader uses ray marching, which is performance-intensive. To optimize:

1. Reduce **Ray March Iterations** (default: 110, can go as low as 40-60 for decent quality)
2. Increase **Step Size** (larger steps = fewer calculations)
3. Lower **Fractal Iterations** for simpler geometry
4. Avoid applying to many objects simultaneously

Expect 1-3ms render time on modern GPUs, which is acceptable for VRChat worlds when used appropriately.

## Credits

- Original ShaderToy implementation by [original author]
- GLSL to HLSL conversion and AudioLink integration by [your name]
- Based on research from [kaleidoscope/docs/research.md](/kaleidoscope/docs/research.md)
- AudioLink ideas from [kaleidoscope/docs/audiolink_ideas.md](/kaleidoscope/docs/audiolink_ideas.md)

## License

[Include your license information here] 