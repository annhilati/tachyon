from std.subprocess import run
from std.pathlib import Path
from std.python import Python
from std.os import PathLike
from std.tempfile import mkdtemp
import std.io.file as file
import std.sys as sys
import std.os as os



def compile(cli_path: Path, shader_file: Path, output_dir: Path, zip: Bool = False) raises:
    var tachyon_lib = String(Python.import_module("os").path.dirname(String(cli_path.__fspath__())))
    
    var cwd = Path()

    
    # Create the output directory
    os.makedirs(output_dir, exist_ok=True)
    var out_file = Path(String(output_dir.__fspath__()) + "/shader.spv")

    var py_os = Python.import_module("os")
    var abs_shader_file = String(py_os.path.abspath(String(shader_file.__fspath__())))
    var abs_output_dir = String(py_os.path.abspath(String(output_dir.__fspath__())))
    var abs_tachyon_lib = String(py_os.path.abspath(tachyon_lib))
    
    var temp_dir = mkdtemp()
    py_os.chdir(temp_dir)
    
    
    print("=================================")
    print(" TACHYON MOJO -> SPIR-V COMPILER ")
    print("=================================")
    
    print("Lowering Mojo to LLVM IR...")
    run_command("mojo build -I " + abs_tachyon_lib + " " + abs_shader_file + " --emit=llvm -o shader.ll")
    
    print("Patching Target Triple...")
    patch_llvm_ir("shader.ll")
    
    print("Assembling LLVM IR to LLVM Bitcode...")
    run_command("opt -O3 shader.ll -o shader.bc")
    
    print("Translating LLVM Bitcode to SPIR-V Binary...")
    run_command("llvm-spirv shader.bc -o shader.spv")
    
    print("Disassembling to SPIR-V Assembly...")
    run_command("spirv-dis shader.spv -o shader.spvasm")
    
    print("Patching compatability with OpenGL...")
    patch_spirv_asm("shader.spvasm")
    
    print("Assembling patched SPIR-V Binary...")
    run_command("spirv-as --target-env spv1.1 shader.spvasm -o shader_logical.spv")
    
    var py_shutil = Python.import_module("shutil")
    var compiler_lib_dir = abs_tachyon_lib + "/tachyon/compiler/lib"
    _ = py_shutil.copyfile(compiler_lib_dir + "/runtime.frag", "runtime.frag")
    _ = py_shutil.copyfile(compiler_lib_dir + "/runtime.vert", "runtime.vert")
    _ = py_shutil.copyfile(compiler_lib_dir + "/runtime.glsl", "runtime.glsl")

    for wrapper in ["runtime.frag", "runtime.vert"]:
        print("Compiling Runtime: " + wrapper + "...")

        print("Compiling GLSL to SPIR-V Binary")
        run_command("glslangValidator -V --target-env spirv1.1 " + wrapper + " -o " + wrapper + ".spv")
    
        print("Disassembling to SPIR-V Assembly...")
        run_command("spirv-dis " + wrapper + ".spv -o " + wrapper + ".spvasm")
    
        print("Patching compatability with OpenGL...")
        patch_spirv_wrapper(wrapper + ".spvasm", "tachyon_main") # The function specification does not work yet
    
        print("Assembling patched SPIR-V Binary...")
        run_command("spirv-as --target-env spv1.1 " + wrapper + ".spvasm -o " + wrapper + ".manual.spv")


    var abs_out_file = abs_output_dir + "/shader.spv"

    print("Linking Core Shader with Runtime...")
    run_command("spirv-link shader_logical.spv runtime.frag.manual.spv runtime.vert.manual.spv -o " + abs_out_file)
    
    print("Validating...")
    run_command("spirv-val --target-env spv1.1 " + abs_out_file)
    
    # Cleanup
    var files_to_remove = ["shader.ll", "shader.bc", "shader.spv", "shader.spvasm", "shader_logical.spv", "runtime.frag.spv", "runtime.frag.spvasm", "runtime.frag.manual.spv", "runtime.vert.spv", "runtime.vert.spvasm", "runtime.vert.manual.spv"]
    for i in range(len(files_to_remove)):
        try:
            os.remove(files_to_remove[i])
        except:
            pass
            
    if zip:
        var shutil = Python.import_module("shutil")
        _ = shutil.make_archive(output_dir.__fspath__(), "zip", output_dir.__fspath__())
        print("Zipped shaderpack into " + output_dir.__fspath__() + ".zip")
            
    print("=================================")
    print(" SUCCESS! Shader is ready.       ")
    print("=================================")


def run_command(cmd: String) raises:
    # print("Run:", cmd)
    _ = run(cmd)

def patch_llvm_ir(filepath: String) raises:
    var f_in = file.open(filepath, "r")
    var content = String(f_in.read())
    f_in.close()
    
    content = content.replace("x86_64-unknown-linux-gnu", "spir64-unknown-unknown")
    
    var f_out = file.open(filepath, "w")
    f_out.write(content)
    f_out.close()

def patch_spirv_asm(filepath: String) raises:
    var re = Python.import_module("re")
    var json = Python.import_module("json")
    
    var f_in = file.open(filepath, "r")
    var content = String(f_in.read())
    f_in.close()

    content = content.replace("OpMemoryModel Physical64 OpenCL", "OpMemoryModel Logical GLSL450")
    content = content.replace("OpCapability Addresses\n", "")
    content = content.replace("OpCapability Kernel\n", "")
    content = content.replace("OpCapability Int64\n", "")
    
    # 1. GLSL.std.450 importieren (falls es noch nicht da ist)
    if "GLSL.std.450" not in content:
        content = content.replace("OpMemoryModel Logical GLSL450\n", "OpMemoryModel Logical GLSL450\n%glsl_std_450 = OpExtInstImport \"GLSL.std.450\"\n")
    
    # OpenCL.std entfernen (brauchen wir nicht mehr, da Mojo's math lib nicht genutzt wird)
    content = String(re.sub(r'^\s*%\d+\s*=\s*OpExtInstImport\s+"OpenCL\.std"\n', "", content, flags=re.MULTILINE))
    
    # 2. Tachyon Compiler Magic auflösen (OpName %X "tachyon_extinst_Y")
    var extinst_pattern = r'OpName\s+(%\w+)\s+"tachyon_extinst_(\w+)"'
    var matches = re.findall(extinst_pattern, content)
    for i in range(len(matches)):
        var func_id = String(matches[i][0])
        var opcode = String(matches[i][1])
        
        # Aufrufe überschreiben: %res = OpFunctionCall %type %func_id %arg1 -> %res = OpExtInst %type %glsl_std_450 opcode %arg1
        var call_pattern = r'OpFunctionCall\s+(%\w+)\s+' + func_id + r'\s+(%\w+)'
        var call_repl = r'OpExtInst \g<1> %glsl_std_450 ' + opcode + r' \g<2>'
        content = String(re.sub(call_pattern, call_repl, content))
        
        # Aufrufe mit ZWEI Parametern (z.B. pow(x, y)): %res = OpFunctionCall %type %func_id %arg1 %arg2
        var call_pattern_2 = r'OpFunctionCall\s+(%\w+)\s+' + func_id + r'\s+(%\w+)\s+(%\w+)'
        var call_repl_2 = r'OpExtInst \g<1> %glsl_std_450 ' + opcode + r' \g<2> \g<3>'
        content = String(re.sub(call_pattern_2, call_repl_2, content))
        
        # Dummy-Deklaration aus der Datei löschen
        var decl_pattern = func_id + r'\s*=\s*OpFunction[\s\S]*?OpFunctionEnd\n'
        content = String(re.sub(decl_pattern, "", content))
        
        content = String(re.sub(r'^\s*OpName\s+' + func_id + r'.*\n', "", content, flags=re.MULTILINE))
        content = String(re.sub(r'^\s*OpDecorate\s+' + func_id + r'.*\n', "", content, flags=re.MULTILINE))
            
    content = String(re.sub(r'^\s*OpDecorate\s+%\d+\s+Alignment\s+\d+\n', "", content, flags=re.MULTILINE))
    content = String(re.sub(r'^\s*OpLifetimeStart\s+%\d+\s+\d+\n', "", content, flags=re.MULTILINE))
    content = String(re.sub(r'^\s*OpLifetimeStop\s+%\d+\s+\d+\n', "", content, flags=re.MULTILINE))

    var f_out = file.open(filepath, "w")
    f_out.write(content)
    f_out.close()

def patch_spirv_wrapper(filepath: String, function_name: String) raises:
    var re = Python.import_module("re")
    
    var f_in = file.open(filepath, "r")
    var content = f_in.read()
    f_in.close()
    
    # Add Import Decorator
    var pattern1 = r'(OpName %' + function_name + r' "' + function_name + r'"\n)'
    var repl1 = r'\1               OpDecorate %' + function_name + r' LinkageAttributes "' + function_name + r'" Import\n'
    content = String(re.sub(pattern1, repl1, content))
    
    # Stringip body
    var pattern2 = r'(%' + function_name + r' = OpFunction.*?\n(?:.*?OpFunctionParameter.*?\n)*?)(?:\s*%\d+\s*=\s*OpLabel.*?\n)(?:.*?\n)*?(?=\s*OpFunctionEnd)'
    content = String(re.sub(pattern2, r'\1', content, flags=re.DOTALL))
    
    var f_out = file.open(filepath, "w")
    f_out.write(content)
    f_out.close()
