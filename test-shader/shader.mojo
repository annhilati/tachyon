from tachyon import Vec4

@export
def mojo_main(color: Vec4, weights: Vec4) -> Vec4:
    var gray = color[0] * weights[0] + color[1] * weights[1] + color[2] * weights[2]
    return Vec4(gray, gray, gray, weights[3])
