package com.tachyon.mixin;

import net.minecraft.client.renderer.PostPass;
import com.mojang.blaze3d.buffers.GpuBuffer;
import com.mojang.blaze3d.buffers.GpuBufferSlice;
import com.mojang.blaze3d.framegraph.FrameGraphBuilder;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import java.util.Map;
import java.lang.reflect.Field;
import org.lwjgl.opengl.GL15;
import org.lwjgl.opengl.GL31;

@Mixin(PostPass.class)
public abstract class PostPassTimeMixin {

    @Shadow @org.spongepowered.asm.mixin.Final private Map<String, GpuBuffer> customUniforms;
    
    private boolean replacedBuffer = false;

    @Inject(method = "addToFrame", at = @At("HEAD"))
    private void onAddToFrame(FrameGraphBuilder builder, Map<?, ?> inputs, GpuBufferSlice output, CallbackInfo ci) {
        if (this.customUniforms != null && this.customUniforms.containsKey("TachyonConfig")) {
            GpuBuffer uboBuffer = this.customUniforms.get("TachyonConfig");
            if (uboBuffer != null && !uboBuffer.isClosed()) {
                try {
                    if (!replacedBuffer) {
                        replacedBuffer = true;
                        
                        Class<?> glBufferClass = Class.forName("com.mojang.blaze3d.opengl.GlBuffer");
                        Field handleField = glBufferClass.getDeclaredField("handle");
                        handleField.setAccessible(true);
                        int oldHandle = handleField.getInt(uboBuffer);
                        
                        GL15.glDeleteBuffers(oldHandle);
                        com.tachyon.TachyonState.TachyonUboHandle = GL15.glGenBuffers();
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, com.tachyon.TachyonState.TachyonUboHandle);
                        GL15.glBufferData(GL31.GL_UNIFORM_BUFFER, 16, GL15.GL_DYNAMIC_DRAW);
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, 0);
                        
                        handleField.setInt(uboBuffer, com.tachyon.TachyonState.TachyonUboHandle);
                    }

                    if (com.tachyon.TachyonState.TachyonUboHandle > 0) {
                        float timeInSeconds = (System.currentTimeMillis() % 10000) / 1000.0f; 
                        
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, com.tachyon.TachyonState.TachyonUboHandle);
                        GL15.glBufferSubData(GL31.GL_UNIFORM_BUFFER, 0, new float[]{timeInSeconds, 0, 0, 0});
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, 0);
                    }
                } catch (Exception e) {
                    System.out.println("[Tachyon] Exception in PostPassTimeMixin:");
                    e.printStackTrace();
                }
            }
        }
    }
}
