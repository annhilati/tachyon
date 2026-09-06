package com.tachyon;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keymapping.v1.KeyMappingHelper;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.client.KeyMapping;
import net.minecraft.resources.Identifier;
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

        toggleShaderKey = KeyMappingHelper.registerKeyMapping(new KeyMapping(
            "key.tachyon.toggle_shader",
            InputConstants.Type.KEYSYM,
            GLFW.GLFW_KEY_O,
            KeyMapping.Category.register(Identifier.fromNamespaceAndPath("tachyon", "general"))
        ));

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            while (toggleShaderKey.consumeClick()) {
                if (client.gameRenderer.currentPostEffect() != null) {
                    client.gameRenderer.clearPostEffect();
                } else {
                    try {
                        java.lang.reflect.Method m = client.gameRenderer.getClass().getDeclaredMethod("setPostEffect", Identifier.class);
                        m.setAccessible(true);
                        m.invoke(client.gameRenderer, Identifier.fromNamespaceAndPath("tachyon", "main"));
                    } catch (Exception e) {
                        LOGGER.error("Fehler beim Aktivieren des Post-Effects", e);
                    }
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
                    LOGGER.info("[Tachyon Debug] Lade SPIR-V von Pfad: " + spvPath.toAbsolutePath().toString());
                    byte[] bytes = Files.readAllBytes(spvPath);
                    LOGGER.info("[Tachyon Debug] Gelesen: " + bytes.length + " bytes.");
                    return bytes;
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
                            LOGGER.info("[Tachyon Debug] Lade SPIR-V aus ZIP: " + zipPath.toAbsolutePath().toString());
                            byte[] bytes = buffer.toByteArray();
                            LOGGER.info("[Tachyon Debug] Gelesen: " + bytes.length + " bytes.");
                            return bytes;
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
