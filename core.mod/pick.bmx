
Strict

Import "surface.bmx"
Import "entity.bmx"

Type TPick
	Field x#,y#,z
	Field nx#,ny#,nz#
	Field time#
	Field entity:TEntity, surface:TSurface
	Field triangle
End Type
