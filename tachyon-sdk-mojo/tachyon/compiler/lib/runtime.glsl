/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Shared library for the Tachyon runtime.

\*================================================================================*/

//=====// Bindings for external resources //======================================//

layout(binding = 0) uniform sampler2D InSampler;    // provided by post_effect tachyon:main as In
layout(binding = 1, std140) uniform TachyonConfig { // provided by post_effect tachyon:main
    float Time;
} TachyonConfig_inst;