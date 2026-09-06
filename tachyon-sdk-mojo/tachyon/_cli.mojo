from std import sys
from std.pathlib import Path
from argmojo import Argument, Command
from tachyon.compiler import compile

def cli() raises:
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

    app.add_argument(
        Argument("debug", help="Enable debug mode (compiles in current directory, preserves temp files)")
        .long["debug"]()
        .short["d"]()
        .flag()
    )

    var result = app.parse()

    var cli_path = Path(sys.argv()[0])

    var shader_path = Path(result.get_string("shader"))
    var output_dir = Path(result.get_string("output"))
    var do_zip = result.get_flag("zip")
    var do_debug = result.get_flag("debug")
    
    compile(cli_path, shader_path, output_dir, do_zip, do_debug)