
Strict

Import "entity.bmx"

Const LIGHT_DIRECTIONAL = 1
Const LIGHT_POINT       = 2
Const LIGHT_SPOT        = 3

Type TLight Extends TEntity
	Field _range#,_inner#,_outer#
	Field _mode
	
	Method New()
		SetRange 1000
		SetAngles 0,90
		SetMode LIGHT_DIRECTIONAL
	End Method
	
	Method Lists[]()
		Return Super.Lists() + [WORLDLIST_LIGHT]
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		Local light:TLight = TLight(entity)

		Local inner#, outer#
		light.GetAngles inner, outer
		
		SetAngles inner,outer
		SetRange light.GetRange()
		SetMode light.GetMode()
		
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TLight(parent:TEntity=Null)
		Return TLight(Super.Copy_(parent))
	End Method
	
	Method GetMode()
		Return _mode
	End Method
	Method SetMode(mode)
		_mode=mode
	End Method
		
	Method GetRange#()
		Return _range
	End Method
	Method SetRange(range#)
		_range=range
	End Method
	
	Method GetAngles(inner# Var,outer# Var)
		inner=_inner;outer=_outer
	End Method
	Method SetAngles(inner#,outer#)
		_inner=inner;_outer=outer
	End Method
End Type
