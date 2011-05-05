
Strict

Rem
	bbdoc: Autodesk 3DS loader for MaxB3D
End Rem
Module MaxB3D.A3DSLoader

ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Uses Markus Ranch's 3DS loading code from the BlitzBasic.com Code Archives."

Import MaxB3D.Core
Import "MR_3DS.bmx"

Type TMeshLoader3DS Extends TMeshLoader
	Method Run(url:Object,mesh:TMesh)	
		If ExtractExt(String(url))<>"3ds" Return False
		If Not Load3DSIntoMemory(String(url)) Return False
		
		For Local m:T3DSMesh=EachIn _3DSMeshList
			Local surface:TSurface=mesh.AddSurface(m.NumVerts,m.NumFaces)
			For Local v=0 To m.NumVerts-1
				Local vert:T3DSVert=m.VertArray[v],tex:T3DSTex=m.TexArray[v]
				surface.SetCoord(v,vert.x,vert.y,vert.z)
				surface.SetTexCoord(v,tex.u,tex.v)
			Next
			
			For Local f=0 To m.NumFaces-1
				Local face:T3DSFace=m.FaceArray[f]
				surface.SetTriangle(f,face.a,face.b,face.c)
				Local mat:T3DSMaterial=face.Material
				Local brush:TBrush=_currentworld.AddBrush()
				brush.SetColor(mat.DiffuseColour.r,mat.DiffuseColour.g,mat.DiffuseColour.b)
				surface.SetBrush brush
			Next
		Next
		mesh.UpdateNormals()
		
		Return True
	End Method
End Type
New TMeshLoader3DS