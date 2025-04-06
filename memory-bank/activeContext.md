# Active Context

*   **Current Focus:** Implementing and documenting a new "Top Shading" feature (procedural gradient) for the "Rainbow Heartburst Iris" shader.
*   **Recent Changes:**
    *   Initialized the core Memory Bank files (`projectbrief.md`, `productContext.md`, `activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`).
    *   Updated `projectbrief.md` and `productContext.md` with details about the "Rainbow Heartburst Iris" shader.
    *   Added procedural top-down gradient shading feature:
        *   Added properties (`_EnableTopShading`, `_TopShadingIntensity`, `_TopShadingHeight`, `_TopShadingSoftness`) to `eye-shader.shader`.
        *   Added `#pragma shader_feature_local _ENABLE_TOP_SHADING`.
        *   Added uniform variable declarations in HLSL.
        *   Added fragment shader logic using `smoothstep` based on `uv.y` to calculate and apply shading factor.
        *   Added corresponding properties and UI drawing logic to `RainbowHeartburstIrisGUI.cs`.
    *   Updated `projectbrief.md` to include the new feature.
    *   Prior to Memory Bank initialization: Development of the "Rainbow Heartburst Iris" shader, including HLSL code, C# GUI, and architecture documentation.
*   **Next Steps:**
    *   Update `systemPatterns.md` with details about the new top shading feature.
    *   Update `progress.md` to reflect the addition and status of the top shading feature.
    *   Test the new top shading feature in Unity Editor.
    *   Consider VRChat integration (Expression Parameters) for the new shading controls.
    *   Review all updated Memory Bank files for consistency.
*   **Active Decisions/Considerations:**
    *   Ensuring the Memory Bank accurately reflects the implemented features and design decisions of the "Rainbow Heartburst Iris" shader.
    *   Decision made to use a procedural gradient (based on `uv.y` and `smoothstep`) for the top shading feature, rather than a texture mask or vertex colors.
    *   Considering potential future steps after documentation, such as performance testing in VRChat, VR compatibility checks, or further feature refinement based on testing.
*   **Key Patterns/Preferences:**
    *   Use of HLSL within Unity's ShaderLab structure.
    *   Integration with AudioLink using `AudioLink.cginc` and filtered data streams (e.g., `ALPASS_FILTEREDAUDIOLINK`).
    *   Extensive use of shader properties exposed to the Unity Inspector and controlled via a custom C# `ShaderGUI` (`RainbowHeartburstIrisGUI.cs`).
    *   Use of `#pragma shader_feature_local` for toggling features efficiently.
    *   Implementation of effects like parallax (using view direction), noise (using textures and fractal functions), HSV color adjustments, and layered effects (infinite mirror, sunburst).
    *   Use of `smoothstep` for creating adjustable gradients based on UV coordinates (newly added for top shading).
    *   Emphasis on a "cute," "dreamy," dynamic but not overly distracting aesthetic.
*   **Learnings/Insights:**
    *   The design process involved iterative refinement based on user feedback (documented in `eye_shader/docs/eye_shader_chat_log.txt`).
    *   Research highlighted potential challenges with transparency sorting, VR compatibility (stereo rendering), and performance in VRChat, which should be kept in mind during testing/refinement.
    *   The importance of using filtered AudioLink data for smooth visual effects was noted.
    *   VRChat Expression Parameters are the intended method for user control of shader properties in-game.

*(This file is crucial for tracking the current state of work. Update it frequently, especially before ending a session or switching tasks.)*