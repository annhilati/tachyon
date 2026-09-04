package com.tachyon.mixin;

import com.mojang.blaze3d.opengl.GlShaderModule;
import com.mojang.blaze3d.shaders.ShaderSource;
import com.mojang.blaze3d.shaders.ShaderType;
import net.minecraft.client.renderer.ShaderDefines;
import net.minecraft.resources.Identifier;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import org.lwjgl.opengl.GL20;
import org.lwjgl.system.MemoryUtil;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import com.tachyon.TachyonMod;

@Mixin(targets = "com.mojang.blaze3d.opengl.GlDevice")
public class GlDeviceMixin {

    @Inject(method = "getOrCompileShader", at = @At("HEAD"), cancellable = true)
    private void onGetOrCompileShader(Identifier id, ShaderType type, ShaderDefines defines, ShaderSource source, CallbackInfoReturnable<GlShaderModule> cir) {
        String namespace = id.getNamespace();
        String name = id.getPath();
        
        if ("tachyon".equals(namespace) && (name.contains("main") || name.contains("screenquad"))) {
            TachyonMod.LOGGER.info("SPIR-V Target erkannt: " + id.toString() + " (Type: " + type + "). Überschreibe GLSL Kompilierung...");

            try {
                byte[] spvBytes = TachyonMod.getActiveSpvBytes();
                if (spvBytes == null) {
                    TachyonMod.LOGGER.error("Keine SPIR-V Daten gefunden. Falle auf Standard-GLSL zurück.");
                    return;
                }
                
                ByteBuffer spvBuffer = MemoryUtil.memAlloc(spvBytes.length);
                spvBuffer.put(spvBytes);
                spvBuffer.flip();

                // 1. Shader ID generieren
                int shaderId = GL20.glCreateShader(type == ShaderType.VERTEX ? GL20.GL_VERTEX_SHADER : GL20.GL_FRAGMENT_SHADER);
                if (shaderId == 0) {
                    TachyonMod.LOGGER.error("Konnte keine Shader-ID von OpenGL erhalten.");
                    MemoryUtil.memFree(spvBuffer);
                    return;
                }

                // 2. SPIR-V Binärdaten in die GPU laden
                org.lwjgl.opengl.GL41.glShaderBinary(new int[]{shaderId}, org.lwjgl.opengl.ARBGLSPIRV.GL_SHADER_BINARY_FORMAT_SPIR_V_ARB, spvBuffer);

                // 3. Einstiegspunkt spezifizieren (leere Arrays statt null, sonst crasht LWJGL beim .length Check!)
                org.lwjgl.opengl.ARBGLSPIRV.glSpecializeShaderARB(shaderId, "main", new int[0], new int[0]);

                // 4. Speicher aufräumen
                MemoryUtil.memFree(spvBuffer);

                // 5. Überprüfen
                int compileStatus = GL20.glGetShaderi(shaderId, GL20.GL_COMPILE_STATUS);
                if (compileStatus == GL20.GL_FALSE) {
                    String infoLog = GL20.glGetShaderInfoLog(shaderId);
                    TachyonMod.LOGGER.error("Fehler beim Spezialisieren des SPIR-V Shaders: " + infoLog);
                    return;
                }

                TachyonMod.LOGGER.info("SPIR-V Shader " + name + " erfolgreich geladen! (ID: " + shaderId + ")");

                // 6. GlShaderModule erstellen (ID, type)
                GlShaderModule module = new GlShaderModule(shaderId, id, type);
                
                cir.setReturnValue(module);
                cir.cancel();

            } catch (Exception e) {
                TachyonMod.LOGGER.error("Fehler beim Verarbeiten des Shaders: ", e);
            }
        }
    }
}
