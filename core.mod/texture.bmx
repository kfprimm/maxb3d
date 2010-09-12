
Strict

Import BRL.Pixmap

Const TEXTURE_COLOR		= 1
Const TEXTURE_ALPHA		= 2
Const TEXTURE_MASKED	= 4
Const TEXTURE_MIPMAP	= 8
Const TEXTURE_CLAMPU	= 16
Const TEXTURE_CLAMPV	= 32
Const TEXTURE_SPHMAP	= 64
Const TEXTURE_CUBEMAP	= 128
Const TEXTURE_VRAM		= 256
Const TEXTURE_HIGHCLR	= 512

Const TEXTURE_DEFAULT	= TEXTURE_COLOR|TEXTURE_MIPMAP
Const TEXTURE_CLAMPUV	= TEXTURE_CLAMPU|TEXTURE_CLAMPV

Const BLEND_NONE		= 0
Const BLEND_ALPHA		= 1
Const BLEND_MULTIPLY	= 2
Const BLEND_ADD			= 3

Type TTexture
	Field _blend,_coords,_flags
	Field _px#,_py#,_r#,_sx#=1.0,_sy#=1.0
	Field _width,_height
	Field _name$
	
	Field _res:TTextureRes,_updateres	
	Field _pixmap:TPixmap,_locked
	
	Method Lock:TPixmap()
		_locked=True
		Return _pixmap
	End Method
	
	Method Unlock()
		_locked=False
		_updateres=True
	End Method
	
	Method SetPixmap:TPixmap(pixmap:TPixmap)
		_pixmap=ConvertPixmap(pixmap,PF_RGBA8888)
		_width=PixmapWidth(_pixmap)
		_height=PixmapHeight(_pixmap)
		_updateres=True
	End Method
	
	Method GetFlags()
		Return _flags
	End Method
	Method SetFlags(flags)
		_flags=flags
	End Method	
	
	Method GetBlend()
		Return _blend
	End Method
	Method SetBlend(blend)
		_blend=blend
	End Method
	
	Method GetCoords()
		Return _coords
	End Method
	Method SetCoords(set)
		_coords=set
	End Method
	
	Method GetScale(x# Var,y# Var)
		x=1.0/_sx;y=1.0/_sy
	End Method
	Method SetScale(x#,y#)
		_sx=1.0/x;_sy=1.0/y
	End Method
	
	Method GetPosition(x# Var,y# Var)
		x=_px;y=_py
	End Method
	Method SetPosition(x#,y#)
		_px=x;_py=y
	End Method
	
	Method GetRotation#()
		Return _r
	End Method
	Method SetRotation(angle#)
		_r=angle
	End Method
	
	Method GetSize(width Var,height Var)
		width=_width;height=_height
	End Method
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
End Type

Type TTextureRes

End Type

