from tachyon import *

@export
def mojo_main(color: Vec4, time: Float, weights: Vec4) abi("C") -> Vec4:
    var gray = (color[0] + color[1] + color[2]) * weights[0]
    var wobble = gray * time
    
    return Vec4(wobble, wobble, wobble, 1.0)
