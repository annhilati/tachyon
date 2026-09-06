/*================================================================================*\

	Tachyon SDK for Mojo

	Copyright (C) 2026 Annhilati
	
    Description: Vertex Shader Runtime.

\*================================================================================*/

#version 450
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) out vec2 texCoord; // used by runtime.frag

layout(binding = 0, std140) uniform TachyonConfig { // provided by post_effect tachyon:main
    float Time;
};

vec4 tachyon_vert_main(vec4 pos, vec2 uv, float time) { return pos; }

void main() {
    // Generate Big Triangle geometry
    vec2 uv = vec2((gl_VertexIndex << 1) & 2, gl_VertexIndex & 2);
    vec4 pos = vec4(uv * vec2(2, 2) + vec2(-1, -1), 0, 1);
    
    // Call Mojo to optionally modify the vertex position
    gl_Position = tachyon_vert_main(pos, uv, Time);
    texCoord = uv;
}
