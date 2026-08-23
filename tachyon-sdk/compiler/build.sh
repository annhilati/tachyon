#!/bin/bash
set -e

# Wir gehen davon aus, dass wir aus dem Workspace (z.B. test-shader) aufgerufen werden
SHADER_FILE="shader.mojo"
SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_PATH="$SDK_DIR/templates/wrapper_base.spvasm"
TACHYON_LIB="$SDK_DIR"

echo "================================="
echo " TACHYON MOJO -> SPIR-V COMPILER "
echo "================================="

echo "[1/5] Compiling Mojo to LLVM IR..."
mojo build -I "$TACHYON_LIB" "$SHADER_FILE" --emit=llvm -o shader.ll

echo "[2/5] Patching Target Triple and Assembling to SPIR-V..."
sed 's/x86_64-unknown-linux-gnu/spir64-unknown-unknown/g' shader.ll > shader_spirv.ll
opt -O3 shader_spirv.ll -o shader.bc
llvm-spirv shader.bc -o shader.spv

echo "[3/5] Adapting Memory Model for OpenGL..."
spirv-dis shader.spv -o shader.spvasm
python3 "$SDK_DIR/compiler/fix_memory_model.py" shader.spvasm shader_logical.spvasm
spirv-as shader_logical.spvasm -o shader_logical.spv

echo "[4/5] Building GLSL Wrapper..."
spirv-as "$TEMPLATE_PATH" -o wrapper_manual.spv

echo "[5/5] Linking Mojo Core with GLSL Wrapper..."
spirv-link shader_logical.spv wrapper_manual.spv -o tachyon_post.spv

echo "[6/6] Validating Final Shader..."
spirv-val --target-env opengl4.0 tachyon_post.spv

echo "[Deploy] Cleaning up and Copying..."
cp tachyon_post.spv dummy/post_desaturate.spv
rm -f shader.ll shader_spirv.ll shader.bc shader.spv shader.spvasm shader_logical.spvasm shader_logical.spv wrapper_manual.spv

echo "================================="
echo " SUCCESS! Shader is ready.       "
echo "================================="
