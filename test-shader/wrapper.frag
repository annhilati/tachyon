#version 450 core
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D InSampler;

vec4 mojo_main(vec4 color, vec4 weights) {
    return vec4(1.0);
}

void main() {
    vec4 color = texture(InSampler, texCoord);
    vec4 weights = vec4(0.299, 0.587, 0.114, 1.0);
    fragColor = mojo_main(color, weights);
}
