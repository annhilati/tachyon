package com.tachyon;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keybinding.v1.KeyBindingHelper;
import net.minecraft.client.KeyMapping;
import net.minecraft.resources.ResourceLocation;
import com.mojang.blaze3d.platform.InputConstants;
import org.lwjgl.glfw.GLFW;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TachyonMod implements ClientModInitializer {
    public static final String MOD_ID = "tachyon";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);
    
    private static KeyMapping toggleShaderKey;

    @Override
    public void onInitializeClient() {
        LOGGER.info("Tachyon: Initializing SPIR-V Loader Mod!");
        
        toggleShaderKey = KeyBindingHelper.registerKeyBinding(new KeyMapping(
            "key.tachyon.toggle_shader",
            InputConstants.Type.KEYSYM,
            GLFW.GLFW_KEY_O,
            "category.tachyon.general"
        ));

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            while (toggleShaderKey.consumeClick()) {
                if (client.gameRenderer.currentEffect() != null) {
                    client.gameRenderer.shutdownEffect();
                } else {
                    client.gameRenderer.loadEffect(ResourceLocation.fromNamespaceAndPath("tachyon", "post_effect/main.json"));
                }
            }
        });
    }
}
