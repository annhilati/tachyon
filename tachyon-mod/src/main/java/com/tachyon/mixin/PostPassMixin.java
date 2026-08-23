package com.tachyon.mixin;

import net.minecraft.client.renderer.PostPass;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(PostPass.class)
public class PostPassMixin {
    @Inject(method = "process", at = @At("HEAD"))
    private void onProcess(float tickDelta, CallbackInfo ci) {
        for (java.lang.reflect.Field field : PostPass.class.getDeclaredFields()) {
            System.out.println("PostPass field: " + field.getName() + " of type " + field.getType().getName());
        }
    }
}
