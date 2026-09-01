#version 450 core
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D InSampler;

layout(binding = 0, std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(binding = 1, std140) uniform TachyonConfig {
    float InverseAmount;
    float Time;
} TachyonConfig_inst;

vec4 mojo_main(vec4 color, float time, vec4 weights) { return color; }

void main() {
    vec4 color = texture(InSampler, texCoord);
    vec4 weights = vec4(0.333, 0.5, 0.5, 1.0);
    fragColor = mojo_main(color, TachyonConfig_inst.Time, weights);
}
