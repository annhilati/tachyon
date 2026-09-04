from sys.ffi import external_call


# ==============================================================================
# TACHYON COMPILER MAGIC
# ==============================================================================
# Diese Funktionen rufen Fake-Funktionen namens "tachyon_extinst_X" auf.
# Unser Python-Postprozessor in __init__.mojo fängt diese Aufrufe ab und
# ersetzt sie direkt durch die nativen GLSL.std.450 OpCodes, ohne den Umweg
# über OpenCL nehmen zu müssen!
# ==============================================================================

def GLSLstd450_op_call[op_code: Int32, RType](*args) -> RType:
    """Reserves an GLSL.std.450 OpCode call for the Tachyon compiler to replace with the actual GLSL instruction.
    
    See the GLSL.std.450 specification for the list of available OpCodes at
    [KhronosGroup/SPIRV-Headers/include/spirv/unified1/GLSL.std.450.h](https://github.com/KhronosGroup/SPIRV-Headers/blob/main/include/spirv/unified1/GLSL.std.450.h).
    """
    comptime cmd = "tachyon_extinst_" + str(op_code)
    return external_call[cmd, RType](*args)