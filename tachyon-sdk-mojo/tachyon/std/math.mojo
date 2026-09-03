from .lib.ffi import GLSL_std_450_op_call


@always_inline
def sin(x: Float32) -> Float32:
    """Berechnet den Sinus hardwarebeschleunigt über GLSL (OpCode 13)."""
    return GLSL_std_450_op_call[13, Float32](x)

@always_inline
def cos(x: Float32) -> Float32:
    """Berechnet den Kosinus hardwarebeschleunigt über GLSL (OpCode 14)."""
    return GLSL_std_450_op_call[14, Float32](x)

@always_inline
def pow(x: Float32, y: Float32) -> Float32:
    """Berechnet x hoch y hardwarebeschleunigt über GLSL (OpCode 26)."""
    return GLSL_std_450_op_call[26, Float32](x, y)
