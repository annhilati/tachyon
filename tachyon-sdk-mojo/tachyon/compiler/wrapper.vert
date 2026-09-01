/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Vertex Shader Wrapper.

\*================================================================================*/

#version 450
#extension GL_GOOGLE_include_directive : enable

out vec2 texCoord;

#include "shared.glsl"

vec4 tachyon_vert_main(vec4 pos, vec2 uv, float time) { return pos; }

void main() {
    // Generate Big Triangle geometry
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    vec4 pos = vec4(uv * vec2(2, 2) + vec2(-1, -1), 0, 1);
    
    // Call Mojo to optionally modify the vertex position
    gl_Position = tachyon_vert_main(pos, uv, TachyonConfig_inst.Time);
    texCoord = uv;
}
