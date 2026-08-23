#!/bin/bash
set -e

echo "================================="
echo " TACHYON MOJO -> SPIR-V COMPILER "
echo "================================="

echo "[1/5] Compiling Mojo to LLVM IR..."
~/.pixi/bin/pixi run mojo build -I ../tachyonSL shader.mojo --emit=llvm -o shader.ll

echo "[2/5] Patching Target Triple and Assembling to SPIR-V..."
sed 's/x86_64-unknown-linux-gnu/spir64-unknown-unknown/g' shader.ll > shader_spirv.ll
~/.pixi/bin/pixi run opt -O3 shader_spirv.ll -o shader.bc
~/.pixi/bin/pixi run llvm-spirv shader.bc -o shader.spv

echo "[3/5] Adapting Memory Model for OpenGL..."
~/.pixi/bin/pixi run spirv-dis shader.spv -o shader.spvasm
python3 fix_memory_model.py
~/.pixi/bin/pixi run spirv-as shader_logical.spvasm -o shader_logical.spv

echo "[4/5] Building GLSL Wrapper..."
~/.pixi/bin/pixi run spirv-as wrapper_manual.spvasm -o wrapper_manual.spv

echo "[5/5] Linking Mojo Core with GLSL Wrapper..."
~/.pixi/bin/pixi run spirv-link shader_logical.spv wrapper_manual.spv -o tachyon_post.spv

echo "[6/6] Validating Final Shader..."
~/.pixi/bin/pixi run spirv-val --target-env opengl4.0 tachyon_post.spv

echo "[Deploy] Copying to Minecraft Virtual Resource Pack..."
cp tachyon_post.spv dummy/post_desaturate.spv

echo "================================="
echo " SUCCESS! Shader is ready.       "
echo "================================="
