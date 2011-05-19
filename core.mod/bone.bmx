
Strict

Import "entity.bmx"
Import "surface.bmx"

Type TBone Extends TEntity
	Field _surface:TSurface[]
	Field _info:TWeightInfo[]
		
	Method Copy:TBone(parent:TEntity=Null)
		Local bone:TBone=New TBone
		bone.AddToWorld parent,[WORLDLIST_BONE]
		Return bone
	End Method
End Type

Type TWeightInfo
	Field vertex_id
	Field weight#
End Type