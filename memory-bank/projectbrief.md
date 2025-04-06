# Project Brief

*   **Project Name:** VRC-shaders (Current focus: Rainbow Heartburst Iris)
*   **Core Goal:** Create a visually stunning, cute, and dynamic eye shader ("Rainbow Heartburst Iris") for VRChat avatars, featuring unique animated effects, depth, and audio reactivity.
*   **Key Features/Requirements:**
    *   **Heart Pupil:** Animated, audio-reactive (bass pulse), customizable color.
    *   **Rainbow Iris Rings:** Concentric, animated rotation, audio-reactive sparkle/brightness (mid/high frequencies).
    *   **Infinite Mirror:** Heart-shaped layers receding into depth, progressive blur.
    *   **Sunburst Streaks:** Animated, multi-layered, counter-rotating, parallax effect.
    *   **Screen-Space Effects:** Heart-shaped bloom and lens flare extending beyond the eye, audio-reactive intensity.
    *   **AudioLink Integration:** Reactivity to bass, low-mid, high-mid, and treble frequencies using filtered data for smoothness.
    *   **Environmental Lighting:** Optional reaction to world light color/intensity via animatable parameter.
    *   **Top Shading:** Procedural gradient shading from the top edge to simulate shadows, customizable intensity/height/softness.
    *   **Customization:** Control key parameters via VRChat Expression Parameters/Menus.
    *   **Platform:** VRChat Avatars 3.0, Unity Built-in Render Pipeline.
    *   **Language:** HLSL for shader code, C# for custom editor GUI (`RainbowHeartburstIrisGUI.cs`).
    *   **Performance:** Target PC VRChat avatars; Quest compatibility is a secondary consideration (AudioLink limitations on Quest).
*   **Target Audience:** VRChat avatar creators and users seeking expressive, cute, and dynamic eye shaders.
*   **Scope:** Initial focus is the implementation and documentation of the "Rainbow Heartburst Iris" shader. Excludes vertex displacement techniques. Includes development of a custom Unity editor GUI for ease of use.

*(This is the foundational document. Fill this out first to guide the rest of the Memory Bank.)*