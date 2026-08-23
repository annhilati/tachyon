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
import org.lwjgl.opengl.GL15;
import org.lwjgl.opengl.GL31;
import java.lang.reflect.Method;
import java.util.Map;

@Mixin(PostPass.class)
public abstract class PostPassTimeMixin {

    @Shadow @org.spongepowered.asm.mixin.Final private Map<String, GpuBuffer> customUniforms;

    @Inject(method = "addToFrame", at = @At("HEAD"))
    private void onAddToFrame(FrameGraphBuilder builder, Map<?, ?> inputs, GpuBufferSlice output, CallbackInfo ci) {
        if (this.customUniforms != null && this.customUniforms.containsKey("InvertConfig")) {
            GpuBuffer uboBuffer = this.customUniforms.get("InvertConfig");
            if (uboBuffer != null && !uboBuffer.isClosed()) {
                try {
                    Method handleMethod = uboBuffer.getClass().getMethod("handle");
                    handleMethod.setAccessible(true);
                    int handle = (int) handleMethod.invoke(uboBuffer);
                    
                    if (handle > 0) {
                        float timeInSeconds = (System.currentTimeMillis() % 10000) / 1000.0f; // 0.0 to 10.0
                        float pulse = (float) (0.5 + 0.5 * Math.sin(timeInSeconds * 3.0));
                        
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, handle);
                        
                        // Check buffer size to prevent GL_INVALID_VALUE
                        int size = GL15.glGetBufferParameteri(GL31.GL_UNIFORM_BUFFER, GL15.GL_BUFFER_SIZE);
                        if (size >= 8) {
                            GL15.glBufferSubData(GL31.GL_UNIFORM_BUFFER, 4, new float[]{pulse});
                        } else {
                            System.out.println("[Tachyon] WARNING: InvertConfig UBO size is " + size + ". Expected 8!");
                        }
                        GL15.glBindBuffer(GL31.GL_UNIFORM_BUFFER, 0);
                    }
                } catch (Exception e) {
                    // Ignore
                }
            }
        }
    }
}
