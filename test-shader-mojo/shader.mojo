from tachyon import *


@export
def tachyon_main(color: Vec4, time: Float) abi("C") -> Vec4:
    # --- Settings (Statisch, kompiliert) ---
    var enable_wobble = Option[DType.bool, "ENABLE_WOBBLE"](True)
    var intensity = Option[DType.float32, "INTENSITY"](0.375)
    
    # --- Shader Logik ---
    if enable_wobble:
        var gray = (color[0] + color[1] + color[2]) * intensity
        # Time ist Live-Data aus Java
        var wobble = gray * (Float32(1.0) + sin(time) * Float32(0.25)) 
        return Vec4(wobble, wobble, wobble, 1.0)
    
    return color
