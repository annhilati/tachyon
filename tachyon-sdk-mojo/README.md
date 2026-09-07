## Compilation Pipeline

```mermaid
flowchart TD
    subgraph Mojo ["Mojo Compilation"]
        M1[\shader.mojo/] -->|mojo build --emit=llvm<br>+ patching target architecture| M2
        M2(shader.ll) -->|opt -O3| M3
        M3(shader.bc) -->|llvm-spirv| M4(shader.spv)
    end

    subgraph Adapter ["LLVM Adapter"]
        T1[p2v_adapter.ll] -->|opt -O3| T2
        T2(p2v_adapter.bc) -->|llvm-spirv| T3(p2v_adapter_raw.spv)
    end

    subgraph GLSL ["GLSL Compilation"]
        R1[runtime.vert<br>runtime.frag] -->|glslangValidator| R2(runtime.vert.spv<br>runtime.frag.spv)
    end
    
    subgraph Patching ["Compatability Patching"]
        M4 -->|spirv-dis| P1(shader.spvasm)
        T3 -->|spirv-dis| P2(p2v_adapter_raw.spvasm)
        R2 -->|spirv-dis| R3(runtime.vert.spvasm<br>runtime.frag.spvasm)
    end
    
    subgraph Linking ["SPIR-V Linking (spirv-link)"]
        P1 -->|spirv-as| L1(shader_logical.spv)
        P2 -->|spirv-as| L3(p2v_adapter.spv)
        R3 -->|spirv-as| L2(runtime.vert.manual.spv<br>runtime.frag.manual.spv)
        L1 --> LF(Final shader.spv)
        L3 --> LF
        L2 --> LF
    end
```


## Layers
Layers will merge in the build process. This diagram shows the complete control flow (nested function calls) and data flow (how Java provides data to the shader).

```mermaid
flowchart TD
    %% Data Providers (Java)
    subgraph Mod ["Tachyon Mod (Java)"]
        JSON[post_effect tachyon:main] -->|defines uniforms| Pass
        Pass[PostPassTimeMixin] -->|extracts UBO handle| State[TachyonState]
        State -.-> Encoder
        Encoder[GlCommandEncoderMixin] -->|force-binds UBO| GL[OpenGL State]
    end

    %% Environment & Inputs
    subgraph Context ["Shader Data Context"]
        GL -->|binding = 0| UBO[(TachyonGlobals UBO)]
        GL -->|binding = 0| Sampler[(InSampler Texture)]
        Settings[settings.yml] -.->|compiles to| SpecConsts([Specialization Constants])
    end

    %% Shader Execution Flow
    subgraph Shader ["Shader Execution Layers"]
        
        subgraph GLSL ["GLSL Runtime Layer"]
            VertGLSL["runtime.vert :: main()"]
            FragGLSL["runtime.frag :: main()"]
        end
        
        subgraph Transport ["LLVM Transport Layer (p2v_adapter.ll)"]
            VertAdapter["tachyon_vert_main_ptr(vec4*, vec2*, float*)"]
            FragAdapter["tachyon_main_ptr(vec4*, float*)"]
        end
        
        subgraph Core ["Mojo Core Logic (shader.mojo)"]
            MojoVert["tachyon_vert_main(vec4, vec2, float)"]
            MojoFrag["tachyon_main(vec4, float)"]
        end
        
        %% Data dependencies
        UBO -.->|Time| VertGLSL
        UBO -.->|Time| FragGLSL
        Sampler -.->|Color| FragGLSL
        SpecConsts -.->|Settings| MojoFrag
        
        %% Control flow (Function calls)
        VertGLSL ==>|calls| VertAdapter
        VertAdapter ==>|dereferences & calls| MojoVert
        
        FragGLSL ==>|calls| FragAdapter
        FragAdapter ==>|dereferences & calls| MojoFrag
    end
```
