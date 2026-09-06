/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Shared library for Tachyon UBO Configurations.

\*================================================================================*/

layout(binding = 0, std140) uniform TachyonGlobals { // provided by post_effect tachyon:main
    float Time;
};
