# Skalare
comptime Float = Float32
comptime Int = Int32
comptime UInt = UInt32
comptime Bool = __type_of(True)

# Float Vektoren (vec2, vec3, vec4)
comptime Vec2 = SIMD[DType.float32, 2]
comptime Vec3 = SIMD[DType.float32, 3]
comptime Vec4 = SIMD[DType.float32, 4]

# Integer Vektoren (ivec2, ivec3, ivec4)
comptime IVec2 = SIMD[DType.int32, 2]
comptime IVec3 = SIMD[DType.int32, 3]
comptime IVec4 = SIMD[DType.int32, 4]

# Unsigned Integer Vektoren (uvec2, uvec3, uvec4)
comptime UVec2 = SIMD[DType.uint32, 2]
comptime UVec3 = SIMD[DType.uint32, 3]
comptime UVec4 = SIMD[DType.uint32, 4]

# Boolean Vektoren (bvec2, bvec3, bvec4)
comptime BVec2 = SIMD[DType.bool, 2]
comptime BVec3 = SIMD[DType.bool, 3]
comptime BVec4 = SIMD[DType.bool, 4]

# Matrizen (mat2, mat3, mat4) 
# In SPIR-V sind Matrizen oft Arrays/Structs aus Spalten-Vektoren (Column-Major).
# Wir bilden sie als Structs ab, die sich genau wie GLSL-Matrizen verhalten.
@value
struct Mat2:
    var c0: Vec2
    var c1: Vec2

@value
struct Mat3:
    var c0: Vec3
    var c1: Vec3
    var c2: Vec3

@value
struct Mat4:
    var c0: Vec4
    var c1: Vec4
    var c2: Vec4
    var c3: Vec4