# Changelog

All notable changes to the GLSL Unified Pattern Generator will be documented in this file.

## [1.0.0] - 2025-11-24

### Added
- Initial release of unified 2D/3D pattern generator
- 14 procedural pattern types:
  - Geometric: Horizontal, Vertical, Radial, Circular, Spiral, Diamond, Grid
  - Organic: Noise, Voronoi, Wave, Flow Field
  - Advanced: Polar Grid, Lissajous Curves, Gyroid (TPMS)
- Dual pattern blending system
- Control map support with 3 modes (direction, distortion, blend)
- 3D mode with PBR lighting (metallic/roughness workflow)
- UV distortion with procedural noise
- Anti-aliasing support
- Time-based animation system
- Split-screen visualization mode for comparing patterns
- Comprehensive documentation and examples

### Features
- Seamless 2D/3D switching
- Aspect ratio correction
- Normal calculation from pattern gradients (3D)
- Cook-Torrance BRDF lighting model (3D)
- Support for up to 3 texture inputs (color ramps + control map)
- Per-pattern parameter control (3 parameters per pattern)
- Mirror/Repeat wrapping modes
- Debug mode for control maps

### Technical
- Optimized Laplacian operator for 3D
- Hash-based procedural noise functions (2D/3D)
- Voronoi/cellular noise (2D/3D)
- Curl noise for flow fields
- Triply periodic minimal surfaces (Gyroid)

