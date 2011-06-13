
Strict

Import "entity.bmx"
Import "animation.bmx"

Type TBone Extends TAnimEntity
	Field _start_matrix:TMatrix
	Field _surface:TSurface[]
	Field _info:TWeightInfo[]
	Field _key:TAnimKey[]
		
	Method Copy:TBone(parent:TEntity=Null)
		Local bone:TBone=New TBone
		bone.AddToWorld parent,[WORLDLIST_BONE]
		Return bone
	End Method
	
	Method AddSurface(surface:TSurface)
		_surface=_surface[.._surface.length+1]
		_surface[_surface.length-1]=surface
		
		_info=_info[.._info.length+1]
		_info[_info.length-1]=New TWeightInfo
	End Method
	
	Method GetSurfaceIndex(surface:TSurface)
		For Local i=0 To _surface.length-1
			If _surface[i]=surface Return i
		Next
		Return -1
	End Method
	
	Method AddVertex(surface:TSurface,vertex,weight#=1.0)
		_info[GetSurfaceIndex(surface)].Add([vertex],[weight])
	End Method
	
	Method AddVertices(surface:TSurface,vertices[],weights#[]=Null)
		_info[GetSurfaceIndex(surface)].Add(vertices,weights)
	End Method
	
	Method SetAnimKey(frame,key:Object)
		For Local k:TAnimKey=EachIn _key
			If k._frame=frame k._object=key;Return
		Next
	End Method
	
	Method Set(matrix:TMatrix=Null)
		If matrix=Null matrix=_start_matrix
		SetMatrix matrix
	End Method
End Type

Type TWeightInfo
	Field _vertex[]
	Field _weight#[]
		
	Method Add(vertex[],weight#[])
		_vertex=_vertex+vertex
		If weight<>Null
			_weight=_weight+weight
		Else
			Local size=_weight.length
			_weight=_weight[.._vertex.length]
			For Local i=size To _weight.length-1
				_weight[i]=1.0
			Next
		EndIf
	End Method
End Type