
Strict

Import BRL.Max2D
Import Prime.Max2DEx
Import "light.bmx"
Import "camera.bmx"
Import "mesh.bmx"
Import "flat.bmx"
Import "sprite.bmx"
Import "terrain.bmx"
Import "bspmodel.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/driver",message
End Function

Public

Type TMaxB3DShaderData
	Field _projection:TMatrix
'	Field _modelview:TMatrix
	Field _modelviewproj:TMatrix
End Type

Global _creategraphicshook=AllocHookId()

Type TCaps
	Field PointSprites
	Field MaxPointSize#
	
	Method CopyBase(caps:TCaps)
		PointSprites=caps.PointSprites
		MaxPointSize=caps.MaxPointSize
	End Method
End Type

Type TMaxB3DDriver Extends TMax2DExDriver
	Global _parent:TMax2DExDriver
	
	Field _texture:TTexture[8],_caps:TCaps
	Field _prevwidth,_prevheight
	Field _in_max2d=True
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		RunHooks _creategraphicshook,Null
		Return Super.CreateGraphics(width,height,depth,hertz,flags)
	End Method
	
	Method AttachGraphics:TGraphics( widget,flags )
		RunHooks _creategraphicshook,Null
		Return Super.AttachGraphics(widget,flags)
	End Method
	
	Method SetGraphics(g:TGraphics)
		_parent.SetGraphics(g)
		_current=g
		If _prevwidth<>GraphicsWidth() Or _prevheight<>GraphicsHeight()
			WorldConfig.Width=GraphicsWidth()
			WorldConfig.Height=GraphicsHeight()	
			ScaleViewports	
			_prevwidth=GraphicsWidth();_prevheight=GraphicsHeight()
		EndIf
		Global firsttime=True
		If firsttime
			_caps=GetCaps()
			firsttime=False
		EndIf
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
	Method RenderFlat(plane:TFlat) Abstract	
	Method RenderSprite(sprite:TSprite) Abstract
	Method RenderTerrain(terrain:TTerrain) Abstract
	Method RenderBSPTree(tree:TBSPTree) Abstract
	
	Method UpdateTextureRes:TTextureRes(frame:TTextureFrame,flags) Abstract
	Method UpdateSurfaceRes:TSurfaceRes(surface:TSurface) Abstract

	Method MergeSurfaceRes:TSurfaceRes(base:TSurface,animation:TSurface,data) Abstract
		
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
End Type
