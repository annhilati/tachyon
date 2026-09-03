import sys
from argmojo import Argument, Command
from .compiler import compile

def main() raises:
    var app = Command("tachyon", "Tachyon Mojo to SPIR-V Compiler.", version="0.1.0")

    app.add_argument(
        Argument("shader", help="Path to the shader.mojo file")
        .positional()
        .required()
    )

    app.add_argument(
        Argument("output", help="Output directory for the compiled shader")
        .long["output"]()
        .short["o"]()
        .default["shader"]()
    )

    app.add_argument(
        Argument("zip", help="Package output as a ZIP file")
        .long["zip"]()
        .short["z"]()
        .flag()
    )

    var result = app.parse()

    var shader_path = result.get_string("shader")
    var output_dir = result.get_string("output")
    var do_zip = result.get_flag("zip")
    
    var cli_path = sys.argv()[0]
    compile(cli_path, shader_path, output_dir, do_zip)