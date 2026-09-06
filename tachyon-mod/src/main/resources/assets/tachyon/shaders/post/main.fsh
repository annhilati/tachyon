#version 330

uniform sampler2D InSampler;

layout(std140) uniform TachyonGlobals {
    float Time;
};

in vec2 texCoord;
out vec4 fragColor;

void main() {
    fragColor = texture(InSampler, texCoord);
}
