
Strict

Module MaxB3D.PLYLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import MaxB3D.Logging

Import Prime.libply

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "plyloader",message
End Function

Public

Type TMeshLoaderPLY Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If stream=Null Return
		Local file:TPlyFile=TPlyFile.Read(stream)
		If file=Null Return Null
		
		Local face:TPlyElement=file.FindElement("face")
		Local indices:TPlyProperty=face.FindProperty("vertex_indices")
		If indices=Null indices=face.FindProperty("vertex_index")

		Local vertices:TPlyElement=file.FindElement("vertex")
		Local vertex_x:TPlyProperty=vertices.FindProperty("x")
		Local vertex_y:TPlyProperty=vertices.FindProperty("y")
		Local vertex_z:TPlyProperty=vertices.FindProperty("z")
		
		Local surface:TSurface=mesh.AddSurface() 
		For Local i=0 To face.count-1
			Local verts[]=indices.ListAsInt(i),tris=verts.length-2
			Local vcnt,tcnt
			
			surface.GetSize vcnt,tcnt
			surface.Resize vcnt+tris*3,tcnt+tris
			
			For Local t=0 To tris-1
				Local v0=vcnt+t*3+0,v1=vcnt+t*3+1,v2=vcnt+t*3+2		
				Local vi0=verts[0],vi1=verts[t+1],vi2=verts[t+2]
				
				surface.SetCoords v0,vertex_x.AsFloat(vi0),vertex_y.AsFloat(vi0),vertex_z.AsFloat(vi0)
				surface.SetCoords v1,vertex_x.AsFloat(vi1),vertex_y.AsFloat(vi1),vertex_z.AsFloat(vi1)
				surface.SetCoords v2,vertex_x.AsFloat(vi2),vertex_y.AsFloat(vi2),vertex_z.AsFloat(vi2)
				
				surface.SetTriangle tcnt+t,v0,v1,v2
			Next
		Next
		surface.UpdateNormals
		
		Return True
	End Method
	
	Method Info$()
		Return "Polygon File Format|.ply"
	End Method
	Method ModuleName$()
		Return "plyloader"
	End Method
End Type
New TMeshLoaderPLY

