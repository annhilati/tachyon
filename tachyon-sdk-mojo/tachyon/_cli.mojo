import sys

from .compiler.__init__ import compile

def main() raises:
    
    var args = sys.argv()
    if len(args) < 2:
        print("Usage: tachyon_cli <shader.mojo> [-o <output.spv>]")
        return

    compile(args[1], args[3] if len(args) >= 4 and args[2] == "-o" else "tachyon_post.spv")