from sys.ffi import external_call

@always_inline
def _FNV_1a(s: StringLiteral) -> UInt32:
    var hash: UInt32 = 2166136261
    var prime: UInt32 = 16777619
    
    var s = StringRef(s)
    var ptr = s.data()
    
    for i in range(len(s)):
        hash ^= ptr[i].cast[DType.uint32]()
        hash &*= prime
    
    return hash


@always_inline
def Option[type: DType, name: StringLiteral](default: SIMD[type, 1]) -> SIMD[type, 1]:
    """Registers an variable open to the shader settings.
    
    The variables used here are SPIR-V specialization constants.
    """
    var id = _FNV_1a(name)

    comptime if type == DType.float32:
        return external_call["_Z20__spirv_SpecConstantif", Float32](id, default)
    elif type == DType.int32:
        return external_call["_Z20__spirv_SpecConstantii", Int32](id, default)
    elif type == DType.bool:
        return external_call["_Z20__spirv_SpecConstantib", Bool](id, default)
    else:
        raise
