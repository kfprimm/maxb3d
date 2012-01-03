
Strict

Module MaxB3D.XLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import Prime.libx

Type TMeshLoaderX Extends TMeshLoader
	Method Run(config:TWorldConfig,mesh:TMesh,stream:TStream,url:Object)
		If stream = Null Return False
		
		Local file:TXFile=TXFile.Read(url)
		If file=Null Return False
'		file.DumpInfo
		
		Local curr:TMesh = Null		
		For Local entry:TXEntry = Eachin file.Entries
			Select entry.TemplateName
			Case "Mesh"
				If curr = Null curr = mesh
				ParseMesh entry, curr
			End Select
		Next
							
		Return True
	End Method	
	
	Method ParseMesh(entry:TXEntry, mesh:TMesh)
		Local tris[] = entry.Data[2].ToIntArray()
		Local verts#[] = entry.Data[1].ToFloatArray()

		Local surface:TSurface = mesh.AddSurface()
		surface.Resize verts.length, tris.length-1

		For Local i = 0 To verts.length-1 Step 3
			surface.SetCoords i/3,verts[i+0],verts[i+1],verts[i+2]
		Next
		For Local i=1 to tris.length-1 step 4
			surface.SetTriangle (i-1)/4,tris[i+1],tris[i+2],tris[i+3]
		Next
		
		For Local subentry:TXEntry = Eachin entry.Children
			Select subentry.TemplateName
			Case "MeshNormals"
				tris = subentry.Data[2].ToIntArray()
				Local nmls#[] = subentry.Data[1].ToFloatArray()
				For Local i = 0 To tris[0]-1
					Local v0,v1,v2
					surface.GetTriangle i,v0,v1,v2
					surface.SetNormal v0,nmls[tris[i*4+1]],nmls[tris[i*4+2]],nmls[tris[i*4+3]]
					surface.SetNormal v1,nmls[tris[i*4+1]],nmls[tris[i*4+2]],nmls[tris[i*4+3]]
					surface.SetNormal v2,nmls[tris[i*4+1]],nmls[tris[i*4+2]],nmls[tris[i*4+3]]
				Next
			End Select
		Next							
	End Method
	
	Method Info$()
		Return "DirectX|.x"
	End Method
	Method ModuleName$()
		Return "xloader"
	End Method
End Type
New TMeshLoaderX

