/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Shared library for wrapper shaders.

\*================================================================================*/

// System Configuration Block (Injected by Java Mixin)
layout(binding = 1, std140) uniform TachyonConfig {
    float InverseAmount;
    float Time;
} TachyonConfig_inst;

// Add more shared data structures here later...
