package com.tachyon.mixin;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(targets = "com.mojang.blaze3d.opengl.GlRenderPass")
public class GlRenderPassMixin {

    @Shadow protected com.mojang.blaze3d.opengl.GlRenderPipeline pipeline;

    @Inject(method = "setPipeline", at = @At("TAIL"))
    private void onSetPipeline(com.mojang.blaze3d.pipeline.RenderPipeline info, CallbackInfo ci) {
        if (this.pipeline != null && this.pipeline.program() != null) {
            String label = this.pipeline.program().getDebugLabel();
            com.tachyon.TachyonState.isTachyonShader = (label != null && label.contains("tachyon"));
        } else {
            com.tachyon.TachyonState.isTachyonShader = false;
        }
    }
}
