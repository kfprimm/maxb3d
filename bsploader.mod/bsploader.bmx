
Strict

Rem
	bbdoc: Loads a TBSPTree into a mesh.
End Rem
Module MaxB3D.BSPLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import sys87.BSP

Type TMeshLoaderBSP Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local tree:TBSPTree=TBSPTree(url)
		If tree=Null Return False
		
		Local surface:TSurface=mesh.AddSurface()
		AddTreeToSurface tree,surface
		surface.UpdateNormals
		
		Return True
	End Method
	
	Function AddTreeToSurface(tree:TBSPTree,surface:TSurface)
		Local node:TBSPNode=tree.Node
		If Not node Return 
		For Local poly:TBSPPolygon=EachIn node.On
			Local ptA:TVector=poly.Point[0],v0
			v0=surface.AddVertex(ptA.x,ptA.y,ptA.z)
			For Local i=1 To poly.Count()-2
				Local ptB:TVector=poly.Point[i],ptC:TVector=poly.Point[i+1]
				Local v1=surface.AddVertex(ptB.x,ptB.y,ptB.z)
				Local v2=surface.AddVertex(ptC.x,ptC.y,ptC.z)			
				surface.AddTriangle v0,v1,v2
			Next
		Next
		AddTreeToSurface node.In,surface
		AddTreeToSurface node.Out,surface
	End Function
	
	Method ModuleName$()
		Return "bsploader"
	End Method
	
	Method Name$()
		Return "BSP Tree"
	End Method
End Type
New TMeshLoaderBSP