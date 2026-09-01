# Tachyon Project

### Subprojects

- **Tachyon** Mod: Fabric Mod that can load SPIR-V-shaders
- **Tachyon Mojo SDK**: Mojo library for writing and compiling SPIR-V shaders

## Specs

**A shader ("shaderpack")**
```yaml
shaderpacks
├── example-shader.zip          # can also be an un-zipped folder
│   ├── assets/                 # 
│   │   └── ...
│   ├── settings.yml            # 
│   └── shader.spv              # 
└── example-shader.yml          # generated, only contains overrides
```

**A shader settings.yml**
```yaml
constants:              # SPIR-V specialization constants
    shadow_resolution:
        type: uint      # only bool, int, uint and float are allowed. TODO: complex types for the settings GUI
        input: slider   # box, slider, restricted_slider
        name: "Shadow Resolution"
        values:         # either range or options, can also provide display names here
            - 16: "low"
            - 64: "medium"
            - 256: "high"
            - 1024: "very high"
            - 2048: "ultra"
        default: 1024
```

**A shader language file**
```yaml
random_constant: Zufällige Konstante    # Shorthand
shadow_resolution:
    name: "Schattenqualität"
    values:
        16: "niedrig"
        64: "mittel"
        256: "hoch"
        1024: "sehr hoch"
        2048: "ultra"
```