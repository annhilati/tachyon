package com.tachyon.mixin;

import com.mojang.blaze3d.opengl.GlProgram;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Redirect;

@Mixin(GlProgram.class)
public class GlProgramUboMixin {

    @Redirect(method = "setupBindGroupLayouts", at = @At(value = "INVOKE", target = "Lorg/lwjgl/opengl/GL33C;glGetUniformBlockIndex(ILjava/lang/CharSequence;)I"))
    private int redirectGetUniformBlockIndex(int program, CharSequence name) {
        int index = org.lwjgl.opengl.GL33C.glGetUniformBlockIndex(program, name);
        if (index == -1 && name != null && name.toString().equals("TachyonConfig")) {
            return 9999;
        }
        return index;
    }

    @Redirect(method = "setupBindGroupLayouts", at = @At(value = "INVOKE", target = "Lorg/lwjgl/opengl/GL33C;glUniformBlockBinding(III)V"))
    private void redirectUniformBlockBinding(int program, int uniformBlockIndex, int uniformBlockBinding) {
        if (uniformBlockIndex == 9999) {
            // Skip! This prevents the GL_INVALID_VALUE spam, while letting Minecraft assign it to the pipeline!
            System.out.println("[Tachyon] Skipped GL error for TachyonConfig UBO binding.");
            return;
        }
        org.lwjgl.opengl.GL33C.glUniformBlockBinding(program, uniformBlockIndex, uniformBlockBinding);
    }
}
