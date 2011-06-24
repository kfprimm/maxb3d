
Strict

Import BRL.Max2D
Import sys87.BufferedMax2D
Import "light.bmx"
Import "camera.bmx"
Import "mesh.bmx"
Import "plane.bmx"
Import "sprite.bmx"
Import "terrain.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/driver",message
End Function

Public

Global _creategraphicshook=AllocHookId()

Type TCaps
	Field PointSprites
	Field MaxPointSize#
	
	Method CopyBase(caps:TCaps)
		PointSprites=caps.PointSprites
		MaxPointSize=caps.MaxPointSize
	End Method
End Type

Type TMaxB3DDriver Extends TBufferedMax2DDriver
	Global _parent:TBufferedMax2DDriver
	
	Field _texture:TTexture[8],_caps:TCaps
	Field _prevwidth,_prevheight
	Field _shaderdriver:TShaderDriver
	Field _in_max2d=True
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		RunHooks _creategraphicshook,Null
		Return Super.CreateGraphics(width,height,depth,hertz,flags)
	End Method
	
	Method SetGraphics(g:TGraphics)
		_parent.SetGraphics(g)
		_current=g
		WorldConfig.Width=GraphicsWidth()
		WorldConfig.Height=GraphicsHeight()	
		ScaleViewports	
		_prevwidth=GraphicsWidth();_prevheight=GraphicsHeight()
		_caps=GetCaps()
	End Method
	
	Method MakeBuffer:TBuffer(src:Object,width,height,flags) Abstract
	
	Method TextureBuffer:TBuffer(texture:TTexture,frame=0,flags=BUFFER_COLOR)
		Return MakeBuffer(texture._frame[frame],texture._width,texture._height,flags)
	End Method
	
	Method SetBuffer(buffer:TBuffer)
		WorldConfig.Width=buffer._width
		WorldConfig.Height=buffer._height			
		Return _parent.SetBuffer(buffer)
	End Method
	
	Method BackBuffer:TBuffer()
		Return _parent.BackBuffer()
	End Method

	Method GetCaps:TCaps() Abstract
	
	Method SetMax2D(enable) Abstract
	
	Method DoMax2D()
		If Not _in_max2d
			_in_max2d=True
			SetMax2D True
		EndIf
	End Method
	Method EndMax2D()
		If _in_max2d
			_in_max2d=False
			SetMax2D False
		EndIf
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha) Abstract
	Method SetCamera(camera:TCamera) Abstract
	Method SetLight(light:TLight,index) Abstract	
	
	Method BeginEntityRender(entity:TEntity) Abstract
	Method EndEntityRender(entity:TEntity) Abstract
	
	Method RenderSurface(surface:TSurfaceRes,brush:TBrush) Abstract
	Method RenderPlane(plane:TPlane) Abstract	
	Method RenderSprite(sprite:TSprite) Abstract
	Method RenderTerrain(terrain:TTerrain) Abstract
	
	Method UpdateTextureRes:TTextureRes(frame:TTextureFrame) Abstract
	Method UpdateSurfaceRes:TSurfaceRes(surface:TSurface) Abstract

	Method MergeSurfaceRes:TSurfaceRes(base:TSurface,animation:TSurface,data) Abstract
		
	Function MakeBrush:TBrush(brush:TBrush,master:TBrush)
		Local red#,green#,blue#,alpha#,shine#,blend,fx,shader:TShader
		red=master._r;green=master._g;blue=master._b;alpha=master._a
		blend=master._blend;fx=master._fx;shader=master._shader
		
		red:*brush._r;green:*brush._g;blue:*brush._b;alpha:*brush._a
		Local shine2#=brush._shine
		If shine=0.0 Then shine=shine2
		If shine<>0.0 And shine2<>0.0 Then shine:*shine2
		If blend=0 Then blend=brush._blend
		fx=fx|brush._fx
		If shader=Null shader=brush._shader
		
		Local newbrush:TBrush=New TBrush
		newbrush.SetColor red*255,green*255,blue*255
		newbrush.SetAlpha alpha
		newbrush.SetShine shine
		newbrush.SetBlend blend
		newbrush.SetFX fx
		newbrush.SetShader shader
		
		For Local i=0 To 7
			newbrush.SetTexture brush._texture[i],i',brush._textureframe[i]
			If master._texture[i] newbrush.SetTexture master._texture[i],i',master._textureframe[i]
		Next
		
		Return newbrush
	End Function
	
	Method ScaleViewports()
		For Local camera:TCamera=EachIn WorldConfig.List[WORLDLIST_CAMERA]
			Local x,y,width,height
			camera.GetViewport x,y,width,height
			Local sx#=WorldConfig.Width/Float(_prevwidth),sy#=WorldConfig.Height/Float(_prevheight)
			If width=0
				width=GraphicsWidth()
			Else
				x:*sx;width:*sx
			EndIf
			If height=0
				height=GraphicsHeight()
			Else
				y:*sy;height:*sy
			EndIf
			camera.SetViewport x,y,width,height
		Next
	End Method
	
	Method SetShaderDriver(driver:TShaderDriver)
		_shaderdriver=driver
	End Method
End Type