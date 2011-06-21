
Strict

Import BRL.Max2D
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

Type TMaxB3DDriver Extends TMax2DDriver
	Global _parent:TMax2DDriver
	
	Field _texture:TTexture[8],_current:TGraphics,_caps:TCaps
	Field _prevwidth,_prevheight
	Field _shaderdriver:TShaderDriver
	
	Method CreateFrameFromPixmap:TImageFrame(pixmap:TPixmap,flags) 
		Return _parent.CreateFrameFromPixmap(pixmap,flags)
	End Method
	
	Method SetBlend( blend )
		Return _parent.SetBlend(blend)
	End Method
	Method SetAlpha( alpha# )
		Return _parent.SetAlpha(alpha)
	End Method
	Method SetColor( red,green,blue )
		Return _parent.SetColor(red,green,blue)
	End Method
	Method SetClsColor( red,green,blue )
		Return _parent.SetClsColor(red,green,blue)
	End Method
	Method SetViewport( x,y,width,height )
		Return _parent.SetViewport(x,y,width,height)
	End Method
	Method SetTransform( xx#,xy#,yx#,yy# )
		Return _parent.SetTransform(xx,xy,yx,yy)
	End Method
	Method SetLineWidth( width# )
		Return _parent.SetLineWidth(width)
	End Method
	
	Method Cls()
		Return _parent.Cls()
	End Method
	Method Plot( x#,y# )
		Return _parent.Plot(x,y)
	End Method
	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# )
		Return _parent.DrawLine(x0,y0,x1,y1,tx,ty)
	End Method
	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# )
		Return _parent.DrawRect(x0,y0,x1,y1,tx,tx)
	End Method
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# )
		Return _parent.DrawOval(x0,y0,x1,y1,tx,ty)
	End Method
	Method DrawPoly( xy#[],handlex#,handley#,originx#,originy# )
		Return _parent.DrawPoly(xy,handlex,handlex,originx,originy)
	End Method
		
	Method DrawPixmap( pixmap:TPixmap,x,y )
		Return _parent.DrawPixmap(pixmap,x,y)
	End Method
	Method GrabPixmap:TPixmap( x,y,width,height )
		Return _parent.GrabPixmap(x,y,width,height)
	End Method
	
	Method SetResolution( width#,height# )
		Return _parent.SetResolution(width,height)
	End Method
	
	Method GraphicsModes:TGraphicsMode[]()
		Return _parent.GraphicsModes()
	End Method
		
	Method AttachGraphics:TGraphics( widget,flags )
		Return MakeGraphics(_parent.AttachGraphics(widget,flags))		
	End Method
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		RunHooks _creategraphicshook,Null
		Return MakeGraphics(_parent.CreateGraphics(width,height,depth,hertz,flags))
	End Method
	
	Method SetGraphics( g:TGraphics )
		_parent.SetGraphics(g)
		_current=g
		WorldConfig.Width=GraphicsWidth()
		WorldConfig.Height=GraphicsHeight()	
		ScaleViewports	
		_prevwidth=GraphicsWidth();_prevheight=GraphicsHeight()
		_caps=GetCaps()
	End Method
	
	Method Flip( sync )
		Return _parent.Flip(sync)
	End Method
	
	Method MakeGraphics:TGraphics(g:TGraphics)
		TMax2DGraphics(g)._driver=Self
		Return g
	End Method
	
	Method GetCaps:TCaps() Abstract
	
	Method BeginMax2D() Abstract
	Method EndMax2D() Abstract
	
	Method SetBrush(brush:TBrush,hasalpha) Abstract
	Method SetCamera(camera:TCamera) Abstract
	Method SetLight(light:TLight,index) Abstract	
	
	Method BeginEntityRender(entity:TEntity) Abstract
	Method EndEntityRender(entity:TEntity) Abstract
	
	Method RenderSurface(surface:TSurfaceRes,brush:TBrush) Abstract
	Method RenderPlane(plane:TPlane) Abstract	
	Method RenderSprite(sprite:TSprite) Abstract
	Method RenderTerrain(terrain:TTerrain) Abstract
	
	Method UpdateTextureRes:TTextureRes(texture:TTexture) Abstract
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
	
	'Method SetRenderTarget(target:TRenderTarget) Abstract
End Type

'Type TRenderTarget
	
'End Type

Type TCaps
	Field PointSprites
	Field MaxPointSize#
	
	Method CopyBase(caps:TCaps)
		PointSprites=caps.PointSprites
		MaxPointSize=caps.MaxPointSize
	End Method
End Type
