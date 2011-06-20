
Strict

Import "entity.bmx"
Import "animation.bmx"

Type TAnimEntity Extends TEntity
	Field _animator:TAnimator
	Method SetAnimKey(frame,key:Object) Abstract
End Type
