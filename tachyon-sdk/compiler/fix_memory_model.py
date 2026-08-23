import re
import sys

if len(sys.argv) != 3:
    print("Usage: fix_memory_model.py <input.spvasm> <output.spvasm>")
    sys.exit(1)

with open(sys.argv[1], "r") as f:
    data = f.read()

data = data.replace("OpMemoryModel Physical64 OpenCL", "OpMemoryModel Logical GLSL450")
data = data.replace("OpCapability Addresses\n", "")
data = data.replace("OpCapability Kernel\n", "")
data = data.replace("OpCapability Int64\n", "")
data = re.sub(r'^\s*%\d+\s*=\s*OpExtInstImport\s+"OpenCL\.std"\n', '', data, flags=re.MULTILINE)
data = re.sub(r'^\s*OpDecorate\s+%\d+\s+Alignment\s+\d+\n', '', data, flags=re.MULTILINE)
data = re.sub(r'^\s*OpLifetimeStart\s+%\d+\s+\d+\n', '', data, flags=re.MULTILINE)
data = re.sub(r'^\s*OpLifetimeStop\s+%\d+\s+\d+\n', '', data, flags=re.MULTILINE)

with open(sys.argv[2], "w") as f:
    f.write(data)
