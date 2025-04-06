# Tech Context

*   **Primary Language(s):**
    *   **HLSL:** Used within Unity's ShaderLab syntax for the core shader logic (`eye-shader.shader`).
    *   **C#:** Used for the custom Unity Editor GUI script (`RainbowHeartburstIrisGUI.cs`).
*   **Engine/Platform:**
    *   **Unity:** (Version likely 2019.4.31f1 or 2021.x based on VRChat SDK compatibility, specific version not confirmed). Uses the Built-in Render Pipeline.
    *   **VRChat SDK3:** Targeting Avatars 3.0 system.
    *   **Platform Focus:** Primarily PC VRChat due to AudioLink usage.
*   **Key Libraries/Includes:**
    *   **`UnityCG.cginc`:** Standard Unity shader utility functions and variables.
    *   **`Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc`:** Provides functions and definitions for accessing AudioLink data texture.
*   **Development Setup:**
    *   **Unity Editor:** For scene setup, material editing, animation creation, and testing.
    *   **VRChat Creator Companion (VCC):** Recommended for managing the Unity project, VRChat SDK, and dependencies like AudioLink via VPM (VRChat Package Manager).
    *   **IDE:** Visual Studio, VS Code, or similar for editing C# GUI script.
    *   **Version Control:** Git (indicated by `.git` directory in the project root).
*   **Technical Constraints:**
    *   **VRChat Shader Limitations:** Adherence to VRChat performance ranking system (instruction count, texture usage) and shader feature restrictions (e.g., no geometry/tessellation shaders). Potential fallback to Standard Lite if too complex.
    *   **Transparency:** Subject to standard transparency sorting issues in Unity's Built-in RP. Requires careful management of `RenderQueue` and potentially `ZWrite` settings.
    *   **AudioLink on Quest:** AudioLink functionality is limited or unavailable on Quest due to performance constraints. Shader needs graceful fallback if targeting cross-platform.
    *   **VR Stereo Rendering:** Parallax and view-dependent effects must be implemented carefully to avoid visual artifacts or discomfort in VR.
    *   **VRChat Expression Parameters:** Limited sync budget (256 bytes total) and precision (floats are 8-bit).
*   **Dependencies:**
    *   **AudioLink Package:** Required for audio reactivity features. Managed via VCC/VPM.
    *   **VRChat SDK3:** Base SDK for avatar functionality.
    *   **Input Textures:** Requires user-provided textures for `_HeartTexture`, `_RainbowGradientTex`, `_IrisTexture`, `_NoiseTexture`.
*   **Tool Usage Patterns:**
    *   Direct HLSL coding within `.shader` files.
    *   Custom C# `ShaderGUI` development for improved editor usability.
    *   Unity Animator controllers (FX layer) and Animation Clips to link VRChat Expression Parameters to shader properties.
    *   In-editor testing using Unity Play Mode, potentially augmented with VRChat ClientSim or Lyuma's Av3Emulator for testing avatar features and AudioLink simulation.
    *   Testing builds within VRChat, particularly in worlds with AudioLink enabled.
    *   Unity Frame Debugger for diagnosing rendering order and draw call issues.

*(This file details the technology stack and development environment.)*