import re

with open("shader.spvasm", "r") as f:
    data = f.read()

# Change Memory Model
data = data.replace("OpMemoryModel Physical64 OpenCL", "OpMemoryModel Logical GLSL450")
data = data.replace("OpCapability Addresses\n", "")
data = data.replace("OpCapability Kernel\n", "")
data = data.replace("OpCapability Int64\n", "")
data = re.sub(r'^\s*%\d+\s*=\s*OpExtInstImport\s+"OpenCL\.std"\n', '', data, flags=re.MULTILINE)

# Remove Alignment decorations (only valid for Kernel capability)
data = re.sub(r'^\s*OpDecorate\s+%\d+\s+Alignment\s+\d+\n', '', data, flags=re.MULTILINE)
# Remove Lifetime markers
data = re.sub(r'^\s*OpLifetimeStart\s+%\d+\s+\d+\n', '', data, flags=re.MULTILINE)
data = re.sub(r'^\s*OpLifetimeStop\s+%\d+\s+\d+\n', '', data, flags=re.MULTILINE)

with open("shader_logical.spvasm", "w") as f:
    f.write(data)
