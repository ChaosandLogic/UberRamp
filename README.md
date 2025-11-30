# UberRamp - A GLSL Pattern Generator for Touchdesigner

	![uberramp touchdesigner glsl](/assets/images/screenshot.png)

A powerful 2D/3D procedural pattern generator for TouchDesigner with 14+ pattern types, blending, control maps, and lighting.

## Features

**14 Pattern Types**
- **Geometric**: Horizontal, Vertical, Radial, Circular, Spiral, Diamond, Grid
- **Organic**: Noise, Voronoi, Wave, Flow Field
- **Advanced**: Polar Grid, Lissajous Curves, Gyroid (TPMS)

**Dual Pattern System**
- Blend between two different pattern types
- Independent parameters for each pattern
- Smooth interpolation and visualization modes

**Control Maps**
- Use textures to drive pattern behavior
- **Direction Mode**: Control pattern movement/flow
- **Distortion Mode**: Modulate distortion intensity
- **Blend Mode**: Spatially control pattern blending

**2D & 3D Modes**
- switch between 2D and 3D
- 3D includes full PBR lighting (metallic/roughness workflow)
- Volumetric patterns with camera control

**Advanced Features**
- UV distortion with noise
- Anti-aliasing
- Time-based animation
- Split-screen visualization mode
- Color ramp support (1D texture inputs)


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

## License

Free to use for any purpose. Attribution appreciated but not required.

## Version History

**v1.0** - Initial release
- 14 pattern types (2D/3D)
- Dual pattern blending
- Control map support
- 3D PBR lighting
- Time-based animation

