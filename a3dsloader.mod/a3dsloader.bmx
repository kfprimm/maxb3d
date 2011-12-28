
Strict

Rem
	bbdoc: Autodesk 3DS loader for MaxB3D
End Rem
Module MaxB3D.A3DSLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import Prime.lib3ds

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "a3dsloader",message
End Function

Public

Type TMeshLoader3DS Extends TMeshLoader	
	Method Run(mesh:TMesh,stream:TStream,url:Object)	
		If stream=Null Return False
		Local file:T3DSFile=T3DSFile.Read(stream)
		If file=Null Return False
		
		file.DumpInfo
		
		Local brushes:TBrush[file.Materials.length]
		For Local i=0 To brushes.length-1
			brushes[i]=_currentworld.AddBrush()
			brushes[i].SetColor file.Materials[i].DiffuseColor.r*255,file.Materials[i].DiffuseColor.g*255,file.Materials[i].DiffuseColor.b*255
			brushes[i].SetTexture _currentworld.AddTexture(file.Materials[i].TextureFile)
		Next
		
		Local surfaces:TSurface[file.Materials.length+1]
		Local nullsurface:TSurface
		
		For Local m:T3DSMesh=EachIn file.Meshes
			For Local i=0 To m.Faces.length-1
				Local surface:TSurface
				If m.Faces[i].Material<>Null
					For Local s=0 To surfaces.length-2
						If file.Materials[s]=m.Faces[i].Material
							If surfaces[s]=Null
								surfaces[s]=New TSurface
								surfaces[s].SetBrush brushes[s]
							EndIf
							surface=surfaces[s]
						EndIf
					Next
				Else
					If surfaces[file.Materials.length-1]=Null surfaces[file.Materials.length-1]=New TSurface
					surface=surfaces[file.Materials.length-1]
				EndIf
				
				Local p0:T3DSVertex=m.Vertices[m.Faces[i].a],p1:T3DSVertex=m.Vertices[m.Faces[i].b],p2:T3DSVertex=m.Vertices[m.Faces[i].c]
				Local t0:T3DSTex=m.Texs[m.Faces[i].a],t1:T3DSTex=m.Texs[m.Faces[i].b],t2:T3DSTex=m.Texs[m.Faces[i].c]
				Local v0=surface.AddVertex(p0.x,p0.y,p0.z,1-t0.u,1-t0.v)
				Local v1=surface.AddVertex(p1.x,p1.y,p1.z,1-t1.u,1-t1.v)
				Local v2=surface.AddVertex(p2.x,p2.y,p2.z,1-t2.u,1-t2.v)
				surface.AddTriangle v0,v1,v2				
			Next			
		Next
		
		surfaces:+[nullsurface]		
		For Local i=0 To surfaces.length-1
			If surfaces[i]=Null Continue
			If Not surfaces[i].IsEmpty()
				surfaces[i].UpdateNormals
				mesh.AppendSurface surfaces[i]
			EndIf
		Next
		
		mesh.Rotate 90,180,0
		
		Return True
	End Method
	
	Method ReadChunk(stream:TStream,length Var)
		Local id=ReadShort(stream)
		Return ReadInt(stream)
	End Method
		
	Method Info$()
		Return "Autodesk 3DS|3ds"
	End Method
	Method ModuleName$()
		Return "a3dsloader"
	End Method
End Type
New TMeshLoader3DS

