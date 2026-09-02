/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Fragment Shader Runtime.

\*================================================================================*/

#version 450
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D InSampler;

#include "shared.glsl"

vec4 tachyon_main(vec4 color, float time);

//=====// Standard Library Bindings //============================================//

float tachyon_sin(float x) { return sin(x); }
float tachyon_cos(float x) { return cos(x); }

void main() {
    vec4 color = texture(InSampler, texCoord);
    fragColor = tachyon_main(color, TachyonConfig_inst.Time);
}
