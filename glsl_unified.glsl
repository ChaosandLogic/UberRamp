// ============================================================================
// UNIFIED 2D/3D GLSL PATTERN GENERATOR
// ============================================================================
// INPUTS:
//   sTD2DInputs[0] - COLOR RAMP 1 (1D texture for pattern 1 coloring)
//   sTD2DInputs[1] - CONTROL MAP (optional - for movement/direction/modulation)
//   sTD2DInputs[2] - COLOR RAMP 2 (1D texture for pattern 2 coloring when blending)
//
// CONTROL MAP USAGE:
//   - Connect a texture (noise, video, feedback, etc.) to input 1
//   - Set uNumInputs = 3 and uUseControlMap = 1.0 to enable
//   - RGB channels control different aspects based on uControlMapMode:
//      Mode 0 (Direction): RG=XY direction, B=Z direction (3D only)
//      Mode 1 (Distortion): R channel modulates distortion amount
//      Mode 2 (Blend): R channel controls blend between Pattern 1 & 2
// ============================================================================

// === UNIFORMS ===
uniform int uDimension;          // 0 = 2D mode, 1 = 3D mode
uniform int uType;
uniform int uType2;              // Second pattern type
uniform float uBlend;            // Blend between patterns
uniform float uPhase;
uniform float uPeriod;
uniform bool uExtend;
uniform vec3 uRes;               // Resolution (x, y, z) - z used only in 3D mode
uniform float uParam1;
uniform float uParam2;
uniform float uParam3;           // Used in 3D mode
uniform float uDistortAmount;    // UV distortion strength
uniform float uDistortScale;     // UV distortion scale
uniform float uAntiAlias;        // Anti-aliasing amount (0.0 to 1.0)

// 3D Lighting uniforms (only used in 3D mode)
uniform vec3 uCameraPos;         // Camera position for lighting
uniform vec4 uLightPos;          // Light position (xyz) and brightness (w)
uniform float uMetallic;         // Metallic factor (0.0 to 1.0)
uniform float uRoughness;        // Roughness factor (0.0 to 1.0)

// Control Map uniforms
uniform float uUseControlMap;    // Enable/disable control map (0.0 to 1.0)
uniform int uControlMapMode;     // 0=direction, 1=distortion, 2=blend, 99=debug
uniform float uControlMapStrength; // How much the control map affects the result
uniform int uNumInputs;          // Number of texture inputs available (1, 2, or 3)

// Time-based phase animation uniforms
uniform float uTime;              // Time source (set to absTime.seconds in TouchDesigner)
uniform float uUseTimePhase;     // Enable/disable using time with phase (0.0 = off, 1.0 = on)
uniform float uPhaseSpeed;       // Speed multiplier for time-based phase animation

// Visualization mode
uniform int uVisMode;            // 0=normal, 1=split view (left=pattern1, middle=blend, right=pattern2)

out vec4 fragColor;

const float pi = 3.14159265359;

// === UTILITY FUNCTIONS ===

// Anti-aliasing function using smoothstep
float smoothPattern(float pattern, float aa) {
    if (aa <= 0.0) return pattern;
    
    // Create smooth transitions around pattern boundaries
    float threshold = 0.5;
    float smoothness = aa * 0.1; // Adjust smoothness range
    
    return smoothstep(threshold - smoothness, threshold + smoothness, pattern);
}

float repeat(float v) {
    return fract(v);
}

float mirror(float v) {
    float m = mod(v, 2.0);
    return mix(m, 2.0 - m, step(1.0, m));
}

// === HASH FUNCTIONS (2D and 3D) ===

float hash2D(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash3D(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

// === NOISE FUNCTIONS (2D and 3D) ===

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash2D(i);
    float b = hash2D(i + vec2(1.0, 0.0));
    float c = hash2D(i + vec2(0.0, 1.0));
    float d = hash2D(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash3D(i);
    float b = hash3D(i + vec3(1.0, 0.0, 0.0));
    float c = hash3D(i + vec3(0.0, 1.0, 0.0));
    float d = hash3D(i + vec3(1.0, 1.0, 0.0));
    float e = hash3D(i + vec3(0.0, 0.0, 1.0));
    float f_val = hash3D(i + vec3(1.0, 0.0, 1.0));
    float g = hash3D(i + vec3(0.0, 1.0, 1.0));
    float h = hash3D(i + vec3(1.0, 1.0, 1.0));
    
    return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
               mix(mix(e, f_val, f.x), mix(g, h, f.x), f.y), f.z);
}

// === VORONOI FUNCTIONS (2D and 3D) ===

float voronoi2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float minDist = 1.0;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash2D(i + neighbor) * vec2(1.0, 1.0);
            vec2 diff = neighbor + point - f;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

float voronoi3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    
    float minDist = 1.0;
    for(int z = -1; z <= 1; z++) {
        for(int y = -1; y <= 1; y++) {
            for(int x = -1; x <= 1; x++) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 point = hash3D(i + neighbor) * vec3(1.0, 1.0, 1.0);
                vec3 diff = neighbor + point - f;
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    return minDist;
}

// === 2D PATTERN CALCULATOR ===

float calculatePattern2D(int type, vec2 uv, vec2 aspect, float phase) {
    float p = 0.0;
    
    if (type == 0) {
        // Horizontal
        float skew = uParam1 * 2.0 - 1.0;
        vec2 uvAdjusted = (uv * aspect - phase) / uPeriod;
        p = uvAdjusted.t + uvAdjusted.s * skew;
    } 
    else if (type == 1) {
        // Vertical
        float skew = uParam1 * 2.0 - 1.0;
        vec2 uvAdjusted = (uv * aspect - phase) / uPeriod;
        p = uvAdjusted.s + uvAdjusted.t * skew;
    } 
    else if (type == 2) { 
        // Radial (angular)
        float aspectScale = min(aspect.x, aspect.y);
        vec2 centered = (uv - 0.5) * aspectScale;
        float angle = atan(centered.y, centered.x);
        
        float segments = max(1.0, floor(uParam1 * 32.0));
        float rotation = uParam2 * pi * 2.0;
        
        p = fract((angle + rotation) / (pi * 2.0) * segments - phase) / uPeriod;
    } 
    else if (type == 3) {
        // Circular (concentric)
        vec2 centerOffset = (vec2(uParam1, uParam2) - 0.5) * 2.0;
        vec2 center = vec2(0.5, 0.5) + centerOffset * 0.3;
        float aspectScale = min(aspect.x, aspect.y);
        vec2 scaledUV = uv * aspectScale;
        vec2 scaledCenter = center * aspectScale;
        float dist = distance(scaledUV, scaledCenter);
        p = (dist / (uPeriod * 0.5) - phase);
    }
    else if (type == 4) {
        // Spiral (Archimedean)
        float aspectScale = min(aspect.x, aspect.y);
        vec2 centered = (uv - 0.5) * aspectScale;
        float angle = atan(centered.y, centered.x);
        float radius = length(centered);
        
        float spiralTightness = uParam1 * 10.0;
        float direction = mix(1.0, -1.0, step(0.5, uParam2));
        
        // Proper Archimedean spiral: distance increases with angle
        // Shift angle from [-π, π] to [0, 2π], then normalize to [0, 1]
        // Period is fixed at 0.25 for perfect tiling
        float angleRotations = (angle + pi) / (pi * 2.0);
        p = (radius * spiralTightness * direction - angleRotations - phase) / 0.25;
    }
    else if (type == 5) {
        // Diamond (Manhattan distance)
        float aspectScale = min(aspect.x, aspect.y);
        vec2 centered = (uv - 0.5) * aspectScale;
        
        // Rotate
        float angle = uParam2 * pi * 2.0;
        float s = sin(angle);
        float c = cos(angle);
        centered = vec2(
            centered.x * c - centered.y * s,
            centered.x * s + centered.y * c
        );
        
        float manhattan = abs(centered.x) + abs(centered.y);
        float euclidean = length(centered);
        float dist = mix(manhattan, euclidean, uParam1);
        
        p = (dist / (uPeriod * 0.5) - phase);
    }
    else if (type == 6) {
        // Grid/Checkerboard
        float scaleX = 0.5 + uParam1 * 2.0;
        float scaleY = 0.5 + uParam2 * 2.0;
        
        vec2 uvAdjusted = (uv * aspect * vec2(scaleX, scaleY) - phase) / uPeriod;
        p = (sin(uvAdjusted.s * pi) + sin(uvAdjusted.t * pi)) * 0.5 + 0.5;
    }
    else if (type == 7) {
        // Wave (Sine modulation)
        vec2 uvAdjusted = (uv * aspect) / uPeriod;
        float waveFreq = max(1.0, uParam1 * 10.0);
        float waveAmp = uParam2 * 0.5;
        float waveDir = uParam3 * pi * 2.0;
        
        // Use direction vector like 3D version (but in 2D)
        vec2 waveVec = vec2(cos(waveDir), sin(waveDir));
        float wave = sin(dot(uvAdjusted, waveVec) * pi * 2.0 * waveFreq) * waveAmp;
        p = (uvAdjusted.t + wave - phase);
    }
    else if (type == 8) {
        // Noise (Perlin-style)
        vec2 uvAdjusted = (uv * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        p = noise2D(uvAdjusted * scale + phase * 10.0);
    }
    else if (type == 9) {
        // Voronoi/Cellular
        vec2 uvAdjusted = (uv * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        p = voronoi2D(uvAdjusted * scale + phase * 5.0);
    }
    else if (type == 10) {
        // Polar Grid
        float aspectScale = min(aspect.x, aspect.y);
        vec2 centered = (uv - 0.5) * aspectScale;
        float angle = atan(centered.y, centered.x);
        float radius = length(centered);
        
        float spokes = max(1.0, uParam1 * 32.0);
        float rings = max(1.0, uParam2 * 16.0);
        
        float anglePattern = fract((angle / (pi * 2.0) + 0.5) * spokes);
        float radiusPattern = fract(radius * rings / uPeriod - phase);
        
        p = (anglePattern + radiusPattern) * 0.5;
    }
    else if (type == 11) {
        // Lissajous curves
        float freqX = max(1.0, floor(uParam1 * 8.0));
        float freqY = max(1.0, floor(uParam2 * 8.0));
        
        float aspectScale = min(aspect.x, aspect.y);
        vec2 centered = (uv - 0.5) * aspectScale;
        float lissX = sin(centered.x * pi * freqX + phase * pi * 2.0);
        float lissY = cos(centered.y * pi * freqY + phase * pi * 2.0);
        
        p = (lissX + lissY + 2.0) * 0.25 / uPeriod;
    }
    else if (type == 12) {
        // 2D Gyroid (slice of 3D gyroid)
        vec2 uvAdjusted = (uv * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        float zSlice = (uParam2 - 0.5) * 2.0;
        vec3 phaseOffset = vec3(phase, phase * 0.7, phase * 1.3) * 10.0;
        vec3 p_scaled = vec3(uvAdjusted * scale, zSlice * scale) + phaseOffset;
        
        p = sin(p_scaled.x) * cos(p_scaled.y) + 
            sin(p_scaled.y) * cos(p_scaled.z) + 
            sin(p_scaled.z) * cos(p_scaled.x);
        p = p * 0.5 + 0.5;
    }
    else if (type == 13) {
        // 2D Flow Field
        vec2 uvAdjusted = (uv * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        
        // Use uParam2 to control flow field rotation
        float rotationAngle = uParam2 * pi * 2.0;
        float cosRot = cos(rotationAngle);
        float sinRot = sin(rotationAngle);
        
        // Apply rotation to the position
        vec2 p_scaled = uvAdjusted * scale;
        vec2 rotatedPos = vec2(
            p_scaled.x * cosRot - p_scaled.y * sinRot,
            p_scaled.x * sinRot + p_scaled.y * cosRot
        );
        
        // Create flow field using 2D curl noise
        float eps = 0.1;
        
        float n1 = noise2D(rotatedPos);
        float n2 = noise2D(rotatedPos + vec2(eps, 0.0));
        float n3 = noise2D(rotatedPos + vec2(0.0, eps));
        
        // Calculate curl in 2D
        vec2 curl = vec2(
            (n3 - n1) / eps,
            (n1 - n2) / eps
        );
        
        // Sample along flow
        vec2 flowPos = rotatedPos;
        float flowValue = 0.0;
        
        for(int i = 0; i < 12; i++) {
            float t = float(i) / 12.0;
            float stepSize = 0.05 * (1.0 + t * 2.0);
            vec2 samplePos = flowPos + curl * t * stepSize;
            
            float sampleValue = noise2D(samplePos);
            sampleValue += noise2D(samplePos * 2.0) * 0.5;
            sampleValue += noise2D(samplePos * 4.0) * 0.25;
            
            flowValue += sampleValue * (1.0 - t) * (1.0 / 12.0);
        }
        
        // Add swirling motion
        float swirl = sin(length(rotatedPos) * 2.0 - phase * 3.0) * 0.3 + 0.5;
        
        // Add turbulence
        float turbulence = length(curl) * 0.2;
        
        p = flowValue + swirl * 0.3 + turbulence;
    }
    
    return p;
}

// === 3D PATTERN CALCULATOR ===

float calculatePattern3D(int type, vec3 pos, vec3 aspect, float phase) {
    float p = 0.0;
    
    if (type == 0) {
        // 3D Horizontal planes
        float skew = uParam1 * 2.0 - 1.0;
        vec3 posAdjusted = (pos * aspect - phase) / uPeriod;
        p = posAdjusted.y + posAdjusted.x * skew + posAdjusted.z * uParam2;
    } 
    else if (type == 1) {
        // 3D Vertical planes
        float skew = uParam1 * 2.0 - 1.0;
        vec3 posAdjusted = (pos * aspect - phase) / uPeriod;
        p = posAdjusted.x + posAdjusted.y * skew + posAdjusted.z * uParam2;
    } 
    else if (type == 2) { 
        // 3D Radial (cylindrical)
        float aspectScale = min(min(aspect.x, aspect.y), aspect.z);
        vec3 centered = (pos - 0.5) * aspectScale;
        float angle = atan(centered.z, centered.x);
        float height = centered.y;
        
        float segments = max(1.0, floor(uParam1 * 32.0));
        float rotation = uParam2 * pi * 2.0;
        float heightFreq = uParam3 * 10.0;
        
        p = fract((angle + rotation) / (pi * 2.0) * segments + height * heightFreq - phase) / uPeriod;
    } 
    else if (type == 3) {
        // 3D Spherical (concentric spheres)
        float aspectScale = min(min(aspect.x, aspect.y), aspect.z);
        vec3 centerOffset = (vec3(uParam1, uParam2, uParam3) - 0.5) * 2.0;
        vec3 center = vec3(0.5, 0.5, 0.5) + centerOffset * 0.3;
        float dist = distance(pos * aspectScale, center * aspectScale);
        p = (dist / (uPeriod * 0.5) - phase);
    }
    else if (type == 4) {
        // 3D Spiral (helical/Archimedean)
        float aspectScale = min(aspect.x, aspect.y);
        vec3 centered = (pos - 0.5) * aspectScale;
        float angle = atan(centered.z, centered.x);
        float radius = length(centered.xz);
        float height = centered.y;
        
        float spiralTightness = uParam1 * 10.0;
        float direction = mix(1.0, -1.0, step(0.5, uParam2));
        float heightTightness = uParam3 * 5.0;
        
        // Proper Archimedean spiral with height component
        // Shift angle from [-π, π] to [0, 2π], then normalize to [0, 1]
        // Period is fixed at 0.25 for perfect tiling
        float angleRotations = (angle + pi) / (pi * 2.0);
        p = (radius * spiralTightness * direction - angleRotations + height * heightTightness - phase) / 0.25;
    }
    else if (type == 5) {
        // 3D Diamond (octahedral)
        float aspectScale = min(aspect.x, aspect.y);
        vec3 centered = (pos - 0.5) * aspectScale;
        
        // Rotate around Y axis
        float angle = uParam2 * pi * 2.0;
        float s = sin(angle);
        float c = cos(angle);
        centered.xz = vec2(
            centered.x * c - centered.z * s,
            centered.x * s + centered.z * c
        );
        
        float octahedral = abs(centered.x) + abs(centered.y) + abs(centered.z);
        float euclidean = length(centered);
        float dist = mix(octahedral, euclidean, uParam1);
        
        p = (dist / (uPeriod * 0.5) - phase);
    }
    else if (type == 6) {
        // 3D Grid/Cubes
        float scaleX = 0.5 + uParam1 * 2.0;
        float scaleY = 0.5 + uParam2 * 2.0;
        float scaleZ = 0.5 + uParam3 * 2.0;
        
        vec3 posAdjusted = (pos * aspect * vec3(scaleX, scaleY, scaleZ) - phase) / uPeriod;
        p = (sin(posAdjusted.x * pi) + sin(posAdjusted.y * pi) + sin(posAdjusted.z * pi)) * 0.333 + 0.5;
    }
    else if (type == 7) {
        // 3D Wave (sine modulation in 3D)
        vec3 posAdjusted = (pos * aspect) / uPeriod;
        float waveFreq = max(1.0, uParam1 * 10.0);
        float waveAmp = uParam2 * 0.5;
        float waveDir = uParam3 * pi * 2.0;
        
        vec3 waveVec = vec3(cos(waveDir), sin(waveDir), 0.0);
        float wave = sin(dot(posAdjusted, waveVec) * pi * 2.0 * waveFreq) * waveAmp;
        p = (posAdjusted.y + wave - phase);
    }
    else if (type == 8) {
        // 3D Noise (Perlin-style)
        vec3 posAdjusted = (pos * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        p = noise3D(posAdjusted * scale + phase * 10.0);
    }
    else if (type == 9) {
        // 3D Voronoi/Cellular
        vec3 posAdjusted = (pos * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        p = voronoi3D(posAdjusted * scale + phase * 5.0);
    }
    else if (type == 10) {
        // 3D Polar Grid (spherical coordinates)
        float aspectScale = min(min(aspect.x, aspect.y), aspect.z);
        vec3 centered = (pos - 0.5) * aspectScale;
        float radius = length(centered);
        float theta = atan(centered.z, centered.x);
        float phi = acos(centered.y / max(radius, 0.001));
        
        float spokes = max(1.0, uParam1 * 32.0);
        float rings = max(1.0, uParam2 * 16.0);
        float layers = max(1.0, uParam3 * 8.0);
        
        float thetaPattern = fract((theta / (pi * 2.0) + 0.5) * spokes);
        float phiPattern = fract(phi * rings / pi);
        float radiusPattern = fract(radius * layers / uPeriod - phase);
        
        p = (thetaPattern + phiPattern + radiusPattern) * 0.333;
    }
    else if (type == 11) {
        // 3D Lissajous curves
        float freqX = max(1.0, floor(uParam1 * 8.0));
        float freqY = max(1.0, floor(uParam2 * 8.0));
        float freqZ = max(1.0, floor(uParam3 * 8.0));
        float aspectScale = min(aspect.x, aspect.y);
        vec3 centered = (pos - 0.5) * aspectScale;
        float lissX = sin(centered.x * pi * freqX + phase * pi * 2.0);
        float lissY = cos(centered.y * pi * freqY + phase * pi * 2.0);
        float lissZ = sin(centered.z * pi * freqZ + phase * pi * 2.0);
        p = (lissX + lissY + lissZ + 3.0) * 0.166 / uPeriod;
    }
    else if (type == 12) {
        // 3D Gyroid (triply periodic minimal surface)
        vec3 posAdjusted = (pos * aspect);
        float scale = max(1.0, uParam1 * 10.0);
        vec3 phaseOffset = vec3(phase, phase * 0.7, phase * 1.3) * 10.0;
        vec3 p_scaled = (posAdjusted / uPeriod) * scale + phaseOffset;
        
        p = sin(p_scaled.x) * cos(p_scaled.y) + 
            sin(p_scaled.y) * cos(p_scaled.z) + 
            sin(p_scaled.z) * cos(p_scaled.x);
        p = p * 0.5 + 0.5;
    }
    else if (type == 13) {
        // 3D Flow Field (proper vector field visualization)
        vec3 posAdjusted = (pos * aspect) / uPeriod;
        float scale = max(1.0, uParam1 * 10.0);
        
        // Use uParam3 to control flow field rotation
        float rotationAngle = uParam3 * pi * 2.0;
        float cosRot = cos(rotationAngle);
        float sinRot = sin(rotationAngle);
        
        // Apply rotation to the position
        vec3 p_scaled = posAdjusted * scale;
        vec3 rotatedPos = vec3(
            p_scaled.x * cosRot - p_scaled.z * sinRot,
            p_scaled.y,
            p_scaled.x * sinRot + p_scaled.z * cosRot
        );
        
        // Create a proper flow field using curl noise with better sampling
        float eps = 0.1;
        
        // Sample noise at different offsets to create curl
        vec3 offset1 = vec3(0.0, 0.0, 0.0);
        vec3 offset2 = vec3(eps, 0.0, 0.0);
        vec3 offset3 = vec3(0.0, eps, 0.0);
        vec3 offset4 = vec3(0.0, 0.0, eps);
        
        float n1 = noise3D(rotatedPos + offset1);
        float n2 = noise3D(rotatedPos + offset2);
        float n3 = noise3D(rotatedPos + offset3);
        float n4 = noise3D(rotatedPos + offset4);
        
        // Calculate curl (cross product of gradients) with better precision
        vec3 curl = vec3(
            (n4 - n3) / eps,
            (n2 - n1) / eps,
            (n3 - n2) / eps
        );
        
        // Use uParam2 to control flow field intensity/strength
        float flowIntensity = max(0.1, uParam2 * 3.0);
        curl *= flowIntensity;
        
        // Create flow lines by integrating along the field
        vec3 flowPos = rotatedPos;
        float flowValue = 0.0;
        
        // Sample multiple points along the flow with variable step size
        for(int i = 0; i < 12; i++) {
            float t = float(i) / 12.0;
            float stepSize = 0.05 * (1.0 + t * 2.0); // Variable step size
            vec3 samplePos = flowPos + curl * t * stepSize;
            
            // Add multiple octaves of noise for richer detail
            float sampleValue = noise3D(samplePos);
            sampleValue += noise3D(samplePos * 2.0) * 0.5;
            sampleValue += noise3D(samplePos * 4.0) * 0.25;
            
            flowValue += sampleValue * (1.0 - t) * (1.0 / 12.0);
        }
        
        // Add swirling motion with intensity control
        float swirlIntensity = flowIntensity * 0.3;
        float swirl = sin(length(rotatedPos) * 2.0 - phase * 3.0) * swirlIntensity + 0.5;
        
        // Add turbulence based on curl magnitude
        float turbulence = length(curl) * 0.2;
        
        // Combine all components
        p = flowValue + swirl * 0.3 + turbulence;
    }
    
    return p;
}

// === MAIN FUNCTION ===

void main()
{
    vec4 color;
    float phase = 0.0;
    
    float effectivePhase = uPhase;
    if (uUseTimePhase > 0.0) {
        effectivePhase += uTime * uPhaseSpeed;
    }
    
    if (uDimension == 0) {
        vec2 aspect = uRes.xy / max(uRes.x, 0.001);
        vec2 uv = vUV.st;
        
        vec4 controlMap = vec4(0.5);
        float localDistortAmount = uDistortAmount;
        float localBlend = uBlend;
        
        if (uUseControlMap > 0.0 && uNumInputs > 1) {
            controlMap = texture(sTD2DInputs[1], vUV.st);
            
            if (uControlMapMode == 99) {
                color = controlMap;
                fragColor = TDOutputSwizzle(color);
                return;
            }
            
            if (uControlMapMode == 0) {
                vec2 controlOffset = (controlMap.rg - 0.5) * 2.0 * uControlMapStrength * 0.1;
                uv += controlOffset;
            }
            else if (uControlMapMode == 1) {
                localDistortAmount += abs(controlMap.r - 0.5) * uControlMapStrength * 2.0;
            }
            else if (uControlMapMode == 2) {
                localBlend = mix(localBlend, controlMap.r, uControlMapStrength);
            }
        }
        
        if (localDistortAmount > 0.0) {
            vec2 distortOffset = vec2(
                noise2D(uv * uDistortScale + vec2(0.0, uPhase)),
                noise2D(uv * uDistortScale + vec2(100.0, uPhase))
            ) * 2.0 - 1.0;
            uv += distortOffset * localDistortAmount * 0.1;
        }
        
        if (uPeriod > 0.0) {
            float p1 = calculatePattern2D(uType, uv, aspect, effectivePhase);
            float p2 = calculatePattern2D(uType2, uv, aspect, effectivePhase);
            float p = p1;
            
            // Determine which pattern to show based on visualization mode
            if (uVisMode == 1) {
                // Split view: left third = pattern1, middle = blend, right third = pattern2
                if (vUV.s < 0.333) {
                    p = p1;
                } else if (vUV.s < 0.666) {
                    p = mix(p1, p2, localBlend);
                } else {
                    p = p2;
                }
            } else {
                // Normal mode: blended output
                if (localBlend > 0.0) {
                    p = mix(p1, p2, localBlend);
                }
            }
            
            if (uExtend)
                phase = mirror(p);
            else
                phase = repeat(p);
            
            if (uAntiAlias > 0.0) {
                phase = smoothPattern(phase, uAntiAlias);
            }
        }
        
        // Sample colors from appropriate ramps
        if (uVisMode == 1) {
            // Split view color mapping
            if (vUV.s < 0.333) {
                // Left third: Pattern 1 with Color Ramp 1
                color = texture(sTD2DInputs[0], vec2(phase, 0.5));
            } else if (vUV.s < 0.666) {
                // Middle third: Blended colors
                if (localBlend > 0.0 && uNumInputs > 2) {
                    vec4 color1 = texture(sTD2DInputs[0], vec2(phase, 0.5));
                    vec4 color2 = texture(sTD2DInputs[2], vec2(phase, 0.5));
                    color = mix(color1, color2, localBlend);
                } else {
                    color = texture(sTD2DInputs[0], vec2(phase, 0.5));
                }
            } else {
                // Right third: Pattern 2 with Color Ramp 2
                if (uNumInputs > 2) {
                    color = texture(sTD2DInputs[2], vec2(phase, 0.5));
                } else {
                    color = texture(sTD2DInputs[0], vec2(phase, 0.5));
                }
            }
        } else {
            // Normal mode color mapping
            if (localBlend > 0.0 && uNumInputs > 2) {
                // Blend between two color ramps
                vec4 color1 = texture(sTD2DInputs[0], vec2(phase, 0.5));
                vec4 color2 = texture(sTD2DInputs[2], vec2(phase, 0.5));
                color = mix(color1, color2, localBlend);
            } else {
                // Use only first color ramp
                color = texture(sTD2DInputs[0], vec2(phase, 0.5));
            }
        }
    }
    else {
        vec3 aspect = uRes / max(uRes.x, 0.001);
        vec3 originalPos = vUV.xyz;
        
        vec4 controlMap = vec4(0.5);
        float localDistortAmount = uDistortAmount;
        float localBlend = uBlend;
        float localPhase = effectivePhase;
        vec3 controlOffset = vec3(0.0);
        
        if (uUseControlMap > 0.0 && uNumInputs > 1) {
            controlMap = texture(sTD2DInputs[1], vUV.xy);
            
            if (uControlMapMode == 99) {
                color = controlMap;
                fragColor = TDOutputSwizzle(color);
                return;
            }
            
            if (uControlMapMode == 0) {
                controlOffset = (controlMap.rgb - 0.5) * 2.0 * uControlMapStrength * 0.1;
            }
            else if (uControlMapMode == 1) {
                localDistortAmount += abs(controlMap.r - 0.5) * uControlMapStrength * 2.0;
            }
            else if (uControlMapMode == 2) {
                localBlend = mix(localBlend, controlMap.r, uControlMapStrength);
            }
        }
        
        vec3 cameraOffset = (uCameraPos - 0.5) * 2.0;
        vec3 pos = originalPos + cameraOffset * 0.3 + controlOffset * 0.1;
        
        if (localDistortAmount > 0.0) {
            vec3 distortOffset = vec3(
                noise3D(pos * uDistortScale + vec3(0.0, uPhase, 0.0)),
                noise3D(pos * uDistortScale + vec3(100.0, uPhase, 0.0)),
                noise3D(pos * uDistortScale + vec3(0.0, 0.0, uPhase))
            ) * 2.0 - 1.0;
            pos += distortOffset * localDistortAmount * 0.1;
        }
        
        if (uPeriod > 0.0) {
            float p1 = calculatePattern3D(uType, pos, aspect, effectivePhase);
            float p2 = calculatePattern3D(uType2, pos, aspect, effectivePhase);
            float p = p1;
            
            // Determine which pattern to show based on visualization mode
            if (uVisMode == 1) {
                // Split view: left third = pattern1, middle = blend, right third = pattern2
                if (vUV.x < 0.333) {
                    p = p1;
                } else if (vUV.x < 0.666) {
                    p = mix(p1, p2, localBlend);
                } else {
                    p = p2;
                }
            } else {
                // Normal mode: blended output
                if (localBlend > 0.0) {
                    p = mix(p1, p2, localBlend);
                }
            }
            
            if (uExtend)
                phase = mirror(p);
            else
                phase = repeat(p);
            
            if (uAntiAlias > 0.0) {
                phase = smoothPattern(phase, uAntiAlias);
            }
        }
        
        // Sample colors from appropriate ramps
        if (uVisMode == 1) {
            // Split view color mapping
            if (vUV.x < 0.333) {
                // Left third: Pattern 1 with Color Ramp 1
                color = texture(sTD2DInputs[0], vec2(phase, 0.5));
            } else if (vUV.x < 0.666) {
                // Middle third: Blended colors
                if (localBlend > 0.0 && uNumInputs > 2) {
                    vec4 color1 = texture(sTD2DInputs[0], vec2(phase, 0.5));
                    vec4 color2 = texture(sTD2DInputs[2], vec2(phase, 0.5));
                    color = mix(color1, color2, localBlend);
                } else {
                    color = texture(sTD2DInputs[0], vec2(phase, 0.5));
                }
            } else {
                // Right third: Pattern 2 with Color Ramp 2
                if (uNumInputs > 2) {
                    color = texture(sTD2DInputs[2], vec2(phase, 0.5));
                } else {
                    color = texture(sTD2DInputs[0], vec2(phase, 0.5));
                }
            }
        } else {
            // Normal mode color mapping
            if (localBlend > 0.0 && uNumInputs > 2) {
                // Blend between two color ramps
                vec4 color1 = texture(sTD2DInputs[0], vec2(phase, 0.5));
                vec4 color2 = texture(sTD2DInputs[2], vec2(phase, 0.5));
                color = mix(color1, color2, localBlend);
            } else {
                // Use only first color ramp
                color = texture(sTD2DInputs[0], vec2(phase, 0.5));
            }
        }
        
        float epsilon = 0.01;
        vec3 samplePos = pos;
        float p1_center = calculatePattern3D(uType, samplePos, aspect, effectivePhase);
        float p_center = p1_center;
        if (uBlend > 0.0) {
            float p2_center = calculatePattern3D(uType2, samplePos, aspect, effectivePhase);
            p_center = mix(p1_center, p2_center, uBlend);
        }
        
        samplePos = pos + vec3(epsilon, 0.0, 0.0);
        float p1_x = calculatePattern3D(uType, samplePos, aspect, effectivePhase);
        float p_x = p1_x;
        if (uBlend > 0.0) {
            float p2_x = calculatePattern3D(uType2, samplePos, aspect, effectivePhase);
            p_x = mix(p1_x, p2_x, uBlend);
        }
        
        samplePos = pos + vec3(0.0, epsilon, 0.0);
        float p1_y = calculatePattern3D(uType, samplePos, aspect, effectivePhase);
        float p_y = p1_y;
        if (uBlend > 0.0) {
            float p2_y = calculatePattern3D(uType2, samplePos, aspect, effectivePhase);
            p_y = mix(p1_y, p2_y, uBlend);
        }
        
        samplePos = pos + vec3(0.0, 0.0, epsilon);
        float p1_z = calculatePattern3D(uType, samplePos, aspect, effectivePhase);
        float p_z = p1_z;
        if (uBlend > 0.0) {
            float p2_z = calculatePattern3D(uType2, samplePos, aspect, effectivePhase);
            p_z = mix(p1_z, p2_z, uBlend);
        }
        
        vec3 gradient = vec3(p_x - p_center, p_y - p_center, p_z - p_center) / epsilon;
        vec3 normal = normalize(gradient);
        
        vec3 lightDir = normalize(uLightPos.xyz - originalPos);
        vec3 viewDir = normalize(uCameraPos - originalPos);
        vec3 halfDir = normalize(lightDir + viewDir);
        float lightIntensity = uLightPos.w;
        
        float NdotL = max(dot(normal, lightDir), 0.0);
        float NdotV = max(dot(normal, viewDir), 0.0);
        float NdotH = max(dot(normal, halfDir), 0.0);
        
        float fresnel = pow(1.0 - NdotV, 5.0);
        vec3 F0 = mix(vec3(0.04), color.rgb, uMetallic);
        vec3 F = F0 + (1.0 - F0) * fresnel;
        
        float roughness = max(uRoughness * 0.5, 0.01);
        float alpha = roughness * roughness;
        float alpha2 = alpha * alpha;
        float denom = NdotH * NdotH * (alpha2 - 1.0) + 1.0;
        float D = alpha2 / (pi * denom * denom);
        
        float k = roughness * 0.5;
        float G1L = NdotL / (NdotL * (1.0 - k) + k);
        float G1V = NdotV / (NdotV * (1.0 - k) + k);
        float G = G1L * G1V;
        
        vec3 specularBRDF = (D * G * F) / (4.0 * NdotL * NdotV + 0.001);
        vec3 diffuse = color.rgb * (1.0 - uMetallic) * NdotL / pi;
        vec3 specularColor = specularBRDF * NdotL * 5.0;
        vec3 ambient = color.rgb * 0.1;
        vec3 litColor = ambient + (diffuse + specularColor) * lightIntensity;
        
        float lightingMix = 0.7;
        color.rgb = mix(color.rgb, litColor, lightingMix);
    }
    
    fragColor = TDOutputSwizzle(color);
}

