// Updated version for Flutter compatibility
#version 310 es
precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uColor1;
uniform vec3 uColor2;

out vec4 fragColor;

// Simplified hash function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

// Basic noise implementation
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution.xy) / min(uResolution.x, uResolution.y);
    
    // Create sphere mapping with surface normal
    float len = length(uv);
    if(len > 1.0) {
        fragColor = vec4(0.0);
        return;
    }
    vec3 normal = vec3(uv, sqrt(1.0 - dot(uv, uv)));
    
    // Add directional lighting
    vec3 lightDir = normalize(vec3(0.5, 0.8, 1.0));
    float diffuse = max(dot(normal, lightDir), 0.2);
    float specular = pow(max(dot(reflect(-lightDir, normal), vec3(0.0, 0.0, 1.0)), 0.0), 32.0);
    
    // Enhanced noise pattern
    float n = noise(uv * 8.0 + uTime * 0.05);
    vec3 baseColor = mix(uColor1, uColor2, n);
    vec3 finalColor = baseColor * diffuse + specular * 0.5;
    
    fragColor = vec4(finalColor, 1.0);
}
