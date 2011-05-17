
Strict

Import "entity.bmx"

Const VIEWMODE_FIXED = 1
Const VIEWMODE_FREE = 2
Const VIEWMODE_UPRIGHT1 = 3
Const VIEWMODE_UPRIGHT2 = 4

Type TSprite Extends TRenderEntity
	Field _angle#
	Field _handlex#,_handley#
	Field _viewmode
	
	Field _view_matrix:TMatrix=New TMatrix
	
	Method Copy:TSprite(parent:TEntity=Null)
		Local sprite:TSprite=New TSprite
		sprite.AddToWorld parent, [WORLDLIST_SPRITE, WORLDLIST_RENDER]
		Return sprite
	End Method
	
	Method GetMatrix:TMatrix(alternate=False,copy=True)
		If alternate
			If copy Return _view_matrix.Copy()
			Return _view_matrix
		EndIf
		Return Super.GetMatrix(alternate,copy)
	End Method
	
	Method GetAngle#()
		Return _angle
	End Method
	Method SetAngle(angle#)
		_angle=angle
	End Method
	
	Method GetHandle(x# Var,y# Var)
		x=_handlex;y=_handley
	End Method
	Method SetHandle(x#,y#)
		_handlex=x;_handley=y
	End Method
	
	Method GetViewMode()
		Return _viewmode
	End Method
	Method SetViewMode(mode)
		_viewmode=mode
	End Method
End Type