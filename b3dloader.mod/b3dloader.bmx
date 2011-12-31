
Strict

Rem
	bbdoc: Blitz3D model loader for MaxB3D
End Rem
Module MaxB3D.B3DLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import MaxB3D.BoneAnimator
Import Prime.libB3D

Type TMeshLoaderB3D Extends TMeshLoader
	Field _mesh:TMesh
	
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local model:TBB3DChunk=TBB3DChunk.Load(url)
		If model=Null Return False	
		
		Local olddir$=CurrentDir()
		If String(url) ChangeDir(ExtractDir(String(url)))
		
		Local texture:TTexture[model.texs.length]
		Local brush:TBrush[model.brus.length]
		
		For Local i=0 To texture.length-1
			Local chunk:TTEXSChunk=model.texs[i]			
			texture[i]=_currentworld.AddTexture(chunk.file,chunk.flags)
			If texture[i]
				texture[i].SetBlend chunk.blend
				texture[i].SetPosition chunk.x_pos,chunk.y_pos
				texture[i].SetScale chunk.x_scale,chunk.y_scale
				texture[i].SetRotation chunk.rotation*(180.0/Pi)
				If chunk.flags&65536 texture[i].SetCoords 1
			EndIf
		Next
		
		For Local i=0 To brush.length-1
			Local chunk:TBRUSChunk=model.brus[i]
			brush[i]=_currentworld.AddBrush()
			brush[i].SetName chunk.name
			brush[i].SetColor chunk.red*255,chunk.green*255,chunk.blue*255;brush[i].SetAlpha chunk.alpha
			brush[i].SetShine chunk.shininess
			brush[i].SetBlend chunk.blend;brush[i].SetFX chunk.fx
			For Local j=0 To chunk.n_texs-1
				If chunk.texture_id[j]>-1 brush[i].SetTexture texture[chunk.texture_id[j]],j
			Next
		Next		
		ChangeDir olddir
		
		' model.dump StandardIOStream
		 
		If model.node
			ParseNode model.node,mesh,brush,mesh
			Return True
		EndIf
		Return False
	End Method
	
	Method ParseNode(node:TNODEChunk,parent:TEntity,brush:TBrush[],entity:TEntity=Null)
		Local meshchunk:TMESHChunk=TMESHChunk(node.kind),bonechunk:TBONEChunk=TBONEChunk(node.kind)
				
		Select node.kind
		Case Null
			entity=_currentworld.AddPivot(parent)
		Case meshchunk			
			If entity=Null entity=_currentworld.AddMesh("//empty",parent)
			Local mesh:TMesh=TMesh(entity)
			mesh._animator=New TBoneAnimator
			_mesh=mesh
			
			If meshchunk.brush_id>-1 entity.SetBrush brush[meshchunk.brush_id]
			
			Local vrts:TVRTSChunk=meshchunk.vrts
			Local vertsurface:TSurface=New TSurface
			vertsurface.Resize(vrts.xyz.length/3,0)
			
			For Local i=0 To vertsurface.CountVertices()-1
				vertsurface.SetCoords i,vrts.xyz[i*3+0],vrts.xyz[i*3+1],vrts.xyz[i*3+2]
				If vrts.nxyz vertsurface.SetNormal i,vrts.nxyz[i*3+0],vrts.nxyz[i*3+1],vrts.nxyz[i*3+2]
				If vrts.rgba vertsurface.SetColor i,vrts.rgba[i*4+0]*255,vrts.rgba[i*4+1]*255,vrts.rgba[i*4+2]*255,vrts.rgba[i*4+3]
				If vrts.SetSize()>1 
					For Local j=0 To vrts.SetCount()-1
						vertsurface.SetTexCoords i,1-vrts.tex_coords[i][j,0],vrts.tex_coords[i][j,1],j
					Next
				EndIf
			Next
			
			For Local i=0 To meshchunk.tris.length-1
				Local tri:TTRISChunk=meshchunk.tris[i]
				Local surface:TSurface=vertsurface.Copy()
				surface.Resize(-1,tri.vertex_id.length/3)
				If tri.brush_id>-1 surface.SetBrush brush[tri.brush_id]
				For Local t=0 To surface.CountTriangles()-1
					surface.SetTriangle t,tri.vertex_id[t*3+0],tri.vertex_id[t*3+1],tri.vertex_id[t*3+2]
				Next
				If vrts.nxyz=Null surface.UpdateNormals			
				mesh.AppendSurface surface
			Next
		Case bonechunk
			entity=_currentworld.AddBone(parent)
			Local bone:TBone=TBone(entity)
			
			For Local surface:TSurface=EachIn _mesh._surfaces
				bone.AddSurface surface
				For Local i=0 To bonechunk.vertex_id.length-1
					bone.AddVertex surface,bonechunk.vertex_id[i],bonechunk.weight[i]
				Next
			Next			
			
			Local ident_matrix:TMatrix=TMatrix.Identity()
			For Local chunk:TKEYSChunk=EachIn node.keys
				Local keys:TAnimKey[chunk.frame.length]
				Local pos#[]=chunk.position,rot#[]=chunk.rotation,scl#[]=chunk.scale
				For Local i=0 To chunk.frame.length-1
					Local bonekey:TBoneKey=New TBoneKey
					
					If pos.length>0 bonekey._px=pos[i*3+0];bonekey._py=pos[i*3+1];bonekey._pz=pos[i*3+2]
					If rot.length>0 bonekey._rw=rot[i*4+0];bonekey._rx=rot[i*4+1];bonekey._ry=rot[i*4+2];bonekey._rz=rot[i*4+3]
					If scl.length>0 bonekey._sx=scl[i*3+0];bonekey._sy=scl[i*3+1];bonekey._sz=scl[i*3+2]
														
					Local key:TAnimKey=New TAnimKey
					key._frame=chunk.frame[i]
					key._object=bonekey
					keys[i]=key
				Next
				TBoneAnimator(_mesh._animator).AddBone bone,keys
			Next
		Default
			entity=_currentworld.AddPivot(parent)
		End Select		
		
		entity.SetName node.name
		entity.SetPosition node.position[0],node.position[1],node.position[2]
		Local pitch#,yaw#,roll#
		TQuaternion.Euler node.rotation[0],node.rotation[1],node.rotation[2],node.rotation[3],pitch,yaw,roll
		entity.SetRotation pitch,yaw,roll
		entity.SetScale node.scale[0],node.scale[1],node.scale[2]
		
		For Local child:TNODEChunk=EachIn node.node
			ParseNode child,entity,brush
		Next
		If TMesh(entity) If TBoneAnimator(TMesh(entity)._animator)._root=Null TMesh(entity)._animator=Null
		If TBone(entity) TBone(entity)._start_matrix=entity.GetMatrix()
	End Method
	
	Method Info$()
		Return "Blitz3D|b3d"
	End Method
	Method ModuleName$()
		Return "b3dloader"
	End Method
End Type
New TMeshLoaderB3D
