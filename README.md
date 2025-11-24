# GLSL Unified Pattern Generator

A powerful 2D/3D procedural pattern generator for TouchDesigner with 14+ pattern types, blending, control maps, and advanced 3D lighting.

## Features

### 🎨 **14 Pattern Types**
- **Geometric**: Horizontal, Vertical, Radial, Circular, Spiral, Diamond, Grid
- **Organic**: Noise, Voronoi, Wave, Flow Field
- **Advanced**: Polar Grid, Lissajous Curves, Gyroid (TPMS)

### 🔀 **Dual Pattern System**
- Blend between two different pattern types
- Independent parameters for each pattern
- Smooth interpolation and visualization modes

### 🎛️ **Control Maps**
- Use textures to drive pattern behavior
- **Direction Mode**: Control pattern movement/flow
- **Distortion Mode**: Modulate distortion intensity
- **Blend Mode**: Spatially control pattern blending

### 🌐 **2D & 3D Modes**
- Seamless switching between 2D and 3D
- 3D includes full PBR lighting (metallic/roughness workflow)
- Volumetric patterns with camera control

### ✨ **Advanced Features**
- UV distortion with noise
- Anti-aliasing
- Time-based animation
- Split-screen visualization mode
- Color ramp support (1D texture inputs)

## Quick Start (TouchDesigner)

### Basic Setup

1. **Create GLSL TOP**
   - Add a GLSL TOP operator
   - Paste `glsl_unified.glsl` code into the shader

2. **Connect Color Ramp**
   - Create a Ramp TOP (set to 1D horizontal)
   - Wire Ramp → GLSL Input 1

3. **Set Minimum Uniforms**
   ```
   uDimension: 0 (2D) or 1 (3D)
   uType: 0-13 (pattern type)
   uPeriod: 0.1 (pattern frequency)
   uPhase: 0.0
   uExtend: 0 (repeat) or 1 (mirror)
   uRes: (1920, 1080, 1) for 2D
   uParam1: 0.5
   uParam2: 0.5
   uParam3: 0.5
   uNumInputs: 1
   ```

4. **Animate It**
   ```
   uTime: absTime.seconds
   uUseTimePhase: 1.0
   uPhaseSpeed: 0.5
   ```

## Pattern Reference

### 2D Patterns

| Type | Name | Param1 | Param2 | Param3 |
|------|------|--------|--------|--------|
| 0 | Horizontal | Skew | - | - |
| 1 | Vertical | Skew | - | - |
| 2 | Radial | Segments | Rotation | - |
| 3 | Circular | Center X | Center Y | - |
| 4 | Spiral | Tightness | Direction | - |
| 5 | Diamond | Shape Mix | Rotation | - |
| 6 | Grid | Scale X | Scale Y | - |
| 7 | Wave | Frequency | Amplitude | Direction |
| 8 | Noise | Scale | - | - |
| 9 | Voronoi | Scale | - | - |
| 10 | Polar Grid | Spokes | Rings | - |
| 11 | Lissajous | Freq X | Freq Y | - |
| 12 | Gyroid | Scale | Z-Slice | - |
| 13 | Flow Field | Scale | Rotation | - |

### 3D Patterns

All 2D patterns have 3D equivalents with additional depth control via Param3.

## Advanced Usage

### Pattern Blending

```
uType: 0 (Horizontal)
uType2: 3 (Circular)
uBlend: 0.5 (50% mix)
uNumInputs: 3 (if using 2 color ramps)
```

### Control Map Setup

1. Connect a texture to Input 2
2. Set uniforms:
   ```
   uNumInputs: 2 or 3
   uUseControlMap: 1.0
   uControlMapMode: 0 (direction), 1 (distortion), or 2 (blend)
   uControlMapStrength: 1.0
   ```

### 3D Mode with Lighting

```
uDimension: 1
uCameraPos: (0.5, 0.5, 0.5)
uLightPos: (0.8, 0.8, 0.5, 1.0)
uMetallic: 0.5
uRoughness: 0.3
```

### Split View Visualization

```
uVisMode: 1
```
Shows: Left third = Pattern 1, Middle = Blend, Right = Pattern 2

## Full Uniform Reference

### Core
- `uDimension` (int): 0=2D, 1=3D
- `uType` (int): Primary pattern type (0-13)
- `uType2` (int): Secondary pattern type (0-13)
- `uBlend` (float): Blend between patterns (0.0-1.0)
- `uPhase` (float): Pattern phase/offset
- `uPeriod` (float): Pattern frequency (0.01-1.0)
- `uExtend` (bool): 0=repeat, 1=mirror
- `uRes` (vec3): Resolution (x, y, z)

### Pattern Parameters
- `uParam1` (float): Pattern-specific parameter 1 (0.0-1.0)
- `uParam2` (float): Pattern-specific parameter 2 (0.0-1.0)
- `uParam3` (float): Pattern-specific parameter 3 (0.0-1.0)

### Distortion
- `uDistortAmount` (float): Distortion strength (0.0-1.0)
- `uDistortScale` (float): Distortion noise scale (1.0-10.0)

### Visual Quality
- `uAntiAlias` (float): Anti-aliasing amount (0.0-1.0)

### 3D Lighting (3D mode only)
- `uCameraPos` (vec3): Camera position (0.0-1.0 per axis)
- `uLightPos` (vec4): Light position (xyz) + brightness (w)
- `uMetallic` (float): Metallic factor (0.0-1.0)
- `uRoughness` (float): Roughness factor (0.0-1.0)

### Control Map
- `uUseControlMap` (float): Enable control map (0.0 or 1.0)
- `uControlMapMode` (int): 0=direction, 1=distortion, 2=blend, 99=debug
- `uControlMapStrength` (float): Control map influence (0.0-1.0)
- `uNumInputs` (int): Number of texture inputs (1-3)

### Animation
- `uTime` (float): Time source (absTime.seconds)
- `uUseTimePhase` (float): Enable time-based animation (0.0 or 1.0)
- `uPhaseSpeed` (float): Animation speed multiplier (0.1-5.0)

### Visualization
- `uVisMode` (int): 0=normal, 1=split view

## Examples

### Example 1: Animated Spiral
```
uDimension: 0
uType: 4 (Spiral)
uPeriod: 0.15
uParam1: 0.5 (tightness)
uParam2: 0.5 (direction)
uExtend: 1 (mirror)
uTime: absTime.seconds
uUseTimePhase: 1.0
uPhaseSpeed: 0.3
```

### Example 2: 3D Gyroid with Lighting
```
uDimension: 1
uType: 12 (Gyroid)
uPeriod: 0.2
uParam1: 0.6 (scale)
uCameraPos: (0.5, 0.5, 0.5)
uLightPos: (1.0, 1.0, 0.5, 1.5)
uMetallic: 0.8
uRoughness: 0.2
```

### Example 3: Noise-Controlled Flow
```
uDimension: 0
uType: 13 (Flow Field)
uPeriod: 0.3
uNumInputs: 2
uUseControlMap: 1.0
uControlMapMode: 0 (direction)
uControlMapStrength: 0.7
```
Connect a Noise TOP to Input 2

### Example 4: Blended Patterns
```
uDimension: 0
uType: 2 (Radial)
uType2: 8 (Noise)
uBlend: 0.5
uPeriod: 0.15
uParam1: 0.6
```

## Performance Tips

1. **Start Simple**: Begin with 2D mode and basic patterns
2. **Resolution**: Lower resolution = faster (especially for 3D)
3. **Distortion**: Set `uDistortAmount = 0.0` if not needed
4. **Anti-aliasing**: Disable (`uAntiAlias = 0.0`) for performance
5. **3D Lighting**: Most expensive feature - optimize parameters

## Technical Details

### Pattern Coordinate System
- UV space: (0, 0) to (1, 1)
- Aspect ratio corrected automatically
- Phase wraps seamlessly for tiling

### Control Map Channels
- **R channel**: Primary control (direction X, distortion, or blend)
- **G channel**: Secondary control (direction Y)
- **B channel**: Tertiary control (direction Z in 3D)

### 3D Lighting Model
- Physically-Based Rendering (PBR)
- Cook-Torrance BRDF
- Fresnel, Distribution, Geometry functions
- Normal calculated from pattern gradients

## Troubleshooting

### Pattern not visible
- Check `uPeriod` is not too small (try 0.1-0.3)
- Verify color ramp is connected to Input 1
- Ensure `uRes` matches your resolution

### Pattern too fast/slow
- Adjust `uPhaseSpeed` (lower = slower)
- Or adjust `uPeriod` (higher = fewer repetitions)

### 3D mode looks flat
- Increase lighting: `uLightPos.w = 2.0`
- Adjust camera: `uCameraPos` away from (0.5, 0.5, 0.5)
- Try different patterns (Gyroid, Voronoi work well)

### Control map not working
- Verify `uNumInputs = 2` or `3`
- Set `uUseControlMap = 1.0`
- Check texture is connected to correct input
- Try `uControlMapMode = 99` (debug) to see the map

## License

Free to use for any purpose. Attribution appreciated but not required.

## Version History

**v1.0** - Initial release
- 14 pattern types (2D/3D)
- Dual pattern blending
- Control map support
- 3D PBR lighting
- Time-based animation

