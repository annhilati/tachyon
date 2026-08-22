#version 450 core

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;

layout(binding = 0) uniform sampler2D InSampler;

layout(std140, binding = 1) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140, binding = 2) uniform InvertConfig {
    float InverseAmount;
};

void main() {
    vec4 color = texture(InSampler, texCoord);
    // Simple desaturation (grayscale)
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(gray, gray, gray, 1.0);
}
