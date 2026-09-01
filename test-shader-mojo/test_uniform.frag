#version 450 core
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D InSampler;

layout(location = 1) uniform float GameTime;

vec4 mojo_main(vec4 color, float time) { return vec4(time); }

void main() {
    vec4 color = texture(InSampler, texCoord);
    fragColor = mojo_main(color, GameTime);
}
