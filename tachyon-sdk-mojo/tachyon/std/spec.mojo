from sys.ffi import external_call

@always_inline
def hash_spec_name(name: StringLiteral) -> Int32:
    """Konvertiert einen String (defV-1a) in eine deterministische 32-Bit ID."""
    var hash: UInt32 = 2166136261
    var prime: UInt32 = 16777619
    var s = StringRef(name)
    for i in range(len(s)):
        hash ^= s[i].cast[DType.uint32]()
        hash &*= prime
    
    # Positive 32-Bit Integer maskieren
    return (hash & 0x7FFFFFFF).cast[DType.int32]()


@always_inline
def spec_constant[type: DType](name: StringLiteral, default_val: SIMD[type, 1]) -> SIMD[type, 1]:
    var id = hash_spec_name(name)

    comptime if type == DType.float32:
        return external_call["_Z20__spirv_SpecConstantif", Float32](id, default_val)
    elif type == DType.int32:
        return external_call["_Z20__spirv_SpecConstantii", Int32](id, default_val)
    elif type == DType.bool:
        return external_call["_Z20__spirv_SpecConstantib", Bool](id, default_val)
    else:
        return default_val
