from sys.ffi import external_call

@always_inline
fn sin(x: Float32) -> Float32:
    """Berechnet den Sinus hardwarebeschleunigt über GLSL."""
    return external_call["tachyon_sin", Float32](x)

@always_inline
fn cos(x: Float32) -> Float32:
    """Berechnet den Kosinus hardwarebeschleunigt über GLSL."""
    return external_call["tachyon_cos", Float32](x)
