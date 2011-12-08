
Strict

Rem
	bbdoc: Milkshape 3D mesh loader for MaxB3D.
End Rem
Module MaxB3D.MS3DLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import Prime.libMS3D

Type TMeshLoaderMS3D Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local model:TMS3DFile=New TMS3DFile.Read(stream)
		If model=Null Return Null
		
		Local materials:TMS3DMaterial[]=model.Materials
		Local brushes:TBrush[materials.length]
		For Local i=0 To materials.length-1
			Local texture:TTexture=_currentworld.AddTexture(materials[i].texture)
			
			brushes[i]=_currentworld.AddBrush()
			brushes[i].SetTexture texture,0
		Next
		
		For Local group:TMS3DGroup=EachIn model.Groups
			Local surface:TSurface=New TSurface
			surface.Resize group.numtriangles*3,group.numtriangles
			
			For Local i=0 To group.numtriangles-1
				Local triangle:TMS3DTriangle=model.Triangles[group.triangleIndices[i]]
				Local v0:TMS3DVertex=model.Vertices[triangle.vertexIndices[0]]
				Local v1:TMS3DVertex=model.Vertices[triangle.vertexIndices[1]]
				Local v2:TMS3DVertex=model.Vertices[triangle.vertexIndices[2]]
				
				surface.SetCoords    i*3+0,v0.vertex[0],v0.vertex[1],v0.vertex[2]
				surface.SetNormal    i*3+0,triangle.vertexNormals[0,0],triangle.vertexNormals[0,1],triangle.vertexNormals[0,2]
				surface.SetTexCoords i*3+0,1.0-triangle.s[0],triangle.t[0]
				
				surface.SetCoords    i*3+1,v1.vertex[0],v1.vertex[1],v1.vertex[2]
				surface.SetNormal    i*3+1,triangle.vertexNormals[1,0],triangle.vertexNormals[1,1],triangle.vertexNormals[1,2]
				surface.SetTexCoords i*3+1,1.0-triangle.s[1],triangle.t[1]
				
				surface.SetCoords    i*3+2,v2.vertex[0],v2.vertex[1],v2.vertex[2]
				surface.SetNormal    i*3+2,triangle.vertexNormals[2,0],triangle.vertexNormals[2,1],triangle.vertexNormals[2,2]
				surface.SetTexCoords i*3+2,1.0-triangle.s[2],triangle.t[2]
				
				surface.SetTriangle i,i*3+0,i*3+1,i*3+2
			Next
			
			If group.materialIndex<>255 surface.SetBrush brushes[group.materialIndex]
			
			mesh.AppendSurface surface		
		Next
		
		For Local joint:TMS3DJoint=EachIn model.Joints
			Local parent:TEntity=mesh.FindChild(joint.parentName,True)
			If parent=Null parent=mesh
			
			Local bone:TBone=_currentworld.AddBone(parent)
			bone.SetName joint.name
			bone.SetPosition joint.position[0],joint.position[1],joint.position[2]
			bone.SetRotation joint.rotation[0],joint.rotation[1],joint.rotation[2]
		Next
		
		Return True
	End Method
	
	Method Info$()
		Return "Milkshape 3D|.ms3d"
	End Method	
	Method ModuleName$()
		Return "ms3dloader"
	End Method
End Type
New TMeshLoaderMS3D
