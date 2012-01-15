
Strict

Import MaxB3D.Logging
Import BRL.Pixmap
Import "worldconfig.bmx"
Import "resource.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/texture",message
End Function

Public

Const TEXTURE_COLOR		= 1
Const TEXTURE_ALPHA		= 2
Const TEXTURE_MASKED	= 4
Const TEXTURE_MIPMAP	= 8
Const TEXTURE_CLAMPU	= 16
Const TEXTURE_CLAMPV	= 32
Const TEXTURE_SPHEREMAP	= 64
Const TEXTURE_CUBEMAP	= 128
Const TEXTURE_VRAM		= 256
Const TEXTURE_HIGHCOLOR	= 512
Const TEXTURE_DEPTH 	= 1024

Const TEXTURE_DEFAULT	= TEXTURE_COLOR
Const TEXTURE_CLAMPUV	= TEXTURE_CLAMPU|TEXTURE_CLAMPV

Const BLEND_NONE      = 0
Const BLEND_ALPHA	     = 1
Const BLEND_MULTIPLY  = 2
Const BLEND_ADD       = 3
Const BLEND_DOT3      = 4
Const BLEND_MULTIPLY2 = 5

Const CUBETEX_LEFT  = 0
Const CUBETEX_FRONT = 1
Const CUBETEX_RIGHT = 2
Const CUBETEX_BACK  = 3
Const CUBETEX_UP    = 4
Const CUBETEX_DOWN  = 5

Type TTexture
	Field _blend=BLEND_MULTIPLY,_coords,_flags
	Field _px#,_py#,_r#,_sx#=1.0,_sy#=1.0
	Field _width=-1,_height=-1,_frame:TTextureFrame[]
	Field _name$
	
	Method Init:TTexture(config:TWorldConfig,url:Object,flags)
		Local pixmap:TPixmap[]
		
		If Int[](url)
			Local arr[]=Int[](url),width,height,frames=1
			If arr.length=0 Return Null
			If arr.length=1 width=arr[0];height=arr[0]
			If arr.length>1 width=arr[0];height=arr[1]
			If arr.length>2 frames=arr[2]	
			pixmap=New TPixmap[frames]
			For Local i=0 To frames-1
				pixmap[i]=CreatePixmap(width,height,PF_BGRA8888)
			Next
		ElseIf TPixmap(url) 
			pixmap=[TPixmap(url)]
			If pixmap[0]=Null 
				If url ModuleLog "Invalid texture url passed. ("+url.ToString()+")" Else ModuleLog "Invalid texture url passed."
				Return Null
			EndIf
		Else
			pixmap=[LoadPixmap(config.GetStream(url))]
			If pixmap[0]=Null 
				If url ModuleLog "Invalid texture url passed. ("+url.ToString()+")" Else ModuleLog "Invalid texture url passed."
				Return Null
			EndIf
		EndIf
		
		If pixmap.length=0
			If url ModuleLog "Invalid texture url passed. ("+url.ToString()+")" Else ModuleLog "Invalid texture url passed."
			Return Null
		EndIf
		
		If String(url) flags = config.ProcessTextureFilters(String(url),flags)
		
		SetName url.ToString()
		SetSize -1,-1,pixmap.length
		For Local i=0 To pixmap.length-1
			If flags&TEXTURE_MASKED pixmap[i] = MaskPixmap(pixmap[i],0,0,0)
			SetPixmap pixmap[i],i
		Next			
		SetFlags flags
		config.AddObject Self,WORLDLIST_TEXTURE
		
		Return Self
	End Method
	
		
	Method Lock:TPixmap(index=0)
		_frame[index]._locked=True
		Return _frame[index]._pixmap
	End Method
	
	Method Unlock(index=0)
		_frame[index]._locked=False
		_frame[index]._updateres=True
	End Method
	
	Method SetPixmap(pixmap:TPixmap,index=0)
		If pixmap=Null _frame[index]=Null;Return
		If _frame[index]=Null _frame[index]=New TTextureFrame
		_frame[index]._pixmap=ConvertPixmap(pixmap,PF_BGRA8888)
		_frame[index]._updateres=True
		
		If (_width<>-1 Or _height<>-1) And (_width<>PixmapWidth(pixmap) Or _height<>PixmapHeight(pixmap))
			Throw "Pixmap size does not match texture size."
		Else
			_width=PixmapWidth(pixmap)
			_height=PixmapHeight(pixmap)
		EndIf
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
	Method SetSize(width,height,frames)
		_width=width
		_height=height
		_frame=_frame[..frames]
	End Method

	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
End Type

Type TTextureFrame 
	Field _res:TTextureRes,_updateres	
	Field _pixmap:TPixmap,_locked
	Field _buffer:Object
End Type

Type TTextureRes Extends TDriverResource

End Type

