
Strict

Rem
	bbdoc: Stanford Bunny mesh loader for MaxB3D
End Rem
Module MaxB3D.BunnyLoader
ModuleInfo "Author: Kevin Primm"

Import MaxB3D.Core
Import "stanford_bunny.c"

Extern
	Function _maxb3d_bunny_indicies:Short Ptr(i,j)
	Function _maxb3d_bunny_vertices:Float Ptr(i,j)
	Function _maxb3d_bunny_normals:Float Ptr(i,j)
End Extern

Rem
	bbdoc: Creates a Stanford bunny mesh.
End Rem
Function CreateBunny:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("//bunny",parent)
End Function

' 8146 Verticies,8127 Normals,16301 Triangles
Type TMeshLoaderBunny Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If String(url)<>"//bunny"Return False
		
		Global surface:TSurface
		If Not surface		
			surface=New TSurface
			
			Local triangle_count=16301
			surface.Resize(triangle_count*3,triangle_count)
			
			For Local i=0 To triangle_count-1
	    	For Local j=0 To 2
					Local vi=_maxb3d_bunny_indicies(i,j)[0]
					Local ni=_maxb3d_bunny_indicies(i,j+3)[0]
					
					Local v:Float Ptr=_maxb3d_bunny_vertices(vi,0)
					Local n:Float Ptr=_maxb3d_bunny_normals(ni,0)
					
					surface.SetCoords i*3+j,v[0],v[1],v[2] 
					surface.SetNormal i*3+j,-n[0],-n[1],-n[2] 
	     	Next
				surface.SetTriangle i,i*3+0,i*3+1,i*3+2
			Next
		EndIf
		
		mesh.AppendSurface surface.Copy()
		
		Return True
	End Method
	
	Method Info$()
		Return "Stanford bunny"
	End Method
	Method ModuleName$()
		Return "bunnyloader"
	End Method
End Type
New TMeshLoaderBunny
