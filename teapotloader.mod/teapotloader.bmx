
Strict

Module MaxB3D.TeapotLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import MaxB3D.Core
Import BRL.RamStream

Incbin "data.dat"

Function CreateTeapot:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*teapot*",parent)
End Function

Type TMeshLoaderTeapot Extends TMeshLoader
	Method Run(url:Object,mesh:TMesh)
		If String(url)="*teapot*"
			Local stream:TStream=ReadStream("incbin::teapot.dat")
			Local vertexcount=ReadInt(stream),trianglecount=ReadInt(stream)

			Local surface:TSurface=mesh.AddSurface(vertexcount,trianglecount)			
			
			For Local i=0 To vertexcount-1
				Local x#=ReadFloat(stream),y#=ReadFloat(stream),z#=ReadFloat(stream)
				Local u#=ReadFloat(stream),v#=ReadFloat(stream)
				surface.AddVertex(x,y,z,u,v)
			Next
			
			For Local i=0 To trianglecount-1
				Local v0=ReadInt(stream),v1=ReadInt(stream),v2=ReadInt(stream)
				surface.AddTriangle v0,v1,v2
			Next
			CloseStream stream
			
			surface.UpdateNormals()
			Return True
		EndIf
	End Method
End Type

New TMeshLoaderTeapot

