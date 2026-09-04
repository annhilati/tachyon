from .lib.ffi import GLSLstd450_op_call


@always_inline
def sin(x: Float32) -> Float32:
    """Berechnet den Sinus hardwarebeschleunigt über GLSL (OpCode Sin)."""
    return GLSLstd450_op_call["Sin", Float32](x)

@always_inline
def cos(x: Float32) -> Float32:
    """Berechnet den Kosinus hardwarebeschleunigt über GLSL (OpCode Cos)."""
    return GLSLstd450_op_call["Cos", Float32](x)

@always_inline
def pow(x: Float32, y: Float32) -> Float32:
    """Berechnet x hoch y hardwarebeschleunigt über GLSL (OpCode Pow)."""
    return GLSLstd450_op_call["Pow", Float32](x, y)
