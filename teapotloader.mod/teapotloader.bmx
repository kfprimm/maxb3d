
Strict

Rem
	bbdoc: Utah teapot mesh loader loader for MaxB3D
End Rem
Module MaxB3D.TeapotLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.RamStream

Incbin "data.dat"

Rem
	bbdoc: Creates a teapot mesh.
End Rem
Function CreateTeapot:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*teapot*",parent)
End Function

Type TMeshLoaderTeapot Extends TMeshLoader
	Field _surface:TSurface
	
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If String(url)<>"*teapot*" Return False
		If _surface=Null
			stream=ReadStream("incbin::data.dat")
			Local vertexcount=ReadInt(stream),trianglecount=ReadInt(stream)
			
			_surface=New TSurface
			_surface.Resize(vertexcount,trianglecount)			
			
			For Local i=0 To vertexcount-1
				Local x#=ReadFloat(stream),y#=ReadFloat(stream),z#=ReadFloat(stream)
				Local u#=ReadFloat(stream),v#=ReadFloat(stream)
				_surface.SetCoords(i,x,y,z)
				_surface.SetTexCoords(i,u,v)
			Next
			
			For Local i=0 To trianglecount-1
				Local v0=ReadInt(stream),v1=ReadInt(stream),v2=ReadInt(stream)
				_surface.SetTriangle i,v0,v1,v2
			Next
			CloseStream stream
			
			_surface.UpdateNormals()
		EndIf
		mesh.AppendSurface _surface.Copy()
		Return True
	End Method
	
	Method Info$()
		Return "Utah teapot"
	End Method
	Method ModuleName$()
		Return "teapotloader"
	End Method
End Type

New TMeshLoaderTeapot