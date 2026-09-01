import sys

from .compiler.__init__ import compile

def main() raises:
    var args = sys.argv()
    if len(args) < 2:
        print("Usage: tachyon_cli <shader.mojo> [-o <output_dir>] [-z]")
        return
        
    var output_dir = "shader"
    var do_zip = False
    
    var i = 2
    while i < len(args):
        if args[i] == "-o" and i + 1 < len(args):
            output_dir = args[i+1]
            i += 2
        elif args[i] == "-z" or args[i] == "--zip":
            do_zip = True
            i += 1
        else:
            i += 1

    compile(args[0], args[1], output_dir, do_zip)