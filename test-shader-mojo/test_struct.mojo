from tachyon import Vec4, Float

struct Uniforms:
    var GameTime: Float

@export
def mojo_main(color: Vec4, env: Uniforms) -> Vec4:
    return color
