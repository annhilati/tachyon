# Concept Paper: Tachyon & Iris Shaders Integration

## 1. Vision & Goal
The long-term architecture of Tachyon Shaders moves away from hacking Vanilla Minecraft's inflexible `PostPass` pipeline. Instead, we aim to establish a deep symbiosis with **Iris Shaders**. 
Iris has already built a highly optimized, state-of-the-art rendering pipeline for Minecraft (G-Buffers, Deferred Passes, Custom Uniforms, SSBOs). By hooking into Iris, we elevate Tachyon from a simple post-processing hack to a full-fledged, high-performance Shader Language (Mojo -> SPIR-V) that runs seamlessly within the Optifine/Iris ecosystem.

## 2. Shaderpack Discovery & Coexistence
Tachyon shaderpacks should be fully compatible with the Iris GUI.
- **Format:** A Tachyon pack can be a `.zip` file (or folder) containing `assets/`, `settings.yml`, and `shader.spv` (as defined in the Tachyon Mod README).
- **Integration Point:** We will mixin to Iris's `ShaderPackInfo` and `ShaderPackDirectoryManager`. When Iris scans the `shaderpacks/` folder, we intercept files ending in `.tachyon` (or zip files containing a `tachyon.json`/`settings.yml`) and register them as valid Iris shaderpacks.
- **Result:** The user can open the Iris Shader Menu and seamlessly switch between a classic GLSL shader (e.g., BSL, Complementary) and a Tachyon SPIR-V shader.

## 3. The Compilation Bypass (The Core Hack)
Iris normally loads GLSL source files (`.vsh`, `.fsh`), resolves macros, and passes the raw text to OpenGL via `glShaderSource` and `glCompileShader`.
To load our Mojo-compiled SPIR-V binaries:
1. We intercept Iris's `ProgramBuilder` or `Program` classes using Mixins.
2. When Iris attempts to compile a Tachyon shader, we **cancel** the GLSL compilation.
3. Instead, we load our pre-compiled `shader.spv` and inject it directly into the GPU using `glShaderBinary(GL_SHADER_BINARY_FORMAT_SPIR_V_ARB)`.

## 4. Bridging Metadata & Uniforms
Iris relies on parsing GLSL **text** (via its custom AST parser / JCPP) to discover which `uniform` and `sampler2D` variables a shader uses. This metadata is crucial for Iris to bind the correct Minecraft variables (like `gbufferModelView` or `shadowLightPosition`) to the shader at runtime.
- **The Problem:** SPIR-V is a binary format; Iris's text parser will fail to find any variables.
- **The Solution:** We bypass Iris's text parser. During the Mojo -> SPIR-V compilation step, our Tachyon compiler can automatically generate a lightweight metadata file (or a dummy GLSL file) containing the variable declarations. We feed this metadata to Iris's `ProgramBuilder`, allowing Iris to map all standard Optifine uniforms to our SPIR-V bindings without modifying Iris's core rendering logic.

## 5. Settings GUI & Specialization Constants
The Tachyon `settings.yml` introduces a revolutionary approach to shader settings:
- **Classic GLSL (Iris):** Changing a setting requires recompiling the entire shader from source because settings are `#define` macros.
- **Tachyon (SPIR-V):** Settings are mapped to **SPIR-V Specialization Constants** (Spec Constants). 
- **Integration:** We will intercept the Iris Settings GUI. When a user adjusts a slider (e.g., Shadow Resolution), we don't recompile the shader. Instead, we update the Spec Constant values and call `glSpecializeShaderARB`. This allows **instantaneous** setting changes without the traditional shader reload freeze!

## 6. Next Steps
1. Study the Iris source code (`.reference/iris_src`) to locate the `ShaderPack` discovery and `ProgramBuilder` compilation hooks.
2. Create a prototype Mixin that forces Iris to recognize a dummy Tachyon shaderpack.
3. Replace Iris's `glCompileShader` calls with `glShaderBinary` for Tachyon packs.
