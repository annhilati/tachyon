comptime Float = Float32

# Vektor Typen
comptime Vec2 = SIMD[DType.float32, 2]
comptime Vec3 = SIMD[DType.float32, 3]
comptime Vec4 = SIMD[DType.float32, 4]

comptime IVec2 = SIMD[DType.int32, 2]
comptime IVec3 = SIMD[DType.int32, 3]
comptime IVec4 = SIMD[DType.int32, 4]

# Wir definieren hier ein Beispiel für das Minecraft Uniform Context Object
@value
struct MinecraftUniforms:
    var GameTime: Float
    var FogColor: Vec4
