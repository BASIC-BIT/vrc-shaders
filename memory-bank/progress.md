# Progress Tracker

*   **What Works:**
    *   **Core Shader Implementation (`eye-shader.shader`):** HLSL code exists for most planned visual features.
    *   **Heart Pupil:** Implemented using texture sampling, size/pulse animation (driven by AudioLink bass/parameters), optional noise, HSV control, parallax.
    *   **Rainbow Iris Rings:** Implemented using gradient texture sampling based on distance, rotation animation, noise distortion, HSV control.
    *   **Iris Detail:** Texture overlay feature implemented with tiling/offset, intensity/contrast control, radial/rotated pattern modes, parallax.
    *   **Limbal Ring:** Implemented with color, width, softness controls, and HSV adjustment.
    *   **Noise Effects:** Implemented using noise texture, tiling/offset, intensity/scale controls, optional dynamic flow distortion.
    *   **Sparkle Effects:** Implemented procedurally using fractal noise, controlled by scale, speed, amount, sharpness, color, and HSV. Audio-reactive intensity via `_IrisSparkleIntensity`.
    *   **Sunburst Streaks:** Implemented using a loop for multiple layers, counter-rotation animation, intensity control, parallax.
    *   **Infinite Mirror:** Implemented using a loop for multiple heart layers, depth scaling, progressive blur (`SampleWithBlur`), parallax per layer.
    *   **Environmental Lighting:** Basic implementation exists to lerp final color based on `UNITY_LIGHTMODEL_AMBIENT`.
    *   **AudioLink Integration:** Shader includes `AudioLink.cginc`, samples filtered audio data (`ALPASS_FILTEREDAUDIOLINK`), and provides fallback logic if AudioLink is unavailable. Reactivity implemented for heart pulse and sparkle intensity.
    *   **Parallax:** View-direction based parallax implemented across multiple features (Heart, Rainbow, Detail, Mirror, Sunburst).
    *   **Feature Toggles:** Extensive use of `#pragma shader_feature_local` allows enabling/disabling most major features.
    *   **Custom Editor GUI (`RainbowHeartburstIrisGUI.cs`):** A comprehensive C# script provides a structured inspector interface with foldouts, manages feature toggles/keywords, and includes helpers for texture properties and HSV controls.
    *   **Top Shading:** Implemented procedural top-down gradient shading using `smoothstep` based on `uv.y`. Includes controls for intensity, height, and softness, integrated into the custom GUI and controlled by `_ENABLE_TOP_SHADING` feature toggle.

*   **What's Left to Build:**
    *   **Screen-Space Effects:** The planned heart-shaped bloom and lens flare extending beyond the eye geometry needs verification and potentially further implementation/refinement. (A `GrabPass` is declared but its usage isn't clear in the main fragment logic; a second pass might be needed as per the architecture doc).
    *   **VRChat Integration:** Setting up VRChat Expression Parameters and corresponding Animator states/animations (likely on FX layer) to control the exposed shader properties via the in-game menu.
    *   **Testing & Refinement:**
        *   Thorough testing within VRChat environments (different lighting, worlds with/without AudioLink).
        *   Performance testing on typical VRChat hardware configurations.
        *   VR compatibility testing (checking parallax, depth effects, potential stereo rendering artifacts).
        *   Visual refinement based on in-game testing.
        *   Testing AudioLink reactivity with diverse audio sources.
        *   Investigating potential transparency sorting issues.
        *   Testing the new Top Shading feature visually and functionally.
        *   Integrating Top Shading controls into VRChat Expression Parameters/Menus.
    *   **Documentation:** Completing the Memory Bank documentation (currently in progress). Creating user-facing documentation (e.g., setup guide, parameter explanations).

*   **Current Status:** The "Rainbow Heartburst Iris" shader is largely feature-complete in terms of its core HLSL implementation and Unity editor interface. The primary remaining tasks involve VRChat-specific integration (Expression Parameters), comprehensive testing, potential refinement of screen-space effects, and final documentation.

*   **Known Issues/Bugs:**
    *   No specific bugs documented, but potential areas identified during research require testing: transparency sorting artifacts, VR stereo rendering issues with parallax/depth, performance bottlenecks (especially loops in fragment shader).
    *   The implementation status of the screen-space flare/bloom needs clarification.

*   **Decision Log:**
    *   Initial design and feature set evolved through discussion (see `eye_shader/docs/eye_shader_chat_log.txt`).
    *   Decision to use HLSL, target Unity Built-in RP for VRChat Av3.
    *   Decision to implement features modularly using `#pragma shader_feature_local`.
    *   Decision to use AudioLink for audio reactivity with fallbacks.
    *   Decision to create a custom `ShaderGUI` for usability.
    *   Specific implementation choices detailed in `eye-shader-architecture.md` (e.g., SDF for heart concept, though texture sampling seems to be the final implementation in `.shader`).
    *   Decision to use procedural gradient for Top Shading feature (vs. texture mask).

*(This file tracks the project's journey, what's done, what's next, and any hurdles. Update alongside activeContext.md.)*