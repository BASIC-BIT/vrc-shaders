Great! I’ll look into how to convert GLSL shaders from ShaderToy into HLSL shaders for use in VRChat with the Universal Render Pipeline (URP). I’ll specifically explore:

- ShaderToy-specific features that need to be adapted (like `iTime`, `iResolution`, etc.)
- HLSL equivalents and how to structure the shader manually for URP compatibility
- Requirements and constraints of VRChat’s shader system
- How to incorporate AudioLink for reactive visual effects
- Techniques and tips for creating immersive 3D volumetric/kaleidoscopic shaders in VRChat using raw HLSL

I’ll compile all of this into a detailed guide. Hang tight while I dig up everything you need!

# Converting a ShaderToy GLSL Shader to a Unity URP HLSL Shader for VRChat

ShaderToy shaders run in a specific WebGL GLSL environment, while Unity’s Universal Render Pipeline (URP) uses HLSL and a different rendering pipeline. Converting a complex **volumetric, fractal, kaleidoscopic ShaderToy shader** to **raw HLSL in Unity URP** (for use in VRChat worlds) involves re-mapping ShaderToy features to Unity equivalents, writing a compatible shader structure, and considering VRChat’s performance constraints. This guide breaks down the process and provides tips for integration (including AudioLink for audio-reactive visuals) and optimization.

## ShaderToy Features vs Unity URP Equivalents

ShaderToy provides built-in uniforms and a full-screen fragment rendering model that we must replicate in Unity’s shader. Key ShaderToy-specific features and how to replace them in Unity HLSL include:

- **`iTime` (ShaderToy)** – A uniform float for time in seconds since the shader started. In Unity URP, you can use the **`_Time`** uniform (a float4). Specifically, `_Time.y` is the time in seconds since level load (which is analogous to ShaderToy’s iTime) ([Unity - Manual: Built-in shader variables reference](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html#:~:text=_Time%20float4%20Time%20since%20level,t%2F8%2C%20t%2F4%2C%20t%2F2%2C%20t)). For example, in HLSL: `float t = _Time.y;` would give you a time value similar to iTime.
- **`iResolution` (ShaderToy)** – A **vec3** representing the viewport resolution (pixels) and pixel aspect ratio. In Unity, the screen or target texture resolution can be obtained from **`_ScreenParams`** (a float4 where _ScreenParams.x = width, _ScreenParams.y = height) ([Unity - Manual: Built-in shader variables reference](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html#:~:text=_ScreenParams%20float4%20,is%201.0%20%2B%201.0%2Fheight)). For instance, `_ScreenParams.xy` gives the render target size in pixels. If needed, you can pack a similar vec3 manually (with z = aspect ratio, which is `_ScreenParams.x/_ScreenParams.y` in Unity).
- **Fragment Coordinates** – In ShaderToy, the fragment shader gets `fragCoord` (pixel coordinates) and typically uses `gl_FragCoord` internally. In Unity’s HLSL, you achieve this by computing UV or pixel positions in the fragment shader:
  - If rendering on a full-screen quad or surface, you can pass the mesh UVs from the vertex shader to fragment shader (ranging 0–1 across the screen). Then compute pixel coordinates as `float2 fragCoord = IN.uv * _ScreenParams.xy;` (where `IN.uv` is the interpolated UV) ([Unity-Raymarching-Fractals/Assets/Fractal.shader at master · yumayanagisawa/Unity-Raymarching-Fractals · GitHub](https://github.com/yumayanagisawa/Unity-Raymarching-Fractals/blob/master/Assets/Fractal.shader#:~:text=float2%20fragCoord%20%3D%20i.uv%20,xy)).
  - Alternatively, use the system value **SV_Position** in the fragment shader input to get clip-space pixel coordinates, then convert to screen UV. Note that Direct3D (used by Unity on PC) has the origin at the **top-left**, whereas OpenGL (ShaderToy) uses bottom-left. To match ShaderToy’s orientation, you may need to flip the y-coordinate. For example: `float2 fragCoord = float2(IN.screenPos.x, _ScreenParams.y - IN.screenPos.y);` if `IN.screenPos` is the SV_Position.
- **`iChannel0..3` (ShaderToy)** – ShaderToy allows up to 4 input channels (textures, videos, or buffers). In Unity, you must supply any required textures or buffers as shader **sampler2D / Texture2D** uniforms (declared in the shader’s Properties and bound via materials). For example, if the ShaderToy uses `iChannel0` for a feedback buffer or an image, you’d declare a `Texture2D _Channel0; sampler2D _Channel0_sampler;` in HLSL and set that from your Unity project (e.g., assign the corresponding texture to the material). There’s no direct equivalent of ShaderToy’s multi-pass buffers in a single material, so **multiple ShaderToy passes** would have to be handled via multiple Unity shader passes or rendering to render textures (which complicates matters). In most cases, a single-pass effect (like a fractal) can be done in one Unity shader pass.
- **Other ShaderToy uniforms** – ShaderToy also provides `iTimeDelta` (time between frames), `iFrame` (frame count), `iMouse` (cursor interaction), etc. These have no automatic Unity equivalent, but you can simulate them:
  - **Frame count**: Unity doesn’t track shader frame count by default; you could implement a counter in a script and set it as a uniform each frame if needed.
  - **Delta time**: Unity provides `_Time.z` as **time*2** and `_Time.w` as **time*3** ([Unity - Manual: Built-in shader variables reference](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html#:~:text=_Time%20float4%20Time%20since%20level,t%2F8%2C%20t%2F4%2C%20t%2F2%2C%20t)), but not the per-frame delta directly. Instead, you can use Unity’s **`_Time.y`** difference between frames or send `Time.deltaTime` from script to a shader uniform if precise per-frame timing is needed.
  - **User input** (`iMouse`): In VRChat, this might not apply (no mouse), but for Unity in general you could pass cursor or VR controller positions via script to the shader.

**ShaderToy’s Rendering Model vs Unity:** ShaderToy essentially calls your `mainImage(out fragColor, in fragCoord)` for each pixel on a full-screen quad, using an implicit camera facing the screen. In Unity URP, you must create this setup. The common approaches are: 

- *Apply the shader to a Quad or Plane* that fills the camera view (for a fullscreen effect in a world). The quad’s UVs can be used to simulate fragCoord as described above. This is like a manual fullscreen post-effect.  
- *Apply the shader to a Skybox or large sphere around the camera.* For immersive volumetric fractals, you might use a sphere with inward-facing normals. The fragment shader can then perform a raymarch in the fragment’s view direction to render the fractal volume. In this case, you’ll use the camera direction (from view or world coordinates) instead of screen UV. Unity provides the **camera position** (`_WorldSpaceCameraPos`) and you can compute a view ray for each fragment using transformed vertex positions or Unity’s matrices. For example, you can reconstruct a view ray in the vertex shader by multiplying the object’s vertex position by the inverse of the projection matrix, etc., or by using Unity’s **SpaceTransforms.hlsl** utilities. This is more advanced, but many Unity raymarching implementations use `UnityObjectToClipPos` in the vertex shader and then in the fragment, use the interpolated position to derive a view direction.
- *Use a custom post-process Pass* (available in URP via the ScriptableRenderFeature mechanism). This is another way to draw a full-screen effect after the scene, but in VRChat world creation you typically don’t have access to adding custom render features. So using geometry (quad or sphere) with your shader is the more common approach.

In summary, any **GLSL logic from ShaderToy** (like fractal distance estimations, coloring, etc.) can be translated line-by-line into HLSL once the above inputs are mapped. The math functions are mostly the same (HLSL uses `lerp(a,b,t)` instead of `mix(a,b,t)`, `frac(x)` instead of `fract(x)`, and `fmod(x,y)` instead of `mod(x,y)` if you need modulus on floats). Be mindful of precision: ShaderToy uses highp floats by default; in HLSL, use `float` (32-bit) for similar precision. You can also use **`half`** in Unity HLSL for optimizations, but more on that in the optimization section.

## Structure of a URP-Compatible HLSL Shader (Manual Implementation)

Unity URP does not support old Surface Shaders or Shader Graph for custom VRChat shaders – we write **vertex/fragment shader code in HLSL** within a ShaderLab file. The shader must be structured to be URP-compatible and VRChat-compatible. Important components of the shader file include:

- **ShaderLab Definition and Properties:** Begin with a `Shader "Name"` declaration. Inside, a `Properties` block defines any tweakable parameters for the material (colors, textures, etc.). Each property should later be matched with a uniform in the HLSL code.
- **URP SubShader with Tags:** URP uses the Scriptable Render Pipeline (SRP). You must tag the SubShader for URP so it’s used instead of built-in. For example: 

  ```c
  SubShader {
    Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
    ... 
  }
  ``` 

  The `RenderPipeline` tag ensures this SubShader is chosen when running under URP ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=%2F%2F%20a%20pass%20is%20executed,)). (If you want the shader to also fall back to built-in pipeline for compatibility, you could provide another SubShader without that tag. But focusing on URP here.)

- **Pass and HLSLPROGRAM Block:** Inside the SubShader, define a `Pass` with the actual HLSL code. Use `HLSLPROGRAM`/`ENDHLSL` (or `CGPROGRAM`/`ENDCG`) to embed HLSL code. URP expects HLSL. Within this block, you’ll specify shader stage entry points and includes:
  - `#pragma vertex vert` and `#pragma fragment frag` to indicate the names of your vertex and fragment shader functions ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=%2F%2F%20The%20HLSL%20code%20block,pragma%20fragment%20frag)).
  - `#pragma target 4.5` (or higher) if you need Shader Model 4.5/5.0 features (URP supports SM 4.5+ which is required for modern HLSL syntax and the SRP Batcher).
  - Include the core URP shader library:  
    ```hlsl
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    ```  
    This gives you common Unity functions/macros and also includes other helpful includes like Unity’s matrix transforms ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=%2F%2F%20The%20Core,pipelines.universal%2FShaderLibrary%2FCore.hlsl)). For example, `TransformObjectToHClip()` becomes available, which transforms object space to homogeneous clip space (similar to UnityObjectToClipPos from built-in).
- **Constant Buffer (CBUFFER) for Material Properties:** To be SRP Batcher compatible, Unity requires that all material properties are inside a **`UnityPerMaterial` CBUFFER** in the shader code ([Writing Shader Code in Universal RP (v2) | Cyanilux](https://www.cyanilux.com/tutorials/urp-shader-code/#:~:text=UnityPerMaterial%20CBUFFER)) ([Writing Shader Code in Universal RP (v2) | Cyanilux](https://www.cyanilux.com/tutorials/urp-shader-code/#:~:text=CBUFFER_START,y%20%3D%201%2Fheight%2C%20z)). The Unity URP templates usually do this for you. In a hand-written shader, you should wrap your property uniforms like this: 
  ```hlsl
  CBUFFER_START(UnityPerMaterial)
    float4 _MainColor;       // example property (color)
    float3 _SomeVector;      // another property
    float4 _MainTex_ST;      // Unity tiling offset for a texture
  CBUFFER_END
  ``` 
  Every property you defined in the Properties block (except textures, which use a different binding method) should appear here, with the same name and a type that matches (Color or Vector -> float4, Float -> float, etc). Unity automatically sets these values per material. The `_MainTex_ST` and similar are standard Unity convention for texture UV transformation (they get set if you have a texture property named “_MainTex”). If you use any textures, Unity will also give you `_TextureName_TexelSize` and so on in some pipelines – but you can ignore those unless needed.
- **Vertex Input (Attributes) and Varyings:** Define struct for vertex input (commonly called `Attributes`) and one for the data passed to fragment (commonly `Varyings` or `Interpolators`). For example:
  ```hlsl
  struct Attributes {
      float4 positionOS : POSITION;   // Object-space vertex position
      float2 uv : TEXCOORD0;         // UV coordinate
      // ... (normal, color, etc, if needed)
  };
  struct Varyings {
      float4 positionCS : SV_POSITION; // Clip-space position (built-in semantic)
      float2 uv : TEXCOORD0;          // UV interpolated to fragment
      // ... (any other data to pass)
  };
  ```
  Here we take the object-space position and uv from the mesh. In the vertex shader, we’ll fill the Varyings.
- **Vertex Shader (`vert` function):** This runs per-vertex. It must output the position to clip space and any needed varyings. Using URP’s include, you can do:
  ```hlsl
  Varyings vert (Attributes IN) {
      Varyings OUT;
      // Transform object space to homogeneous clip space (HClip)
      OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz); // function from Core.hlsl
      OUT.uv = IN.uv;
      return OUT;
  }
  ```
  This uses Unity’s MVP matrix internally to get `SV_POSITION` ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=Varyings%20OUT%3B%20%2F%2F%20The%20TransformObjectToHClip,return%20OUT%3B)). If you needed world-space position or normal for your fragment (e.g., for ray direction calculation), you would also transform those here and pass in the varyings.
- **Fragment Shader (`frag` function):** This runs per-pixel. It takes the Varyings input and must return a color (`float4`) with semantic **SV_Target**. Here you implement the ShaderToy logic. For example:
  ```hlsl
  float4 frag (Varyings IN) : SV_Target {
      // Normalize UV (0 to 1)
      float2 uv = IN.uv;
      // If needed, compute pixel coordinates:
      float2 fragCoord = uv * _ScreenParams.xy;  // pixel position
      // Time
      float time = _Time.y;
      // Implement kaleidoscopic fractal coloring (example pseudo-code)
      float3 col = FractalKaleidoscope(uv, time);
      return float4(col, 1.0);
  }
  ```
  In the above snippet, `FractalKaleidoscope` would be a function you write (in HLSL) that reproduces the fractal rendering. That could involve ray marching: casting a ray through a volumetric fractal distance field, iterating, checking for intersection, coloring, etc. You can write helper functions above or below frag as needed. Keep in mind HLSL syntax (for example, use `for` loops similarly to GLSL; most math functions like `sin, cos, dot, normalize` are the same).
  
Putting it all together, here’s a **minimal example** of an URP shader skeleton in HLSL (unlit, suitable for VRChat world usage):

```hlsl
Shader "MyProject/FractalKaleidoscope"
{
    Properties{
        _MainTex ("Base Texture", 2D) = "white" {}    // example texture property
        _Color ("Color Tint", Color) = (1,1,1,1)      // example color property
    }
    SubShader{
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        Pass{
            HLSLPROGRAM
            // Target shader model 4.5 (DX11) for modern features
            #pragma target 4.5
            // Entry points
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Uniforms in UnityPerMaterial for SRP Batcher
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
            CBUFFER_END

            // Texture2D and sampler (textures aren’t in the CBUFFER)
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target {
                // Example: sample a texture and modulate by a color and a time-varying factor
                float2 uv = IN.uv;
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                // Use _Time (Unity built-in) for animation
                float t = _Time.y;
                float pulsing = 0.5 + 0.5 * sin(t);  // oscillate between 0 and 1
                float4 resultColor = texColor * _Color * pulsing;
                return resultColor;
            }
            ENDHLSL
        }
    }
}
```

In this example, we showed a texture modulated by time and a color. For your actual fractal, you would replace the texture sampling and simple pulse with your raymarching calculations. The structure (Properties, CBUFFER, includes, vert/frag functions, etc.) should remain as shown. Notice we used `TEXTURE2D`/`SAMPLER` macros (these come from Unity’s HLSL includes) to declare the texture and sampler. We also used `SAMPLE_TEXTURE2D` to sample it. These macros handle differences between platforms (and they correspond to typical HLSL `Texture2D` and `SamplerState` usage).

**URP lighting**: Since the effect is kaleidoscopic and volumetric, you likely want it **unlit** (just emissive color). The shader above is effectively unlit. If you needed lighting, URP’s pipeline is more complex (you’d need to handle additional passes or include Lit functions). For VRChat world effects, unlit is usually fine (and cheaper). Make sure to consider blending if your effect isn’t opaque – e.g., if you want additive or alpha blending (set `Blend` states in the pass and use `Tags { "RenderType"="Transparent" "Queue"="Transparent" }` for transparency).

Finally, ensure the shader compiles without errors and apply it to a material on a test object in Unity to verify it reproduces the ShaderToy look.

## VRChat-Specific Shader Considerations

When targeting VRChat, you must account for platform and performance constraints:

- **Render Pipeline Compatibility:** As of 2025, **VRChat uses Unity’s Built-In Render Pipeline (BiRP)** for rendering, *not* URP ([Is there a comprehensive guide to VRC's engine VS PC hardware - General Discussion - VRChat Ask Forum](https://ask.vrchat.com/t/is-there-a-comprehensive-guide-to-vrcs-engine-vs-pc-hardware/16827#:~:text=VRChat%20uses%20Unity%E2%80%99s%20Builtin%20Renderer,some%20experience%20with%20graphics%20programming)). This means a shader tagged for URP might *not* work in VRChat unless VRChat updates to URP. In practice, if you import an URP shader into VRChat, the engine may ignore the URP SubShader. To ensure compatibility, you have two options:
  1. **Adapt the shader to Built-in:** Remove or modify the `RenderPipeline` tag and use built-in includes (like UnityCG.cginc). The HLSL logic for the fractal can remain the same, but you’d use `UnityObjectToClipPos` instead of `TransformObjectToHClip`, etc. If you prefer to keep it URP-style, you could also *duplicate the shader code* in a second SubShader without URP-specific tags as a fallback for VRChat’s built-in pipeline.
  2. **Use VRChat’s experimental URP (if available):** VRChat has discussed future support for URP, but as of now it’s not implemented. If you strictly use the shader in VRChat worlds, you may need to stick to built-in pipeline for the time being. (The good news is that converting URP unlit shader code to built-in unlit is relatively straightforward, mostly involving different include files and possibly removing the UnityPerMaterial buffer requirement. Since this guide focuses on URP, remember to revisit this if you encounter a pink shader in VRChat – it might be the pipeline mismatch.)
- **Platforms – PC vs Quest:** VRChat runs on PC (with typically DirectX11) and on Oculus Quest (Android OpenGL ES). PC can handle complex shaders better, while Quest is **much more limited**. **Custom shaders on avatars are completely blocked on Quest** (only a fixed set of shaders can be used) ([Quest Content Limitations | VRChat Creation](https://creators.vrchat.com/platforms/android/quest-content-limitations/#:~:text=VRChat%20on%20Quest%20only%20permits,a%20short%20description%20and)). **World shaders on Quest** are *allowed* but should be extremely optimized ([Quest Content Optimization | VRChat Creation](https://creators.vrchat.com/platforms/android/quest-content-optimization/#:~:text=Shaders%20are%20not%20restricted%20for,and%20bake%20your%20lighting)). A ray-marched volumetric fractal will not run well (or at all) on Quest’s mobile GPU – it might exceed instruction limits or run at an unplayable framerate. So practically, **target this effect for PC VRChat**. You can mark the material as “PC only” in your world or use fallback shaders for Quest users (perhaps a static skybox).
- **Performance in VR:** Even on PC, VRChat is often run in VR at 90+ FPS, so performance is critical. A shader that takes 5ms on a flat screen might be 10ms+ in VR (since it’s rendered twice, once per eye). Volumetric fractals (which typically use raymarching loops) are *expensive*. Some considerations:
  - **Iteration count:** If your fractal shader uses iterative ray marching (e.g., stepping through a 3D space to find surfaces or coloring a volume), make sure the number of steps is as low as possible while still looking good. Provide a way to reduce quality if needed (for example, a shader keyword or uniform to toggle a “low quality” mode with fewer iterations or a shorter ray distance).
  - **Avoid complex branches:** Fractal shaders sometimes have `if` conditions inside loops (for example, bail-out conditions). On GPU, divergent branches can hurt performance. Try to structure calculations to use math operations instead of conditionals where possible (use smooth minimums, etc., or ensure all threads follow similar path).
  - **Texture access:** If your shader is mostly procedural (fractal), it might not use many textures. This is good for performance. If you do use textures (noise textures, etc.), be mindful of their size. VRChat recommends not using huge textures, especially for avatars. For worlds, it’s a bit more lenient, but still, 4K textures sampled in a fragment shader can reduce cache efficiency. Since your effect is likely resolution-dependent (each pixel does heavy math rather than sampling lots of textures), focus on optimizing math.
  - **GPU Fragile Limits:** Shader Model 5.0 on PC can handle a lot, but there are limits (for example, DX11 has a maximum of 1024 instruction slots for pixel shaders *before* unrolling loops – though modern GPUs can often handle dynamic loops well beyond that, the compiler might unroll loops in some cases). If your shader is extremely long or uses big unrolled loops, you could hit those limits and get a compile error. Keep an eye on Unity’s console during import – if the shader is too complex, Unity will warn or error. Splitting work into multiple passes is not really an option in VRChat for this case (would need multiple render targets), so it’s about balancing within one pass.
- **VRChat World Constraints:** Unlike avatars, worlds don’t have an explicit “performance rank” system for shaders. But **the same principles apply** – if your world has a shader that eats 10ms of GPU time, it will cause low FPS for users. VRChat’s community generally expects worlds to be reasonably optimized. It’s wise to allow users to turn off or reduce intensive effects. For example, you could provide an in-world Udon toggle to disable the fractal effect for those with weaker PCs. Many worlds do this for post-processing or shader-intensive visuals.
- **Testing in VRChat:** Test your shader in the VRChat client (not just Unity Editor). Sometimes Unity Editor will run a shader fine, but VRChat might have subtle differences (for instance, VRChat uses a forward rendering path with multiple lights and post-processing unless you disable them – an unlit shader should largely be unaffected by lights, though).
- **No dynamic tessellation or geometry shaders on VRChat:** Unity URP doesn’t support geometry/tessellation in the default pipeline anyway (HDRP does, URP doesn’t by default). And Quest wouldn’t handle those. So stick to vertex/fragment logic as we’ve done.

In short, for VRChat: focus on **PC, unlit, single-pass, forward rendering**. Keep it as simple as possible while achieving the desired visual. Profile it on a typical VR-ready PC to ensure it’s not lagging. VRChat’s docs suggest aiming for **<200 shader math instructions for avatars** as a guideline; for worlds you can exceed that, but a raymarch will likely be in the thousands of instructions. That’s acceptable only if it’s a main part of your world and not used on too many pixels at once. Perhaps limit it to the skybox or a contained area so it’s not covering every pixel all the time (if it is a sky dome, it *is* covering every pixel when looking at it, which is fine as long as it’s optimized to run ~90 FPS).

*A note on stereo rendering:* If you want the fractal to have proper depth in VR (stereo vision), you should incorporate the camera’s position for each eye in the ray calculations. Unity will render the shader twice (once per eye) with `_WorldSpaceCameraPos` set accordingly. As long as your raymarch uses `_WorldSpaceCameraPos` and the fragment’s direction, each eye will see a slightly different view of the fractal, giving true 3D depth to the effect. This can greatly enhance an “immersive” volumetric effect. Just be sure to use the **camera position and view direction per pixel** rather than assuming a single static camera. Many shaders simply assume camera at origin looking down -Z (as ShaderToy does); converting to use actual camera transforms will make it work in VR the same way it does in the Editor.

## AudioLink Integration in HLSL (Audio-Reactive Shaders in VRChat)

**AudioLink** is a system in VRChat that feeds audio spectrum data to shaders, allowing visuals to react to music or other audio ([Community:AudioLink - VRChat Wiki](https://wiki.vrchat.com/wiki/Community:AudioLink#:~:text=AudioLink%20is%20a%20Unity,the%20audio%27s%20rhythm%20and%20intensity)) ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=The%20per,world%20and%20across%20all%20avatars)). It works by analyzing the world’s audio in real-time (via an Udon script) and writing the analysis into a **global texture `_AudioTexture`** that all shaders can access. To integrate AudioLink in your HLSL shader:

1. **Install and Enable AudioLink:** In your VRChat world project, import the AudioLink package (via VRChat Creator Companion or the GitHub package). Ensure an **AudioLink controller** prefab is present in the scene and feeding the audio source. This setup is outside the shader – but the shader will not receive data unless AudioLink is active in the world.
2. **Declare the AudioLink texture in the Shader:** In the shader code, you need to declare the special texture that AudioLink uses. The name is `_AudioTexture`. It’s a 2D texture (typically sized 128xN). You should also declare a sampler for it. For example, inside the HLSLPROGRAM:
   ```hlsl
   TEXTURE2D(_AudioTexture);
   SAMPLER(sampler_AudioTexture);
   ```
   AudioLink will globally bind this texture for you at runtime (you don’t set it manually; the AudioLink script uses a shader global).
3. **Sample Audio Data:** The `_AudioTexture` contains a lot of information packed in pixels. Each pixel’s RGBA components represent certain audio metrics (often amplitudes of certain frequency ranges, or other derived data like beat timing or color triggers). Typically:
   - The width of the texture (x dimension) is 128 pixels (this is a default in AudioLink ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=define%20AUDIOLINK_WIDTH%20128))).
   - The height (y dimension) can be multiple rows for different categories of data. AudioLink’s documentation indicates it streams **per-frequency amplitude data** into this texture ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=The%20per,world%20and%20across%20all%20avatars)). The first few rows might correspond to different audio bands or channels.
   - For example, AudioLink often uses four frequency bands (commonly labeled **Bass, Low Mid, High Mid, Treble**) as well as a full spectrum. The four band-averages might be stored in specific pixels (or as an average of ranges of the spectrum row). The full spectrum (all 128 frequency bins) might be stored in one row of 128 pixels, updated each frame.
   - There may also be special pixels for overall amplitude (VU meter) or beat detection outputs, depending on the AudioLink version.
   
   To retrieve data, you can sample specific pixel coordinates. There are two approaches:
   - **Direct index sampling (preferred in HLSL)**: Since we know the texture is a small data texture, we can sample by exact texel. In HLSL, you can do: 
     ```hlsl
     int2 pixel = int2(x, y);
     float4 audioValue = _AudioTexture.Load(int3(pixel, 0));
     ```
     This fetches the texel at (x,y) with no filtering. Each component `.r .g .b .a` might represent different things (often they pack multiple channels of audio data).
   - **Normalized UV sampling**: Alternatively, compute UV and sample as a normal texture (using `tex2Dlod` or `SAMPLE_TEXTURE2D` with a manual LOD 0). For instance: 
     ```hlsl
     float2 uv = (pixel + 0.5) / float2(textureWidth, textureHeight);
     float4 audioValue = SAMPLE_TEXTURE2D_LOD(_AudioTexture, sampler_AudioTexture, uv, 0);
     ```
     Ensure no interpolation (`POINT` sampling) is applied – AudioLink texture is set up as point filtered, so `.Load` or explicit LOD are safe.
   - **Using AudioLink’s helper functions**: If you include AudioLink’s provided shader include (AudioLink.cginc), it defines handy macros like `AudioLinkData(int2 coord)` which abstracts the above ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=sampler2D%20_AudioTexture%3B)). For example, `AudioLinkData(int2(0,0))` might return the float4 at pixel (0,0). It also has functions like `AudioLinkLerp` for smooth interpolation ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=float4%20AudioLinkLerp%28float2%20xy%29%20,x%20%29%20%29%3B)). These are optional but can simplify code. Make sure to `#include "AudioLink.cginc"` *after* declaring the texture, to get those macros.

4. **Understand AudioLink Data Layout:** While you can trial-and-error sample the texture, here’s a general idea of common layout (check AudioLink docs for specifics of your version):
   - The **first row (y=0)** of `_AudioTexture` often contains the **full spectrum** (frequency analysis). Each x from 0 to 127 is a frequency bin (from low to high frequency). `.r/.g/.b/.a` might each correspond to a different channel or different processed version (some implementations use .r for left, .g for right, etc., or .r for amplitude and .g/.b/.a for other metrics). If you just need an overall intensity of a particular frequency range, you might sum or average a subset of these.
   - Additional rows might contain history or filtered data. For instance, row 1 could be the spectrum from the previous frame (a delay), or a smoothed version. AudioLink 2.0 introduced multiline textures and more data, so there could be a row for each of the 4 bands’ smoothed values over time.
   - **Four-band averages**: Many creators use just four numbers corresponding to Bass, Low Mid, High Mid, Treble energy. AudioLink provides these as well. They might be at specific pixel indices (e.g., sometimes pixel (0,1), (1,1), (2,1), (3,1) for the four bands, or they might require averaging segments of the spectrum row). Check AudioLink’s shader examples or documentation to find exactly where – or compute it yourself: for example, define frequency ranges for each band (Bass = bins 0–10, etc.) and average those bins’ values.
   - **Amplitude/Volume**: A general volume level (VU meter style) might be stored (some AudioLink versions store it in the alpha of a certain pixel or as a separate pixel).
   - **Beat pulses / BPM**: AudioLink doesn’t explicitly compute BPM, but you can derive beat events by watching for spikes in the low-frequency (bass) values. Some advanced AudioLink shaders use algorithms to detect beats (e.g., compare current bass to a running average and trigger if above threshold). The AudioLink system itself primarily provides the raw spectrum and possibly a smoothed variant; beat detection logic is usually done in the shader.

5. **Use Audio Data in Your Shader Logic:** Once you have the audio data, you can creatively drive visuals. For a **kaleidoscopic fractal**:
   - **Beat/Amplitude Reactivity:** Use the **bass or overall amplitude** to pulse the fractal’s intensity or size. For example, scale the fractal’s color brightness or the step count based on a bass value. A simple approach: `float bass = AudioLinkData(int2(0, someRow)).r;` (get the bass value from the appropriate place) then `col *= 1.0 + bass*2.0;` to make the color brighter when bass hits.
   - **Frequency-based Color:** Map different frequency bands to different color channels or patterns. For instance, use the treble (high frequencies) to add a subtle color tint or sparkles to the fractal highlights, and use the mid frequencies to shift the hue of the kaleidoscope. If you have a spectrum array, you could even map frequency -> radius in the fractal: e.g., alter a parameter of the fractal formula at index corresponding to a certain frequency.
   - **Geometric Transformations:** Kaleidoscopic effects often involve mirror symmetries or rotations. You can modulate the angle of rotation or number of symmetry segments with music. For example, if your shader has a kaleidoscope mirror count, you could add `+ sin(t * someBassLinkedSpeed)` to that count to subtly oscillate the pattern complexity in sync with beats.
   - **Time-based modulation:** AudioLink gives you real-time data, but you can also incorporate it over time. For example, accumulate an average of bass over a second to detect “beat drops” or use an integral of treble to create glitter effects after a crescendo. You might use a smoothing function (AudioLink provides an example of an IIR filter in shader form: `filteredValue = lerp(newValue, lastValue, 0.9)` for instance ([audiolink/Docs at master · llealloo/audiolink · GitHub](https://github.com/llealloo/vrc-udon-audio-link/tree/master/Docs#:~:text=Filtered%20Value%20%3D%20New%20Value,Filter%20Constant))) to avoid jitter.

6. **AudioLink Shader Documentation and Links:** Refer to official AudioLink docs for specifics. The VRChat **AudioLink GitHub** has a section for shader creators ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=The%20per,world%20and%20across%20all%20avatars)) and even an FAQ. There is also an official VRChat **AudioLink documentation page** ([Community:AudioLink - VRChat Wiki](https://wiki.vrchat.com/wiki/Community:AudioLink#:~:text=AudioLink%20is%20a%20Unity,the%20audio%27s%20rhythm%20and%20intensity)). Here are some useful references:
   - *VRChat AudioLink Wiki:* “AudioLink... distributes amplitude and frequency data to shaders via a texture (_AudioTexture)” ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=The%20per,world%20and%20across%20all%20avatars)). This confirms the concept.
   - *AudioLink GitHub (llealloo/audiolink):* Contains `AudioLink.cginc` and example shaders. You can see how they sample `_AudioTexture` and what coordinates they use. For instance, in one community shader, they define a macro for AudioLinkData to index the texture with `tex2Dlod` ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=sampler2D%20_AudioTexture%3B)).
   - *AudioLink Prefab Package:* Often includes example materials (for example, an AudioLink spectrum prefab or some avatar shaders). Studying those can reveal which pixel corresponds to which band. Commonly, they use something like:
     ```hlsl
     float4 spectrum = AudioLinkData(int2(binIndex, 0));  // y=0 row for spectrum
     ```
     and
     ```hlsl
     float bass = AudioLinkData(int2(0,1)).r;
     float lowMid = AudioLinkData(int2(1,1)).r;
     // etc.
     ```
     (This is speculative – check actual mappings.)

For your use case, you might not need the exact mapping – experiment by printing values (e.g., temporarily output the audio value to the fragment color to see what part of the texture changes with the music). For example, set your shader’s output color to `float4(bass, 0, 0, 1)` and watch in VRChat with music to ensure the bass component is coming through.

**Beat Detection Tip:** A simple beat pulse can be detected by comparing the current bass value to a slightly time-smoothed bass. For instance:
```hlsl
half currBass = AudioLinkData(int2(0,1)).r;
half beat = saturate((currBass - _PrevBass) * 10.0);  // _PrevBass could be a uniform updated via AudioLink or a value held via shader trick
```
In shaders, you don’t have a persistent variable across frames easily (unless you use something like the audio texture itself to store a history). AudioLink might actually encode previous frames already (some implementations use extra rows as a history buffer). You can use those to detect rising edges. Once you have a beat signal (e.g., >0 when a beat occurs), you can flash the screen or expand the fractal momentarily. Many AudioLink shaders use the bass or combined low frequencies as a trigger for on-beat events.

Finally, **don’t forget to include a reference or slider to turn off AudioLink** if no audio is present. If `_AudioTexture` isn’t present (no AudioLink in the world or disabled), shaders usually default to 0. It’s good to handle that gracefully (the visuals might just not react, which is fine). You could also allow a manual mode to animate even without audio (fallback to using `_Time` so the shader isn’t static).

**Resources for AudioLink:**

- Official AudioLink GitHub README (llealloo): gives an overview ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=AudioLink%20is%20a%20system%20that,data%20to%20Scripts%20and%20Shaders)).
- AudioLink section in Poiyomi Toon Shader docs: explains some uses of the 4 bands and options ([AudioLink Shader - Docs](https://shaders.orels.sh/docs/orl-standard/audio-link#:~:text=,Options%20are%3A%20X%2FY%2FNegative%20X%2FNegative%20Y)).
- Community guides and YouTube tutorials on AudioLink (look up “VRChat AudioLink shader tutorial”) – these often show how to bind the shader and tune the bands.
- The AudioLink prefab’s `AudioLinkController` in Unity has tunable settings (like frequency band split frequencies, smoothing amount). These can affect what you see in `_AudioTexture`. For example, the default split might categorize frequencies at roughly 60 Hz (bass), 250 Hz (low mid), 1000 Hz (high mid), 4000+ Hz (treble) as band separation. If you need precise control, you can adjust those or just use the continuous spectrum.

## Tools, Libraries, and Resources for Converting ShaderToy to Unity HLSL

Porting shaders can be tricky, but there are some tools and open-source projects that can help or serve as examples:

- **Shader Conversion Tools:** There have been community tools to assist in converting ShaderToy GLSL to Unity. For example, some developers created scripts to translate GLSL code to HLSL (accounting for syntax differences). One such project mentioned on Unity forums is “Shader Converter” which aimed to automate some of this. However, these are not always up-to-date or 1-click solutions; you will often need to tweak the output. Given the complexity of a volumetric fractal, manual conversion (with testing) is likely still needed.
- **Open-Source Unity Raymarching Shaders:** A great way to learn patterns is to study existing Unity shaders that do similar things:
  - **Unity-Raymarching-Fractals (GitHub)** – An open source project by user *yumayanagisawa* that contains fractal raymarching shaders in Unity ([Unity-Raymarching-Fractals/Assets/Fractal.shader at master - GitHub](https://github.com/yumayanagisawa/Unity-Raymarching-Fractals/blob/master/Assets/Fractal.shader#:~:text=Unity,creating%20an%20account%20on%20GitHub)). It likely includes HLSL code for fractals (possibly the Mandelbulb, etc.) in Unity’s context. You can see how they set up the coordinate system, camera ray, and loop. This can guide your conversion.
  - **WSWhitehouse/Unity-Raymarching (GitHub)** – Another project focused on ray marching in Unity, targeting URP ([GitHub - WSWhitehouse/Unity-Raymarching: Raymarching Project In Unity](https://github.com/WSWhitehouse/Unity-Raymarching#:~:text=unity%20%20%20%20104,pipeline)). It might have examples of implementing ShaderToy-like scenes. This repo also provides a list of resources (articles and videos) for raymarching, which is the technique likely used in your volumetric fractal shader.
  - **Alan Zucconi’s Raymarching Tutorials** – A well-known series of blog posts on ray marching in Unity (in 2D and 3D). These cover Signed Distance Functions (SDFs) and how to render them in Unity HLSL ([GitHub - WSWhitehouse/Unity-Raymarching: Raymarching Project In Unity](https://github.com/WSWhitehouse/Unity-Raymarching#:~:text=%2A%20https%3A%2F%2Fwww.alanzucconi.com%2F2016%2F07%2F01%2Fraymarching%2F%20%2A%20https%3A%2F%2Fwww.alanzucconi.com%2F2016%2F07%2F01%2Fsigned,Unrelated%2C%20But%20Worth%20Reading)). If your fractal is defined by an SDF, this resource is pure gold. It starts simple (shapes) and goes up to fractal noise and optimizations like distance field shadows.
  - **Shadertoy to Three.js or Babylon.js examples:** While not Unity, there are numerous examples of ShaderToy shaders ported to other engines (like Three.js). The principles are similar for Unity in terms of converting coordinate space and replacing uniforms. For instance, the Three.js community often takes ShaderToy code and replaces iTime with their time uniform and iResolution with canvas size. Seeing those conversions (e.g., on Stack Exchange or blog posts) can reinforce the steps needed for Unity.
- **Community Shaders for VRChat:** Some community-made shader packs for VRChat might have done something similar. For example, there are “trippy” shader packs or worlds that have kaleidoscopic effects (perhaps not fractal, but kaleidoscope mirrors). If any of those are open-source or if authors shared tips, they might provide insight on performance or implementation details specific to VRChat. Names to look for include *Mochie* (known for fancy shaders, some open-source on GitHub) or *Cyan* (CyanLaser) who wrote shader tutorials for VRChat.
- **Debugging Tools:** Unity’s **Frame Debugger** can help ensure your shader is being applied and see the draw call for your object. For deeper shader debugging (stepping through loops), standard tools are limited on actual hardware. You can use **RenderDoc** (a graphics debugger) with Unity to capture a frame and inspect shader inputs/outputs. RenderDoc won’t let you step through HLSL like a CPU debugger, but you can see render target outputs for each draw and sometimes isolate issues (like if your shader isn’t drawing at all, etc.). Another trick: **Shader Model 4.5 vs 5.0** – if using SM5.0, you can use some debugging tools in DirectX (like PIX or Nsight) to possibly see intermediate values, but this is advanced.
- **Iteration in Play Mode:** To iterate on the visual quickly, you could use Unity’s play mode or even the **ShaderToy Unity plugin** if one exists. There used to be a Unity asset store package that let you run ShaderToy shaders in Unity by auto-wrapping them – but it might not handle complex cases and likely isn’t URP-compatible. Still, for initial prototyping, running the shader in ShaderToy itself is the fastest way to tweak the look, then port changes to Unity.
- **Testing on target hardware:** If you have access to a VR headset and a moderately powered PC and a weak PC, test on both. Sometimes a shader that runs fine on a 3080 might struggle on a GTX 1060. Knowing your audience (VRChat users have a range of PCs) can guide how much to optimize.

**Libraries:** Besides Unity’s built-in include files (Core.hlsl, etc.), you might find useful HLSL utility libraries on GitHub for noise functions or math. For example, if your ShaderToy fractal uses a 3D noise, you’ll need an HLSL implementation of that (many are available – e.g., search for “HLSL simplex noise”). Rather than translate the GLSL noise line-by-line, you might drop in a known-good noise function in HLSL.

In summary, leverage community knowledge. Often someone has already dealt with “GLSL to Unity HLSL” conversion issues (like the Y inversion, or the lack of certain functions). Unity’s forums, Stack Overflow, and Reddit (e.g., r/Unity3D or r/ShaderCoding) have Q&A on specific conversion problems. For instance, if you hit an error converting a GLSL array or a for-loop with dynamic indexing, a quick search might show a workaround.

## Optimization and Debugging Tips for VRChat HLSL Shaders

Working with complex shaders requires careful optimization and iterative debugging. Here are some best practices to get your shader running smoothly:

- **Optimize math operations:** Simplify the fractal calculations as much as you can. For example, if the fractal formula has symmetry, exploit it. Kaleidoscopic effects often mirror coordinates; you can reflect the coordinate instead of fully raymarching multiple symmetric rays. Compute expensive functions once if they can be reused. Use multiplications instead of divisions where possible, etc.
- **Use appropriate precision:** In Unity HLSL, `float` is 32-bit (high precision) and `half` is 16-bit (moderate precision). Using `half` in your fragment shader for intermediate calculations can improve performance on some GPUs (especially mobile, though on PC it’s less critical but can reduce register pressure). Be cautious: if your fractal requires high precision to not “blow up” (many iterations accumulating error), stick to `float`. You can often use `half` for color values or non-critical parts (like the final color modulation). Profile to see if it makes a difference.
- **Loop unrolling vs dynamic:** If you have a `for` loop with a known maximum, HLSL might unroll it, leading to a lot of static instructions. Sometimes leaving it dynamic (with a `break` condition) can be better, but sometimes not. You might experiment with `[loop]` and `[unroll]` attributes to guide the compiler. Unity will by default try to unroll small loops. For a fractal raymarch (which might loop until a certain depth or distance threshold), you might want it *not* unrolled to keep shader size manageable. Mark it with `[loop]` to hint at a dynamic loop.
- **Reduce texture fetches**: If you introduced any texture for detail (maybe a 3D texture or a detail map), be aware each texture sample is relatively expensive, especially in a heavy math shader. Try to use purely mathematical patterns if you can. If you *must* use a texture (say, a 3D noise texture for volumetric detail), consider sampling it at a lower rate or lod. Also, reuse the sample – e.g., if you need the noise at two points that are close, maybe just sample once and adjust it.
- **LOD vs resolution trade-off:** If applying shader on a large object, the effective resolution could be high. One trick: You can render your effect to a smaller RenderTexture and then upscale it in the world (like a fullscreen blit at half resolution) – but in VRChat worlds, doing a separate render is not trivial without custom scripting and likely not worth it. Instead, consider if you can get away with lower detail: e.g., skip every other pixel’s heavy calculation and interpolate (this is advanced and usually not done in shaders directly, except via rendering to half-res target).
- **Debugging visual issues:** If the shader isn’t working as expected (e.g., black screen or artifacts), try isolating parts:
  - Set the fragment output to a simple test pattern (uv grid or time-based color) to ensure the pipeline (vertex to frag) is correct.
  - Then add back the fractal code gradually. Use a lot of temporary visuals: for example, output the distance estimator result as grayscale to see if the raymarch is computing distances correctly. Or output the iteration count (normalized) to see where it’s hitting a max.
  - You can also use the **SV_Depth** output in fragment if doing raymarching to manually set depth, but that’s only needed if you want other objects to occlude properly. If this fractal is a skybox/background, you can often ignore depth or set it to far.
  - Check for NaNs or INFs – if your fractal math diverges, it can create NaNs that propagate and show up as black or white flickers. Clamp values or use `isfinite()` checks if needed (Shader Model 5 has functions like `isnan()` and `isinf()` which you could use to catch and handle, though that’s rarely needed if your math is sound).
- **Profiling in Unity:** Use the Unity Profiler or Frame Debugger to see how many draw calls your shader is causing and if it might be falling out of SRP batcher. If you see “SRP Batcher compatible: NO” on your shader in Inspector, fix that (likely mismatched CBUFFER). Batching won’t make it compute faster, but it reduces overhead if you have multiple materials using the shader.
- **Limit on-screen usage:** If performance is borderline, you can design the world so that the shader isn’t covering the entire view all the time. Maybe it’s in a specific area or can be turned off. Also consider using **occlusion culling** – if the fractal sphere is outside the room, when people go indoors their GPU gets a break.
- **Quantum of solace – know when to stop iterating:** Shader optimization can be endless. If you reach a stable effect that runs at, say, 120 FPS on your PC and 70 FPS on a weaker PC, that might be “good enough”, given that VRChat can also be CPU bound. Sometimes obsessing over every shader millisecond yields diminishing returns. However, in VR every millisecond counts, so try to at least keep the shader under ~3-4ms on a mid-tier GPU.

**Testing with Audio:** When you add AudioLink, test the shader with actual music. Sometimes the range of values might surprise you (e.g., bass might be 0 to 5 or something if not normalized). You might need to scale or bias the values. For example, if you expect bass 0–1 but it’s actually 0–4, your effects might saturate too fast. Adjust with multiplication or use a power curve (e.g., take sqrt of amplitude for a gentler response). Also, test with different genres if possible (bass-heavy EDM vs voice-only) to ensure the visuals remain interesting in various cases.

Finally, **stay informed**. VRChat updates, Unity updates, and AudioLink updates could affect your shader. For instance, if VRChat moves to a newer Unity/URP, you’d want to adapt your shader (perhaps removing some workarounds). Keep an eye on VRChat release notes and the community forums for any changes to shader support. And if you get stuck, the community (on VRChat Ask forums or Discords for shader developers) can often help debug specific issues.

By following this guide, you should be able to convert the ShaderToy shader into Unity HLSL and deploy it in VRChat, complete with reactive audio-driven effects. It’s a challenging but rewarding process – you’ll bring a unique interactive visual to the VRChat world! Good luck, and have fun shader coding.

**Sources:**

- Unity Documentation – Built-in shader variables (e.g., _Time and _ScreenParams usage) ([Unity - Manual: Built-in shader variables reference](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html#:~:text=_Time%20float4%20Time%20since%20level,t%2F8%2C%20t%2F4%2C%20t%2F2%2C%20t)) ([Unity - Manual: Built-in shader variables reference](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html#:~:text=_ScreenParams%20float4%20,is%201.0%20%2B%201.0%2Fheight))  
- VRChat Ask Forum – Confirmation of VRChat using Built-In Render Pipeline ([Is there a comprehensive guide to VRC's engine VS PC hardware - General Discussion - VRChat Ask Forum](https://ask.vrchat.com/t/is-there-a-comprehensive-guide-to-vrcs-engine-vs-pc-hardware/16827#:~:text=VRChat%20uses%20Unity%E2%80%99s%20Builtin%20Renderer,some%20experience%20with%20graphics%20programming))  
- VRChat Creator Docs – Quest world shader guidelines (no hard limit but caution) ([Quest Content Optimization | VRChat Creation](https://creators.vrchat.com/platforms/android/quest-content-optimization/#:~:text=Shaders%20are%20not%20restricted%20for,and%20bake%20your%20lighting))  
- AudioLink Official Info – AudioLink provides audio data via a globally accessible texture ([GitHub - llealloo/audiolink: Audio reactive prefabs for VRChat](https://github.com/llealloo/audiolink#:~:text=The%20per,world%20and%20across%20all%20avatars)) ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=sampler2D%20_AudioTexture%3B))  
- Unity URP Shader Example – Basic unlit URP shader structure from Unity’s manual ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=%2F%2F%20a%20pass%20is%20executed,)) ([URP unlit basic shader | Universal RP | 8.2.0 ](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@8.2/manual/writing-shaders-urp-basic-unlit-structure.html#:~:text=%2F%2F%20The%20HLSL%20code%20block,pragma%20fragment%20frag))  
- AudioLink Shader Macro Example – Community AudioLink.cginc showing texture sampling macros ([CasToon/AudioLink.cginc at main · CascadianVR/CasToon · GitHub](https://github.com/CascadianVR/CasToon/blob/main/AudioLink.cginc#:~:text=sampler2D%20_AudioTexture%3B)).