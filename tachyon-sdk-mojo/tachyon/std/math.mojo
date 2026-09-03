from sys.ffi import external_call

# ==============================================================================
# TACHYON COMPILER MAGIC
# ==============================================================================
# Diese Funktionen rufen Fake-Funktionen namens "tachyon_extinst_X" auf.
# Unser Python-Postprozessor in __init__.mojo fängt diese Aufrufe ab und
# ersetzt sie direkt durch die nativen GLSL.std.450 OpCodes, ohne den Umweg
# über OpenCL nehmen zu müssen!
# ==============================================================================

def _GLSL_std_450_op_call[op_code: Int32, RType](*args) -> RType:
    """Ruft einen GLSL.std.450 OpCode hardwarebeschleunigt auf."""
    return external_call[f"tachyon_extinst_{op_code}", RType](*args)

@always_inline
def sin(x: Float32) -> Float32:
    """Berechnet den Sinus hardwarebeschleunigt über GLSL (OpCode 13)."""
    return _GLSL_std_450_op_call[13, Float32](x)

@always_inline
def cos(x: Float32) -> Float32:
    """Berechnet den Kosinus hardwarebeschleunigt über GLSL (OpCode 14)."""
    return _GLSL_std_450_op_call[14, Float32](x)

@always_inline
def pow(x: Float32, y: Float32) -> Float32:
    """Berechnet x hoch y hardwarebeschleunigt über GLSL (OpCode 26)."""
    return _GLSL_std_450_op_call[26, Float32](x, y)
