
Strict

Import "surface.bmx"
Import "entity.bmx"

Type TPick
	Field x#,y#,z
	Field nx#,ny#,nz#
	Field time#
	Field entity:TEntity, surface:TSurface
	Field triangle
	
	Method FromRaw:TPick(raw:TRawPick)
		x = raw.x;y = raw.y;z = raw.z
		nx = raw.nx;ny = raw.ny;nz = raw.nz
		time = raw.time
		entity = raw.entity
		triangle = raw.triangle
		Return Self
	End Method		
End Type
