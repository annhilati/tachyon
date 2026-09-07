## Compilation Pipeline

```mermaid
flowchart TD
    subgraph Mojo ["Mojo Compilation"]
        M1[shader.mojo] -->|mojo build --emit=llvm| M2
        M2(shader.ll) -->|opt -O3| M3
        M3(shader.bc) -->|llvm-spirv| M4(shader.spv)
    end

    subgraph Transport ["LLVM Transport Layer"]
        T1[p2v_adapter.ll] -->|opt -O3| T2
        T2(p2v_adapter.bc) -->|llvm-spirv| T3(p2v_adapter_raw.spv)
    end

    subgraph GLSL ["GLSL Compilation"]
        R1[runtime.vert<br>runtime.frag] -->|glslangValidator| R2(runtime.vert.spv<br>runtime.frag.spv)
    end
    
    subgraph Patching ["Compatability Patching"]
        M4 -->|spirv-dis| P1(shader.spvasm)
        R2 -->|spirv-dis| R3(runtime.vert.spvasm<br>runtime.frag.spvasm)
        T3 -->|spirv-dis| P2(p2v_adapter_raw.spvasm)
    end
    
    subgraph Linking ["SPIR-V Linking (spirv-link)"]
        P1 -->|spirv-as| L1
        R3 -->|spirv-as| L2
        P2 -->|spirv-as| L3
        L1(shader_logical.spv) --> LF(Final shader.spv)
        L2(runtime.vert.manual.spv<br>runtime.frag.manual.spv) --> LF
        L3(p2v_adapter.spv) --> LF
    end
```
<!-- ### The LLVM Transport Layer (`wrapper.ll`)
Mojo (via LLVM-SPIRV) expects function arguments to be passed by **value** (e.g., `<4 x float>`), while OpenGL/GLSL passes variables between shader stages by **pointer**. 
To resolve this ABI mismatch without manually writing SPIR-V assembly, we use `wrapper.ll`. This small LLVM IR file acts as a transport layer: it takes the pointer arguments provided by GLSL, loads their values, and passes them to the pure Mojo function. It is compiled and linked directly into the final SPIR-V binary. -->

## Layers
Layers will merge in the build process. This diagramm shows how function definitions will interact.

```mermaid
flowchart TD
    subgraph Mod ["Tachyon Mod"]
        M(post_effect::tachyon:main) -->|"provides runtime values"| d
        shader.yml <-- Settings
    end

    subgraph Shader
        runtime.frag
        shader.yml -->|spec consts| Mojo
        runtime.vert --> Mojo
        Mojo[shader.mojo::tachyon_main]
        Settings[settings.yml]
    end
```
