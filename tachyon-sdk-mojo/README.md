## Compilation Pipeline

```mermaid
flowchart TD
    subgraph Mojo ["Mojo Compilation"]
        M1[shader.mojo] -->|mojo build --emit=llvm| M2(shader.ll)
        M2 -->|opt -O3| M3(shader.bc)
        M3 -->|llvm-spirv| M4(shader.spv)
    end

    subgraph Transport ["LLVM Transport Layer"]
        T1[wrapper.ll] -->|opt -O3| T2(wrapper.bc)
        T2 -->|llvm-spirv| T3(wrapper_raw.spv)
    end

    subgraph GLSL ["GLSL Compilation"]
        R1[runtime.vert<br>runtime.frag] -->|glslangValidator| R2(runtime.vert.spv<br>runtime.frag.spv)
    end
    
    subgraph Patching ["Compatability Patching"]
        M4 -->|spirv-dis| P1(shader.spvasm)
        R2 -->|spirv-dis| R3(runtime.vert.spvasm<br>runtime.frag.spvasm)
        T3 -->|spirv-dis| P2(wrapper_raw.spvasm)
    end
    
    subgraph Linking ["SPIR-V Linking (spirv-link)"]
        P1 -->|spirv-as| L1(shader_logical.spv)
        R3 -->|spirv-as| L2(runtime.vert.manual.spv<br>runtime.frag.manual.spv)
        P2 -->|spirv-as| L3(wrapper.spv)
        L1 --> LF(Final shader.spv)
        L2 --> LF
        L3 --> LF
    end
```
<!-- ### The LLVM Transport Layer (`wrapper.ll`)
Mojo (via LLVM-SPIRV) expects function arguments to be passed by **value** (e.g., `<4 x float>`), while OpenGL/GLSL passes variables between shader stages by **pointer**. 
To resolve this ABI mismatch without manually writing SPIR-V assembly, we use `wrapper.ll`. This small LLVM IR file acts as a transport layer: it takes the pointer arguments provided by GLSL, loads their values, and passes them to the pure Mojo function. It is compiled and linked directly into the final SPIR-V binary. -->

## Layers
