# GLSL Unified Pattern Generator - Examples

Quick-start presets for common use cases.

## 🎯 Copy-Paste Presets

### 1. Classic Spiral Animation
```
uDimension: 0
uType: 4
uPeriod: 0.15
uPhase: 0.0
uExtend: 1
uRes: (1920, 1080, 1)
uParam1: 0.5
uParam2: 0.5
uParam3: 0.5
uDistortAmount: 0.0
uDistortScale: 5.0
uAntiAlias: 0.3
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.3
uNumInputs: 1
uBlend: 0.0
uType2: 0
uUseControlMap: 0.0
uControlMapMode: 0
uControlMapStrength: 1.0
uVisMode: 0
```

### 2. Organic Voronoi Cells
```
uDimension: 0
uType: 9
uPeriod: 0.2
uParam1: 0.6
uExtend: 0
uDistortAmount: 0.2
uDistortScale: 3.0
uAntiAlias: 0.5
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.1
```

### 3. 3D Gyroid with Lighting
```
uDimension: 1
uType: 12
uPeriod: 0.2
uParam1: 0.6
uParam2: 0.5
uParam3: 0.5
uRes: (1920, 1080, 1080)
uCameraPos: (0.5, 0.5, 0.5)
uLightPos: (1.0, 1.0, 0.5, 1.5)
uMetallic: 0.8
uRoughness: 0.2
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.2
```

### 4. Blended Radial + Noise
```
uDimension: 0
uType: 2
uType2: 8
uBlend: 0.5
uPeriod: 0.15
uParam1: 0.6
uParam2: 0.3
uExtend: 1
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.4
uNumInputs: 1
```

### 5. Flow Field (Animated)
```
uDimension: 0
uType: 13
uPeriod: 0.3
uParam1: 0.5
uParam2: 0.5
uDistortAmount: 0.1
uDistortScale: 4.0
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.15
```

### 6. Kaleidoscope (Polar Grid)
```
uDimension: 0
uType: 10
uPeriod: 0.1
uParam1: 0.5 (12 spokes)
uParam2: 0.625 (10 rings)
uExtend: 1
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.5
```

### 7. Lissajous Figure
```
uDimension: 0
uType: 11
uPeriod: 0.25
uParam1: 0.375 (3 cycles X)
uParam2: 0.5 (4 cycles Y)
uExtend: 0
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.2
```

### 8. Diamond Lattice
```
uDimension: 0
uType: 5
uPeriod: 0.15
uParam1: 0.5 (shape blend)
uParam2: 0.0 (rotation)
uExtend: 1
uAntiAlias: 0.5
```

### 9. 3D Spherical Waves
```
uDimension: 1
uType: 3
uPeriod: 0.15
uParam1: 0.5 (center X)
uParam2: 0.5 (center Y)
uParam3: 0.5 (center Z)
uRes: (1920, 1080, 1080)
uCameraPos: (0.5, 0.5, 0.5)
uLightPos: (0.8, 0.8, 0.5, 1.0)
uMetallic: 0.3
uRoughness: 0.5
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.3
```

### 10. Grid Pattern
```
uDimension: 0
uType: 6
uPeriod: 0.2
uParam1: 0.5 (scale X)
uParam2: 0.5 (scale Y)
uExtend: 0
uAntiAlias: 0.3
```

---

## 🎨 Color Ramp Suggestions

### Preset 1: Fire
- Colors: Black → Red → Orange → Yellow → White
- Use with: Flow Field, Wave, Noise

### Preset 2: Ice
- Colors: Black → Dark Blue → Cyan → White
- Use with: Voronoi, Gyroid, Diamond

### Preset 3: Rainbow
- Colors: Red → Orange → Yellow → Green → Blue → Purple → Red
- Use with: Spiral, Radial, Polar Grid

### Preset 4: Monochrome
- Colors: Black → Gray → White
- Use with: Lissajous, Grid, Horizontal

### Preset 5: Neon
- Colors: Black → Cyan → Magenta → Yellow → White (high saturation)
- Use with: Flow Field, Noise, Wave

---

## 🎬 Animation Recipes

### Slow Drift
```
uPhaseSpeed: 0.1
uDistortAmount: 0.05
```

### Fast Pulse
```
uPhaseSpeed: 2.0
uDistortAmount: 0.0
```

### Organic Breathing
```
uPhaseSpeed: 0.2
uDistortAmount: 0.3
uDistortScale: 2.0
```

### Chaotic
```
uPhaseSpeed: 1.5
uDistortAmount: 0.5
uDistortScale: 8.0
```

---

## 🎛️ Control Map Examples

### Example A: Video Controls Flow Direction
1. Connect Movie File In TOP to Input 2
2. Set uniforms:
   ```
   uNumInputs: 2
   uUseControlMap: 1.0
   uControlMapMode: 0 (direction)
   uControlMapStrength: 0.8
   ```
3. Bright areas in video will push pattern

### Example B: Noise Controls Distortion
1. Connect Noise TOP to Input 2
2. Set uniforms:
   ```
   uNumInputs: 2
   uUseControlMap: 1.0
   uControlMapMode: 1 (distortion)
   uControlMapStrength: 1.0
   ```
3. Pattern will warp based on noise

### Example C: Audio Reactive Blend
1. Use Audio Spectrum → Math CHOP
2. Drive uControlMapStrength with audio level
3. Set:
   ```
   uControlMapMode: 2 (blend)
   uControlMapStrength: op('audiomath')['chan0']
   ```

---

## 🚀 Performance Profiles

### High Quality (Slow)
```
Resolution: 2048x2048
uAntiAlias: 0.8
uDimension: 1
uDistortAmount: 0.3
```

### Balanced
```
Resolution: 1024x1024
uAntiAlias: 0.3
uDimension: 0
uDistortAmount: 0.1
```

### Fast (Real-time)
```
Resolution: 512x512
uAntiAlias: 0.0
uDimension: 0
uDistortAmount: 0.0
```

---

## 💡 Creative Combinations

### Combo 1: Coral Growth
- Type: 9 (Voronoi)
- Slow phase speed (0.05)
- High distortion (0.4)
- Mirror mode

### Combo 2: Liquid Metal
- Type: 12 (Gyroid) in 3D
- High metallic (0.9)
- Low roughness (0.1)
- Slow rotation

### Combo 3: Tribal Patterns
- Type: 10 (Polar Grid)
- Many spokes (Param1 > 0.7)
- Few rings (Param2 < 0.3)
- High contrast color ramp

### Combo 4: Plasma Effect
- Type: 13 (Flow Field)
- Blend with Type 8 (Noise)
- High phase speed (1.0)
- Medium distortion (0.2)

### Combo 5: Holographic
- Type: 11 (Lissajous) in 3D
- Medium metallic (0.5)
- Medium roughness (0.4)
- Rainbow color ramp

---

## 📐 Resolution Guide

| Use Case | Resolution | Notes |
|----------|-----------|-------|
| Preview | 512×512 | Fast iteration |
| Standard Output | 1920×1080 | Full HD |
| Square Instagram | 1080×1080 | Social media |
| 4K Export | 3840×2160 | High quality |
| Projection Mapping | 1920×1080 | Per projector |
| LED Wall | Match LED resolution | Pixel-perfect |
| VR/360 | 4096×2048 | Equirectangular |

---

## 🎓 Learning Path

1. **Start Simple**: Try Horizontal (Type 0) with animation
2. **Add Complexity**: Switch to Spiral (Type 4), adjust params
3. **Blend Patterns**: Mix two types with uBlend
4. **Add Distortion**: Enable uDistortAmount
5. **Try Control Maps**: Use noise to drive patterns
6. **Go 3D**: Switch uDimension to 1, add lighting
7. **Advanced**: Flow Field + Control Map + Blending

---

## 🛠️ Troubleshooting Recipes

### Pattern too busy
- Increase uPeriod (0.3 or higher)
- Reduce uParam1 (for most patterns)

### Pattern too boring
- Add distortion (uDistortAmount = 0.2)
- Blend two patterns (uBlend = 0.5)
- Use control map

### Animation too jerky
- Lower uPhaseSpeed (try 0.1-0.3)
- Enable anti-aliasing (uAntiAlias = 0.3)

### 3D looks flat
- Move camera (uCameraPos away from 0.5,0.5,0.5)
- Increase light (uLightPos.w = 2.0)
- Adjust metallic/roughness

---

Happy pattern generating! 🌟

