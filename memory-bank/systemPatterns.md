# System Patterns

*   **Overall Architecture:**
    *   **Shader Type:** Single "uber shader" (`Custom/RainbowHeartburstIris`) implemented using Unity's ShaderLab syntax with HLSL code within `CGPROGRAM` blocks.
    *   **Rendering:** Designed for transparent rendering (`Queue=Transparent+1`, `Blend SrcAlpha OneMinusSrcAlpha`, `ZWrite Off`, `Cull Back`). Applied to a single circular iris mesh.
    *   **Modularity:** Features are modularized using `#pragma shader_feature_local` directives (e.g., `_ENABLE_HEART`, `_ENABLE_RAINBOW`, `_ENABLE_MIRROR`), allowing features to be toggled on/off, which compiles different shader variants for performance.
    *   **Passes:** Primarily uses a single main pass for rendering the iris, pupil, and most effects. A `GrabPass` is declared, potentially for refraction or distortion effects (though not explicitly used in the main fragment logic provided). The architecture document mentions an optional second pass for additive lens flare/glow, but this isn't fully detailed in the provided `.shader` structure.
    *   **Editor Integration:** Uses a custom C# editor script (`CustomEditor "RainbowHeartburstIrisGUI"`) to provide a user-friendly interface in the Unity Inspector.

*   **Key Technical Decisions:**
    *   **Audio Reactivity:** Leverages AudioLink (`AudioLink.cginc`) to drive animations based on filtered audio frequency bands (bass, low-mid, high-mid, treble). Fallback behavior (simple sine wave animation) is implemented for when AudioLink is unavailable.
    *   **Procedural Effects:** Core visual elements like rainbow rings, sunburst streaks, noise patterns, and sparkles are generated procedurally within the shader using mathematical functions (distance, atan2, sin, noise functions) and texture sampling (gradients, noise maps).
    *   **Layered Depth:** Infinite mirror and sunburst effects are created using loops (`for`) in the fragment shader to render multiple layers with varying properties (scale, blur, rotation, parallax), accumulated additively or via weighted averages.
    *   **Parallax:** View-dependent parallax effects are implemented across multiple features (heart, rainbow, detail, mirror, sunburst) by offsetting UV coordinates based on the view direction vector (`i.viewDir`).
    *   **Feature Toggles:** Extensive use of `#pragma shader_feature_local` allows users to enable/disable specific visual components (heart, rainbow, noise, sunburst, mirror, etc.), optimizing performance by excluding unused code from compiled variants.
    *   **Custom GUI:** A dedicated C# `ShaderGUI` script enhances usability by organizing shader properties into logical foldout sections and managing shader keyword toggles automatically.
    *   **Color Control:** HSV adjustments (Hue, Saturation, Brightness) are provided for major color elements via helper functions, offering flexible color customization.
    *   **Texture Usage:** Uses textures for gradients (`_RainbowGradientTex`), noise patterns (`_NoiseTexture`), iris detail (`_IrisTexture`), and the heart shape/detail (`_HeartTexture`).

*   **Design Patterns:**
    *   **Uber Shader:** Consolidates multiple effects into one shader file, controlled by properties and feature toggles.
    *   **Custom Editor (C# `ShaderGUI`):** Provides a structured and intuitive interface for tweaking shader parameters in Unity, improving user experience over the default inspector. Manages shader keyword state based on toggles.
    *   **Procedural Generation:** Employs mathematical formulas and noise functions to create complex visual patterns (rings, streaks, sparkles) dynamically.
    *   **Layered Rendering (Loops):** Builds complex effects like the infinite mirror and sunbursts by iterating in the fragment shader, accumulating results from multiple calculated layers.
    *   **Parallax Mapping (Simple):** Uses view direction to offset UVs, creating an illusion of depth on a flat surface.
    *   **Audio-Reactive Design:** Maps specific AudioLink data streams (filtered bands) to visual parameters (scale, intensity, speed) for synchronized effects.
    *   **Helper Functions:** Encapsulates common calculations (UV rotation, HSV conversion, noise generation, blurring) into reusable HLSL functions.
    *   **Fallback Behavior:** Includes checks (`AudioLinkIsAvailable()`) and alternative logic for when dependencies like AudioLink are not present.

*   **Component Relationships:**
    *   Shader properties (`Properties` block) define the user-configurable parameters.
    *   Uniform variables in HLSL receive values from these properties.
    *   The `RainbowHeartburstIrisGUI.cs` script reads and writes these properties and manages the corresponding `#pragma shader_feature_local` keywords.
    *   AudioLink provides the `_AudioLink` texture, sampled by the shader to drive animations.
    *   View direction (`i.viewDir`) is a key input for all parallax calculations.
    *   Noise functions and the `_NoiseTexture` influence the appearance of the heart, iris rings, and sunbursts.
    *   The final pixel color is a composite result of blending the outputs of various feature calculations (rainbow, detail, mirror, sunburst, sparkle, limbal ring, heart) in a specific order.

*   **Critical Implementation Paths:**
    *   **Infinite Mirror Loop:** The fragment shader loop calculating the layered heart mirror effect, involving UV scaling, parallax offset per layer, conditional blurring (`SampleWithBlur`), masking, and weighted color accumulation. Performance is sensitive to `_InfiniteLayerCount`.
    *   **Sunburst Streak Loop:** The loop generating multi-layered, rotating, parallaxing streaks, using trigonometric functions and potentially noise. Performance depends on `_SunburstLayerCount`.
    *   **AudioLink Integration:** Correctly sampling the `_AudioLink` texture at appropriate coordinates (e.g., `ALPASS_FILTEREDAUDIOLINK`) and applying the data smoothly to visual parameters.
    *   **Parallax Calculations:** Ensuring view-direction based UV offsets are correctly calculated and applied consistently across features, especially for VR stereo rendering.
    *   **Effect Blending:** The final composition stage in the fragment shader where all calculated effects (base iris, mirror, streaks, sparkles, limbal ring, heart) are combined using appropriate blending logic (lerp, addition) to achieve the desired visual layering.
    *   **Shader Feature Management:** Correctly defining `#pragma shader_feature_local` directives and ensuring the `ShaderGUI` script enables/disables the corresponding keywords accurately.

*(This file documents the technical design and structure. Refer to projectbrief.md and techContext.md.)*