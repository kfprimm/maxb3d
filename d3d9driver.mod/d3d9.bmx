
Strict

Import PUB.DirectX
Import "d3d9.cpp"

' D3DFILLMODE
Const D3DFILL_POINT			= 1
Const D3DFILL_WIREFRAME	= 2
Const D3DFILL_SOLID			= 3

Extern "C"
	Function maxb3dD3D9VertexElements:Byte Ptr()'="_maxb3dD3D9VertexElements@0"
End Extern

Function GetD3D9MaxB3DVertexDecl:IDirect3DVertexDeclaration9(d3ddev:IDirect3DDevice9)
	Global decl:IDirect3DVertexDeclaration9,dev:IDirect3DDevice9
	If decl=Null Or dev<>d3ddev
		Assert d3ddev.CreateVertexDeclaration(maxb3dD3D9VertexElements(),decl)=D3D_OK,"Failed to create vertex declaration."
		dev=d3ddev
	EndIf
	Return decl
End Function

Function D3DCOLOR_XRGB(red,green,blue)
	Return D3DCOLOR_ARGB(255,red,green,blue)
End Function

Function D3DCOLOR_ARGB(alpha,red,green,blue)
	Return ((alpha&$ff) Shl 24)|((red&$ff) Shl 16)|((green&$ff) Shl 8)|(blue&$ff)
End Function


'''' TESTING!!!
Global d3d_set_camera(d3ddev:IDirect3DDevice9)
Global d3d_draw_cube(d3ddev:IDirect3DDevice9)


Local lib=LoadLibraryA("d3d9_testing.dll")
d3d_set_camera=GetProcAddress(lib,"_d3d_set_camera@4")
d3d_draw_cube=GetProcAddress(lib,"_d3d_draw_cube@4")
DebugLog "loaded"

