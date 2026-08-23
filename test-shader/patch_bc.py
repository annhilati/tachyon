with open("shader.bc", "rb") as f:
    data = f.read()

# Replace exactly 24 bytes
old_triple = b"x86_64-unknown-linux-gnu"
new_triple = b"spir64-unknown-unknown\0\0\0" # we need exact length match, maybe nulls?
if len(new_triple) > len(old_triple):
    new_triple = new_triple[:len(old_triple)]
elif len(new_triple) < len(old_triple):
    new_triple = new_triple.ljust(len(old_triple), b'\0')

data = data.replace(old_triple, new_triple)

with open("shader_spirv.bc", "wb") as f:
    f.write(data)
