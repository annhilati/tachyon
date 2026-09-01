package com.tachyon;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keybinding.v1.KeyBindingHelper;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.client.KeyMapping;
import net.minecraft.resources.ResourceLocation;
import com.mojang.blaze3d.platform.InputConstants;
import org.lwjgl.glfw.GLFW;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class TachyonMod implements ClientModInitializer {
    public static final String MOD_ID = "tachyon";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);
    
    private static KeyMapping toggleShaderKey;
    public static Path SHADERPACKS_DIR;

    @Override
    public void onInitializeClient() {
        LOGGER.info("Tachyon: Initializing SPIR-V Loader Mod!");
        
        SHADERPACKS_DIR = FabricLoader.getInstance().getGameDir().resolve("shaderpacks");
        try {
            if (!Files.exists(SHADERPACKS_DIR)) {
                Files.createDirectories(SHADERPACKS_DIR);
            }
        } catch (Exception e) {
            LOGGER.error("Konnte shaderpacks Ordner nicht erstellen!", e);
        }

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

    public static byte[] getActiveSpvBytes() {
        try {
            // Priorität 1: Entpackter Ordner "shader" (für einfache Entwicklung)
            Path devFolder = SHADERPACKS_DIR.resolve("shader");
            if (Files.exists(devFolder) && Files.isDirectory(devFolder)) {
                Path spvPath = devFolder.resolve("shader.spv");
                if (Files.exists(spvPath)) {
                    return Files.readAllBytes(spvPath);
                }
            }

            // Priorität 2: Gepackte ZIP "shader.zip"
            Path zipPath = SHADERPACKS_DIR.resolve("shader.zip");
            if (Files.exists(zipPath)) {
                try (ZipFile zip = new ZipFile(zipPath.toFile())) {
                    ZipEntry entry = zip.getEntry("shader.spv");
                    if (entry != null) {
                        try (InputStream is = zip.getInputStream(entry)) {
                            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                            int nRead;
                            byte[] data = new byte[16384];
                            while ((nRead = is.read(data, 0, data.length)) != -1) {
                                buffer.write(data, 0, nRead);
                            }
                            return buffer.toByteArray();
                        }
                    }
                }
            }
            
            // Priorität 3: Fallback auf das alte test-shader-mojo Verzeichnis, falls man aus der IDE startet
            Path legacyPath = FabricLoader.getInstance().getGameDir().resolve("../../test-shader-mojo/dummy/post_desaturate.spv").normalize();
            if (Files.exists(legacyPath)) {
                return Files.readAllBytes(legacyPath);
            }

            LOGGER.error("Kein gültiges Tachyon-Shaderpack (shader.zip oder shader/) in " + SHADERPACKS_DIR + " gefunden!");
            return null;
        } catch (Exception e) {
            LOGGER.error("Fehler beim Lesen der shader.spv aus dem Shaderpack", e);
            return null;
        }
    }
}
