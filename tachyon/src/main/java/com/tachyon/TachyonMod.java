package com.tachyon;

import net.fabricmc.api.ClientModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TachyonMod implements ClientModInitializer {
	public static final String MOD_ID = "tachyon";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

	@Override
	public void onInitializeClient() {
		LOGGER.info("Tachyon: Initializing SPIR-V Loader Mod!");
	}
}
