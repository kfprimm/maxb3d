# MaxB3D - A 3D engine for BlitzMax
Copyright (C) 2011 by Kevin Primm

MaxB3D aims to be a full 3D engine for BlitzMax that is capable of providing a modern Blitz3D-like programming experience.

Originally conceived as a project to bridge the gap of minor features between MiniB3D and Blitz3D, it has since evolved into a completely new project written from the ground up to be platform and graphics API agnostic.

## Installation

Install the following modules scopes:
http://github.com/kfprimm/prime.mod
http://github.com/kfprimm/gfx.mod

Then, apply this [fix](https://github.com/kfprimm/maxb3d/wiki/BRL.DXGraphics-Tweak) to get the D3D9 driver working properly. If you're on Linux or Mac OS, you can safely skip this.

## Getting Started

To use MaxB3D, simply import the main meta-module.

```blitzmax
Import MaxB3D.Drivers
```

This will import the core module as well as the primitive loader, functions module, and standard collision driver. It will not import any mesh loaders.

To import all available mesh loaders:

```blitzmax
Import MaxB3D.Loaders
```

Alternatively, you may import only the loaders you need:

```blitzmax
Import MaxB3D.A3DSLoader       ' Autodesk 3DS
Import MaxB3D.B3DLoader        ' Blitz3D
Import MaxB3D.BSPLoader        ' TBSPTree to mesh
Import MaxB3D.BunnyLoader      ' Stanford bunny model
Import MaxB3D.HeightmapLoader  ' Pixmap to mesh
Import MaxB3D.MD2Loader        ' Quake II MD2
Import MaxB3D.MonkeyHeadLoader ' CreateMonkeyHead(), Blender Suzanne model
Import MaxB3D.MS3DLoader       ' Milkshape 3D
Import MaxB3D.OBJLoader        ' Wavefront OBJ
Import MaxB3D.PLYLoader        ' Polygon File Format
Import MaxB3D.TeapotLoader     ' CreateTeapot(), Utah teapot model
Import MaxB3D.XLoader          ' Direct X
```

Don't see a file format you need? Check out the [wiki page](https://github.com/kfprimm/maxb3d/wiki/Writing-a-mesh-loader) on writing a custom mesh loader. If it's a common format, please consider contributing it back to the project.

## Notes

This library is still under initial development. While most of the groundwork is laid, the API is still subject to change without warning. 

Do not begin any serious projects with this library unless you intend to freeze your codebase, or keep up with the changes.

## Contributors

 * Kevin Primm [[kfprimm](https://github.com/kfprimm)]

## LICENSE

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```