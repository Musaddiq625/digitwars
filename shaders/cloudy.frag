#version 300 es
precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uColor1;
uniform vec3 uColor2;

out vec4 fragColor;

// Improved random hash function
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

// Smooth value noise
float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f); // Smoothstep-like interpolation

    return mix(mix(a, b, u.x),
               mix(c, d, u.x), u.y);
}

// Fractal Brownian Motion
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; i++) {
        value += noise(p * frequency) * amplitude;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    uv *= 2.0;  // Optional zoom

    // Animate with time
    vec2 motion = vec2(uTime * 0.03, uTime * 0.05);
    float n = fbm(uv + motion);

    // Smooth blend between uColor1 and uColor2
    vec3 color = mix(uColor1, uColor2, smoothstep(0.3, 0.7, n));

    fragColor = vec4(color * n * 1.2, 1.0);
}
