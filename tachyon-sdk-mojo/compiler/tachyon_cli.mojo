import sys
from python import Python

def run_command(cmd: List[String]) raises:
    var subprocess = Python.import_module("subprocess")
    var py_cmd = Python.list()
    var cmd_str = String("")
    for i in range(len(cmd)):
        py_cmd.append(cmd[i])
        cmd_str += cmd[i] + " "
    
    print("Run:", cmd_str)
    
    _ = subprocess.run(py_cmd, check=True)

def patch_llvm_ir(filepath: String) raises:
    var builtins = Python.import_module("builtins")
    var f_in = builtins.open(filepath, "r")
    var content: String = f_in.read()
    f_in.close()
    
    content = content.replace("x86_64-unknown-linux-gnu", "spir64-unknown-unknown")
    
    var f_out = builtins.open(filepath, "w")
    f_out.write(content)
    f_out.close()

def patch_spirv_asm(filepath: String) raises:
    var builtins = Python.import_module("builtins")
    var re = Python.import_module("re")
    
    var f_in = builtins.open(filepath, "r")
    var content: String = f_in.read()
    f_in.close()

    content = content.replace("OpMemoryModel Physical64 OpenCL", "OpMemoryModel Logical GLSL450")
    content = content.replace("OpCapability Addresses\n", "")
    content = content.replace("OpCapability Kernel\n", "")
    content = content.replace("OpCapability Int64\n", "")
    
    content = str(re.sub(r'^\s*%\d+\s*=\s*OpExtInstImport\s+"OpenCL\.std"\n', "", content, flags=re.MULTILINE))
    content = str(re.sub(r'^\s*OpDecorate\s+%\d+\s+Alignment\s+\d+\n', "", content, flags=re.MULTILINE))
    content = str(re.sub(r'^\s*OpLifetimeStart\s+%\d+\s+\d+\n', "", content, flags=re.MULTILINE))
    content = str(re.sub(r'^\s*OpLifetimeStop\s+%\d+\s+\d+\n', "", content, flags=re.MULTILINE))

    var f_out = builtins.open(filepath, "w")
    f_out.write(content)
    f_out.close()

def main() raises:
    var args = sys.argv()
    if len(args) < 2:
        print("Usage: tachyon_cli <shader.mojo> [-o <output.spv>]")
        return
        
    var shader_file = args[1]
    var out_file = "tachyon_post.spv"
    
    if len(args) >= 4:
        if args[2] == "-o":
            out_file = args[3]
    
    var os = Python.import_module("os")
    var sdk_dir = os.path.dirname(os.path.dirname(os.path.abspath(args[0])))
    var template_path = os.path.join(sdk_dir, "templates", "wrapper_base.spvasm")
    var tachyon_lib = sdk_dir
    
    print("=================================")
    print(" TACHYON MOJO -> SPIR-V COMPILER ")
    print("=================================")
    
    print("[1/5] Compiling Mojo to LLVM IR...")
    var cmd1 = List[String]("mojo", "build", "-I", str(tachyon_lib), shader_file, "--emit=llvm", "-o", "shader.ll")
    run_command(cmd1)
    
    print("[2/5] Patching Target Triple and Assembling to SPIR-V...")
    patch_llvm_ir("shader.ll")
    
    var cmd2 = List[String]("opt", "-O3", "shader.ll", "-o", "shader.bc")
    run_command(cmd2)
    
    var cmd3 = List[String]("llvm-spirv", "shader.bc", "-o", "shader.spv")
    run_command(cmd3)
    
    print("[3/5] Adapting Memory Model for OpenGL...")
    var cmd4 = List[String]("spirv-dis", "shader.spv", "-o", "shader.spvasm")
    run_command(cmd4)
    
    patch_spirv_asm("shader.spvasm")
    
    var cmd5 = List[String]("spirv-as", "shader.spvasm", "-o", "shader_logical.spv")
    run_command(cmd5)
    
    print("[4/5] Building GLSL Wrapper...")
    var cmd6 = List[String]("spirv-as", str(template_path), "-o", "wrapper_manual.spv")
    run_command(cmd6)
    
    print("[5/5] Linking Mojo Core with GLSL Wrapper...")
    var cmd7 = List[String]("spirv-link", "shader_logical.spv", "wrapper_manual.spv", "-o", out_file)
    run_command(cmd7)
    
    print("[6/6] Validating Final Shader...")
    var cmd8 = List[String]("spirv-val", "--target-env", "opengl4.0", out_file)
    run_command(cmd8)
    
    # Cleanup
    var files_to_remove = List[String]("shader.ll", "shader.bc", "shader.spv", "shader.spvasm", "shader_logical.spv", "wrapper_manual.spv")
    for i in range(len(files_to_remove)):
        try:
            os.remove(files_to_remove[i])
        except:
            pass
            
    print("=================================")
    print(" SUCCESS! Shader is ready.       ")
    print("=================================")
