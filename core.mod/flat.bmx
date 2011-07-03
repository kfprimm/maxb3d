
Strict

Import "entity.bmx"

Type TFlat Extends TEntity 
	Method Copy:TFlat(parent:TEntity=Null)
	End Method
	
	Method GetCullRadius#()
		If _cullradius<0 Return Abs(_cullradius)
		Local sx#,sy#,sz#
		GetScale sx,sy,sz,True
		Local radius#=Max(sx,Max(sy,sz))/2.0
		Local radius_sqr#=radius*radius
		Return Sqr(radius_sqr+radius_sqr+radius_sqr) 
	End Method
End Type
