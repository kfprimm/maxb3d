
Strict

'Derived from Warner's engine.
'http://code.google.com/p/warner-engine/

Import "entity.bmx"
Import "roamstep4d.c"

Import BRL.Random

Type TTerrain Extends TEntity
	Field _heights#[], _size, _lmax, _max_tris, _clmax#
	Field _handle:Byte Ptr, _data:Float Ptr,_count
	Field _update
	
	Method New()
			SetDetail 14,12000 
	End Method
	
	Method Free()
		Super.Free
		
		_heights = Null
		
		If _handle
			roam_free _handle
			_handle = Null
		EndIf
	End Method
	
	Method Lists[]()
		Return Super.Lists()+[WORLDLIST_TERRAIN, WORLDLIST_RENDER]
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		Local terrain:TTerrain = TTerrain(entity)
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TTerrain(parent:TEntity=Null)
		Return TTerrain(Super.Copy_(parent))
	End Method
	
	Method SetMap(url:Object)
		Local pixmap:TPixmap=TPixmap(url)
		If pixmap=Null pixmap=LoadPixmap(url)		
		If pixmap
			_size=Max(PixmapWidth(pixmap),PixmapHeight(pixmap))
			Local s=1
			While s<_size;s:*2;Wend
			_size=s
			_heights=New Float[_size*_size]
			pixmap=ResizePixmap(pixmap,_size,_size)
			For Local i = 0 To _size-1
				For Local j = 0 To _size-1
					SetHeight ((ReadPixel(pixmap, i, j) & $FF)/255.0)*3,j,i
				Next
			Next
		ElseIf Int[](url)
			_size = Int[](url)[0]
			_heights=New Float[_size*_size]
		Else
			_heights=New Float[_size*_size]
		EndIf
		_update=True
	End Method
	
	Method GetHeight#(x,z)
		Return _heights[(z*_size)+x]
	End Method
	Method SetHeight(height#,x,z)
		_heights[(z*_size)+x]=height			
	End Method	
	
	Method GetSize()
		Return _size
	End Method
	
	Method SetDetail(lmax, max_tris, clmax=-1)
		If clmax = -1 clmax = lmax
		_lmax = Min(lmax,44)
		_max_tris = max_tris
		_clmax = Min(clmax,44)
		
		If _handle
			roam_set_lmax _handle, lmax
			roam_set_tricntmax _handle, _max_tris
					
			For Local l = 0 To 44
				roam_set_displacement _handle,l,0.3/Sqr(1 Shl l)
			Next
		EndIf
	End Method
	
	Method Update(x#,y#,z#,frustrum:Float Ptr)
		DebugLog "lde"
		If _handle = Null
			_handle=roam_create(_heights, _size)
			SetDetail _lmax,_max_tris,_clmax	
		EndIf
		
		If _update
			roam_set_heightdata _handle, _heights, _size
			roam_update_heightdata _handle
			_update = False
		EndIf
		
		_matrix.TransformVec3 x,y,z
		roam_set_frustum _handle,x,y,z,frustrum
		roam_optimize _handle	
		_data=roam_getdata(_handle, _count)
	End Method
End Type

Extern "C"
	Function roam_create:Byte Ptr(heightdata:Float Ptr, size:Int)
	Function roam_set_frustum( terrain:Byte Ptr, cx#,cy#,cz#, frustum:Float Ptr )
	Function roam_set_lmax( terrain:Byte Ptr, lmax% )
	Function roam_draw( terrain:Byte Ptr )
	Function roam_set_tricntmax( terrain:Byte Ptr, lmax% )
	Function roam_set_iqfine( terrain:Byte Ptr, lmax% )
	
	Function roam_optimize( terrain:Byte Ptr )	
	Function roam_set_heightdata( terrain:Byte Ptr, heightdata:Float Ptr, size% )
	Function roam_update_heightdata( terrain:Byte Ptr )
	
	Function roam_getdata:Float Ptr( terrain:Byte Ptr, count% Var )	
	Function roam_set_displacement( terrain:Byte Ptr, index%, displacement#)
	
	Function getHeight#( terrain:Byte Ptr, x#,y# )
	Function roam_free( terrain:Byte Ptr )
End Extern
