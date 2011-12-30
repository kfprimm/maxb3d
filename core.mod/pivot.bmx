
Strict

Import "entity.bmx"

Type TPivot Extends TEntity
	Method Lists[]()
		Return Super.Lists()+[WORLDLIST_PIVOT]
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		Local terrain:TPivot = TPivot(entity)
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TPivot(parent:TEntity=Null)
		Return TPivot(Super.Copy_(parent))
	End Method
End Type
