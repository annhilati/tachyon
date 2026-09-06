from tachyon import *

@export
def tachyon_main(color: Vec4, time: Float32) abi("C") -> Vec4:
    var enable_wobble = Option["ENABLE_WOBBLE", DType.bool](True)
    var intensity = Option["INTENSITY", DType.float32](0.375)
    
    var gray = (color[0] + color[1] + color[2]) * intensity
    
    var wobble = gray * (Float32(1.0) + sin(time) * Float32(0.25)) 
    return Vec4(wobble, wobble, wobble, color[3])
