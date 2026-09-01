/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Fragment Shader Wrapper.

\*================================================================================*/

#version 450
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D InSampler;

#include "shared.glsl"

vec4 tachyon_main(vec4 color, float time, vec4 weights) { return color; }

void main() {
    vec4 color = texture(InSampler, texCoord);
    vec4 weights = vec4(0.333, 0.5, 0.5, 1.0);
    fragColor = tachyon_main(color, TachyonConfig_inst.Time, weights);
}
