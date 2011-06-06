
Strict

Import "entity.bmx"

Const BODY_NONE   = 0
Const BODY_BOX 	  = 1
Const BODY_SPHERE = 2

Type TBody Extends TEntity
	Field _mass#,_shape
	Field _data:Object,_update
	
	Method New()
		_shape = BODY_SPHERE
	End Method
	
	Method Copy:TBody(parent:TEntity=Null)
		Local body:TBody=New TBody
		Return body
	End Method
	
	Method SetScale(x#,y#,z#,glob=False)
		Super.SetScale(x,y,z,glob)
		_update=True
	End Method
	
	Method SetRotation(x#,y#,z#,glob=False)
		Super.SetRotation(x,y,z,glob)
		_update=True
	End Method
	
	Method SetPosition(x#,y#,z#,glob=False)
		Super.SetPosition(x,y,z,glob)
		_update=True
	End Method
	
	Method SetBox(x#,y#,z#,width#,height#,depth#)
		Super.SetBox(x,y,z,width,height,depth)
		_shape = BODY_BOX
		_update=True
	End Method

	Method GetMass#()
		Return _mass
	End Method
	Method SetMass(mass#)
		_mass=mass
		_update=True
	End Method
End Type
