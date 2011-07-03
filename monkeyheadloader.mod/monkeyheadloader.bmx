
Strict

Rem
	bbdoc: Blender's 'Suzanne' model loader.
End Rem
Module MaxB3D.MonkeyHeadLoader

Import MaxB3D.Core
Import "data.c"

Extern
	Function get_monkeyhead(verts:Float Ptr Var,normals:Float Ptr Var,tris:Short Ptr Var,vert_count Var,tri_count Var)
End Extern

Type TMeshLoaderMONKEYHEAD Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If String(url)<>"*monkeyhead*" Return False
		Global surface:TSurface
		If Not surface
			surface=New TSurface
			Local v:Float Ptr,n:Float Ptr,t:Short Ptr,vc,tc
			get_monkeyhead v,n,t,vc,tc
			surface.Resize vc,tc
			
			For Local i=0 To vc-1
				surface.SetCoord i,v[i*3+0],v[i*3+1],v[i*3+2]
				'surface.SetNormal i,-n[i*3+0],-n[i*3+1],-n[i*3+2]
			Next
			
			For Local i=0 To tc-1
				surface.SetTriangle i,t[i*3+0],t[i*3+1],t[i*3+2]
			Next
		EndIf
		mesh.AppendSurface surface.Copy()
		Return True
	End Method
	
	Method Name$()
		Return "Suzanne"
	End Method
	Method ModuleName$()
		Return "monkeyheadloader"
	End Method
End Type
New TMeshLoaderMONKEYHEAD

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateMonkeyHead:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*monkeyhead*",parent)
End Function
