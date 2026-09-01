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

def patch_spirv_wrapper(filepath: String, function_name: String) raises:
    var builtins = Python.import_module("builtins")
    var re = Python.import_module("re")
    
    var f_in = builtins.open(filepath, "r")
    var content: String = f_in.read()
    f_in.close()
    
    # Add Import Decorator
    var pattern1 = r'(OpName %' + function_name + r' "' + function_name + r'"\n)'
    var repl1 = r'\1               OpDecorate %' + function_name + r' LinkageAttributes "' + function_name + r'" Import\n'
    content = str(re.sub(pattern1, repl1, content))
    
    # Strip body
    var pattern2 = r'(%' + function_name + r' = OpFunction.*?\n(?:.*?OpFunctionParameter.*?\n)*?)(?:\s*%\d+\s*=\s*OpLabel.*?\n)(?:.*?\n)*?(?=\s*OpFunctionEnd)'
    content = str(re.sub(pattern2, r'\1', content, flags=re.DOTALL))
    
    var f_out = builtins.open(filepath, "w")
    f_out.write(content)
    f_out.close()

def compile(cli_path: String, input: String, output_dir: String = "shader", do_zip: Bool = False) raises:
    var shader_file = input
        
    var os = Python.import_module("os")
    
    # Create the output directory
    os.makedirs(output_dir, exist_ok=True)
    var out_file = os.path.join(output_dir, "shader.spv")
    
    # Make this path resolving safe
    var sdk_dir = os.path.dirname(os.path.dirname(os.path.abspath(cli_path)))
    var template_frag = os.path.join(sdk_dir, "compiler", "wrapper.frag")
    var tachyon_lib = sdk_dir
    
    print("=================================")
    print(" TACHYON MOJO -> SPIR-V COMPILER ")
    print("=================================")
    
    print("[1/6] Compiling Mojo to LLVM IR...")
    var cmd1 = List[String]("mojo", "build", "-I", str(tachyon_lib), shader_file, "--emit=llvm", "-o", "shader.ll")
    run_command(cmd1)
    
    print("[2/6] Patching Target Triple and Assembling to SPIR-V...")
    patch_llvm_ir("shader.ll")
    
    var cmd2 = List[String]("opt", "-O3", "shader.ll", "-o", "shader.bc")
    run_command(cmd2)
    
    var cmd3 = List[String]("llvm-spirv", "shader.bc", "-o", "shader.spv")
    run_command(cmd3)
    
    print("[3/6] Adapting Memory Model for OpenGL...")
    var cmd4 = List[String]("spirv-dis", "shader.spv", "-o", "shader.spvasm")
    run_command(cmd4)
    
    patch_spirv_asm("shader.spvasm")
    
    var cmd5 = List[String]("spirv-as", "shader.spvasm", "-o", "shader_logical.spv")
    run_command(cmd5)
    
    print("[4/6] Building and Patching GLSL Wrappers...")
    var template_frag = os.path.join(sdk_dir, "compiler", "wrapper.frag")
    var template_vert = os.path.join(sdk_dir, "compiler", "wrapper.vert")
    
    # --- Fragment Wrapper ---
    var cmd6 = List[String]("glslangValidator", "-V", str(template_frag), "-o", "wrapper_raw.spv")
    run_command(cmd6)
    
    var cmd6a = List[String]("spirv-dis", "wrapper_raw.spv", "-o", "wrapper_raw.spvasm")
    run_command(cmd6a)
    
    patch_spirv_wrapper("wrapper_raw.spvasm", "tachyon_main")
    
    var cmd6b = List[String]("spirv-as", "wrapper_raw.spvasm", "-o", "wrapper_manual.spv")
    run_command(cmd6b)
    
    # --- Vertex Wrapper ---
    var cmd6c = List[String]("glslangValidator", "-V", str(template_vert), "-o", "wrapper_vert_raw.spv")
    run_command(cmd6c)
    
    var cmd6d = List[String]("spirv-dis", "wrapper_vert_raw.spv", "-o", "wrapper_vert_raw.spvasm")
    run_command(cmd6d)
    
    patch_spirv_wrapper("wrapper_vert_raw.spvasm", "tachyon_vert_main")
    
    var cmd6e = List[String]("spirv-as", "wrapper_vert_raw.spvasm", "-o", "wrapper_vert_manual.spv")
    run_command(cmd6e)
    
    print("[5/6] Linking Mojo Core with GLSL Wrappers...")
    # Link Everything into a single SPV module (SPIR-V supports multiple entry points!)
    var cmd7 = List[String]("spirv-link", "shader_logical.spv", "wrapper_manual.spv", "wrapper_vert_manual.spv", "-o", out_file)
    run_command(cmd7)
    
    print("[6/6] Validating Final Shader...")
    var cmd8 = List[String]("spirv-val", "--target-env", "opengl4.0", out_file)
    run_command(cmd8)
    
    # Cleanup
    var files_to_remove = List[String]("shader.ll", "shader.bc", "shader.spv", "shader.spvasm", "shader_logical.spv", "wrapper_raw.spv", "wrapper_raw.spvasm", "wrapper_manual.spv", "wrapper_vert_raw.spv", "wrapper_vert_raw.spvasm", "wrapper_vert_manual.spv")
    for i in range(len(files_to_remove)):
        try:
            os.remove(files_to_remove[i])
        except:
            pass
            
    if do_zip:
        var shutil = Python.import_module("shutil")
        _ = shutil.make_archive(output_dir, "zip", output_dir)
        print("Zipped shaderpack into " + output_dir + ".zip")
            
    print("=================================")
    print(" SUCCESS! Shader is ready.       ")
    print("=================================")
