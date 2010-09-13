
Strict

Import "entity.bmx"

Const LIGHT_DIRECTIONAL		= 1
Const LIGHT_POINT			= 2
Const LIGHT_SPOT			= 3

Type TLight Extends TEntity
	Field _range#,_inner#,_outer#
	Field _mode
	
	Method Copy:TLight(parent:TEntity=Null)
		Local light:TLight=New TLight
		Return light
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
