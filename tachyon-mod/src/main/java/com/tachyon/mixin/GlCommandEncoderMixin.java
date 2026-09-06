package com.tachyon.mixin;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(targets = "com.mojang.blaze3d.opengl.GlCommandEncoder")
public class GlCommandEncoderMixin {

    @Inject(method = "executeDraw", at = @At("HEAD"))
    private void onExecuteDraw(CallbackInfo ci) {
        if (com.tachyon.TachyonState.isTachyonShader && com.tachyon.TachyonState.TachyonUboHandle > 0) {
            org.lwjgl.opengl.GL30.glBindBufferBase(org.lwjgl.opengl.GL31.GL_UNIFORM_BUFFER, 0, com.tachyon.TachyonState.TachyonUboHandle);
        }
    }
}
