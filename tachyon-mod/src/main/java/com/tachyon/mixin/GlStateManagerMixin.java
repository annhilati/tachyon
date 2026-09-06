package com.tachyon.mixin;

import com.mojang.blaze3d.opengl.GlStateManager;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(GlStateManager.class)
public class GlStateManagerMixin {
    @Inject(method = "_glGetUniformLocation", at = @At("HEAD"), cancellable = true)
    private static void onGetUniformLocation(int programId, CharSequence name, CallbackInfoReturnable<Integer> cir) {
        if (name != null && name.toString().equals("InSampler")) {
            // Return a fake location so Minecraft's ShaderManager registers the sampler 
            // and binds the texture to a Texture Unit. 
            // Since SPIR-V already has layout(binding=0), OpenGL will route it correctly!
            cir.setReturnValue(9999);
        }
    }
}
