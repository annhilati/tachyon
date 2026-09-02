from tachyon import *

@export
def tachyon_main(color: Vec4, time: Float) abi("C") -> Vec4:
    # --- Settings (Statisch, kompiliert) ---
    var enable_wobble = spec_constant_bool("ENABLE_WOBBLE", True)
    var intensity = spec_constant_float("INTENSITY", 0.333)
    
    # --- Shader Logik ---
    if enable_wobble:
        var gray = (color[0] + color[1] + color[2]) * intensity
        # Time ist Live-Data aus Java
        var wobble = gray * (1.0 + sin(time) * 0.2) 
        return Vec4(wobble, wobble, wobble, 1.0)
    
    return color
