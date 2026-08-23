import re

with open("wrapper.spvasm", "r") as f:
    lines = f.readlines()

# 1. Find the mangled name for mojo_main
mangled_name = None
for line in lines:
    match = re.search(r'OpName (%[^\s]+) "mojo_main\(', line)
    if match:
        mangled_name = match.group(1)
        break

if not mangled_name:
    print("Error: Could not find mojo_main in spvasm.")
    exit(1)

# 2. Replace mangled name with %mojo_main
for i in range(len(lines)):
    lines[i] = lines[i].replace(mangled_name + " ", "%mojo_main ")
    lines[i] = lines[i].replace(mangled_name + "\n", "%mojo_main\n")

# 3. Insert LinkageAttributes Import
decorate_idx = -1
for i, line in enumerate(lines):
    if "OpDecorate" in line:
        decorate_idx = i
if decorate_idx != -1:
    lines.insert(decorate_idx + 1, f'                 OpDecorate %mojo_main LinkageAttributes "mojo_main" Import\n')

# 4. Remove the body of mojo_main
in_mojo_main = False
has_removed_label = False
new_lines = []
for line in lines:
    if "%mojo_main = OpFunction " in line:
        in_mojo_main = True
        new_lines.append(line)
        continue
    
    if in_mojo_main:
        if "OpFunctionParameter" in line:
            new_lines.append(line)
        elif "OpFunctionEnd" in line:
            new_lines.append(line)
            in_mojo_main = False
        else:
            # Skip everything else (OpLabel, OpReturnValue, etc.)
            pass
    else:
        new_lines.append(line)

with open("wrapper_patched.spvasm", "w") as f:
    f.writelines(new_lines)
