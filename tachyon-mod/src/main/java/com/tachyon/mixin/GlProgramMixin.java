package com.tachyon.mixin;

import com.mojang.blaze3d.opengl.GlProgram;
import com.mojang.blaze3d.opengl.Uniform;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;

@Mixin(GlProgram.class)
public abstract class GlProgramMixin {

    @Shadow public abstract String getDebugLabel();

    @Shadow @org.spongepowered.asm.mixin.Final private java.util.Map<String, Uniform> uniformsByName;

    @Inject(method = "setupBindGroupLayouts", at = @At("RETURN"))
    private void onSetupBindGroupLayouts(java.util.List<?> layouts, org.spongepowered.asm.mixin.injection.callback.CallbackInfo ci) {
        String label = getDebugLabel();
        if (label != null && label.contains("invert")) {
            if (!this.uniformsByName.containsKey("InSampler")) {
                // Füge den Sampler manuell für Texture Unit 0 hinzu!
                // Minecraft sucht explizit nach 'InSampler' (hängt 'Sampler' an den JSON-Namen an).
                this.uniformsByName.put("InSampler", new Uniform.Sampler(0, 0));
            }
        }
    }
}
