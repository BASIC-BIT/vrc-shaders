# Active Context

*   **Current Focus:** Documenting the existing "Rainbow Heartburst Iris" shader (`eye_shader/`) within the newly initialized Memory Bank. This involves populating the core Memory Bank files with details extracted from the shader code (`.shader`), custom GUI script (`.cs`), architecture description (`.md`), and development chat log (`.txt`).
*   **Recent Changes:**
    *   Initialized the core Memory Bank files (`projectbrief.md`, `productContext.md`, `activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`).
    *   Updated `projectbrief.md` and `productContext.md` with details about the "Rainbow Heartburst Iris" shader.
    *   Prior to Memory Bank initialization: Development of the "Rainbow Heartburst Iris" shader, including HLSL code, C# GUI, and architecture documentation.
*   **Next Steps:**
    *   Update `systemPatterns.md` with the architectural details from `eye_shader/eye-shader-architecture.md` and the shader code.
    *   Update `techContext.md` with the technologies used (HLSL, C#, AudioLink, Unity Built-in RP).
    *   Update `progress.md` to reflect the current state of the "Rainbow Heartburst Iris" shader (appears largely implemented, needs documentation and potentially testing/refinement).
    *   Review all updated Memory Bank files for consistency and completeness regarding the eye shader.
*   **Active Decisions/Considerations:**
    *   Ensuring the Memory Bank accurately reflects the implemented features and design decisions of the "Rainbow Heartburst Iris" shader.
    *   Considering potential future steps after documentation, such as performance testing in VRChat, VR compatibility checks, or further feature refinement based on testing.
*   **Key Patterns/Preferences:**
    *   Use of HLSL within Unity's ShaderLab structure.
    *   Integration with AudioLink using `AudioLink.cginc` and filtered data streams (e.g., `ALPASS_FILTEREDAUDIOLINK`).
    *   Extensive use of shader properties exposed to the Unity Inspector and controlled via a custom C# `ShaderGUI` (`RainbowHeartburstIrisGUI.cs`).
    *   Use of `#pragma shader_feature_local` for toggling features efficiently.
    *   Implementation of effects like parallax (using view direction), noise (using textures and fractal functions), HSV color adjustments, and layered effects (infinite mirror, sunburst).
    *   Emphasis on a "cute," "dreamy," dynamic but not overly distracting aesthetic.
*   **Learnings/Insights:**
    *   The design process involved iterative refinement based on user feedback (documented in `eye_shader/docs/eye_shader_chat_log.txt`).
    *   Research highlighted potential challenges with transparency sorting, VR compatibility (stereo rendering), and performance in VRChat, which should be kept in mind during testing/refinement.
    *   The importance of using filtered AudioLink data for smooth visual effects was noted.
    *   VRChat Expression Parameters are the intended method for user control of shader properties in-game.

*(This file is crucial for tracking the current state of work. Update it frequently, especially before ending a session or switching tasks.)*