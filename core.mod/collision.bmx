
Strict

Import "worldconfig.bmx"

Const COLLISION_METHOD_SPHERE	= 1
Const COLLISION_METHOD_POLYGON	= 2
Const COLLISION_METHOD_BOX		= 3

Const COLLISION_RESPONSE_NONE		= 0
Const COLLISION_RESPONSE_STOP		= 1
Const COLLISION_RESPONSE_SLIDE		= 2
Const COLLISION_RESPONSE_SLIDEXZ	= 3

Type TCollisionPair
	Field src,dest
	Field methd,response
End Type

Type TCollision
	Field x#,y#,z#
	Field nx#,ny#,nz#
	Field time#
	Field entity:Object,surface,triangle
End Type

Type TCollisionDriver
	Global _default:TCollisionDriver
	
	Method New()
		_default=Self
	End Method
	
	Method Init();End Method	
	Method Update(config:TWorldConfig,speed#) Abstract
End Type

Type TNullCollisionDriver Extends TCollisionDriver
	Method Update(config:TWorldConfig,speed#) ; End Method
End Type
New TNullCollisionDriver


