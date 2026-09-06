/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Fragment Shader Runtime.

\*================================================================================*/

#version 450
#extension GL_GOOGLE_include_directive : enable

#include "runtime.glsl"

layout(location = 0) in vec2 texCoord;              // provided by runtime.vert
layout(location = 0) out vec4 fragColor;            // used by Minecraft


vec4 tachyon_main(vec4 color, float time) {
    return vec4(0.0);
}

void main() {
    vec4 color = texture(InSampler, texCoord);
    
    // Call Mojo to compute the final color
    fragColor = tachyon_main(color, Time);
}
