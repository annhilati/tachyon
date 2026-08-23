package com.tachyon.mixin;

import com.mojang.blaze3d.opengl.GlProgram;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(GlProgram.class)
public class GlProgramMixinTest {
    @Inject(method = "<init>", at = @At("RETURN"))
    private void onInit(CallbackInfo ci) {
        for (java.lang.reflect.Method m : GlProgram.class.getDeclaredMethods()) {
            System.out.println("GlProgram method: " + m.getName());
        }
    }
}
