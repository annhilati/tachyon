with open('tachyon/compiler/__init__.mojo', 'r') as f:
    content = f.read()

# Replace the tachyon_lib assignment
content = content.replace(
    'var tachyon_lib = String(Python.import_module(" os\).path.dirname(String(cli_path.__fspath__())))
