
Strict

Rem
	bbdoc: Wavefront .OBJ loader for MaxB3D
End Rem
Module MaxB3D.OBJLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.Map

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "objloader",message
End Function

Public

Type TMeshLoaderOBJ Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If Not stream Return False
		
		Local surface:TSurface=New TSurface
		Local v#[],vt#[],vn#[]
		While Not Eof(stream)
			Local line$=ReadLine(stream).Trim()
			If line[..2]="vt"
				Local i$[]=Split(line)
				vt:+[Float(i[1]),Float(i[2])]
				Continue
			ElseIf line[..2]="vn"
				Local i$[]=Split(line)
				vn:+[Float(i[1]),Float(i[2]),Float(i[3])]
				Continue
			EndIf
			Select Chr(line[0])
			Case "o"
				mesh.SetName line[1..]
			Case "g"
'				surface=mesh.AddSurface()
			Case "v"
				Local i$[]=Split(line)
				v:+[Float(i[1]),Float(i[2]),Float(i[3])]
			Case "f"
				Local i$[]=Split(line)[1..],verts[i.length,3]
				For Local j=0 To i.length-1
					Local indices$[]=i[j].Split("/"),vi,vti,vni
					vi=Int(indices[0])
					If indices.length>1 vti=Int(indices[1])
					If indices.length>2 vni=Int(indices[2])
					verts[j,0]=vi
					verts[j,1]=vti
					verts[j,2]=vni
				Next
				Local vcnt,tcnt,tris=i.length-2
				surface.GetSize vcnt,tcnt
				surface.Resize vcnt+tris*3,tcnt+tris
				
				Local i0=0,i1=1,i2=2
				For Local t=0 To tris-1
					Local v0=vcnt+(t*3)+0,v1=vcnt+(t*3)+1,v2=vcnt+(t*3)+2
					Local vi0=verts[i0,0],vt0=verts[i0,1],vn0=verts[i0,2]
					Local vi1=verts[i1,0],vt1=verts[i1,1],vn1=verts[i1,2]
					Local vi2=verts[i2,0],vt2=verts[i2,1],vn2=verts[i2,2]
					
					If vi0<0 vi0=v.length-vi0 Else vi0:-1
					If vi1<0 vi1=v.length-vi1 Else vi1:-1					
					If vi2<0 vi2=v.length-vi2 Else vi2:-1
					
					surface.SetCoord v0,v[vi0*3+0],v[vi0*3+1],v[vi0*3+2]					
					surface.SetCoord v1,v[vi1*3+0],v[vi1*3+1],v[vi1*3+2]
					surface.SetCoord v2,v[vi2*3+0],v[vi2*3+1],v[vi2*3+2]
					
					If vn0
						If vn0<0 vn0=vn.length-vn0 Else vn0:-1
						surface.SetNormal v0,vn[vn0*3+0],vn[vn0*3+1],vn[vn0*3+2]
					EndIf
					
					If vn1
						If vn1<0 vn1=vn.length-vn1 Else vn1:-1
						surface.SetNormal v1,vn[vn1*3+0],vn[vn1*3+1],vn[vn1*3+2]
					EndIf

					If vn2
						If vn2<0 vn2=vn.length-vn2 Else vn2:-1
						surface.SetNormal v2,vn[vn2*3+0],vn[vn2*3+1],vn[vn2*3+2]					
					EndIf
					
					surface.SetTriangle tcnt+t,v0,v1,v2
					i2:+1;i1=i2-1
				Next
			Case "#"
			Default
				ModuleLog "Unrecognized line: ~q"+line+"~q"
			End Select
		Wend
		
		mesh.AppendSurface surface
		
		mesh.UpdateNormals
		Return True
	End Method
	
	Method Split$[](str$)
		Local res$[],instring=False
		For Local i=0 To str.length-1
			If str[i]=" "[0] Or str[i]="~t"[0] instring=False;Continue
			If Not instring res=res[..res.length+1]
			res[res.length-1]:+Chr(str[i])
			instring=True
		Next
		Return res
	End Method
	
	Method Name$()
		Return "Wavefront OBJ"
	End Method
	Method ModuleName$()
		Return "objloader"
	End Method
End Type
New TMeshLoaderOBJ

