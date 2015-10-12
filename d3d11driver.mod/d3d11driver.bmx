
Strict

Rem
	bbdoc: Direct3D 11 renderer for MaxB3D
End Rem
Module MaxB3D.D3D11Driver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import GFX.D3D11Max2DEx

?Win32

Type TD3D11MaxB3DDriver Extends TMaxB3DDriver
	Method MakeBuffer:TBuffer(src:Object,width,height,flags)
	End Method
	
	Method GetCaps:TCaps()
	End Method
	
	Method SetMax2D(enable)
	End Method

	Method Abbr$()
		Return "d3d11"
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha,config:TWorldConfig)
	End Method
	Method SetCamera(camera:TCamera,config:TWorldConfig)
		camera.UpdateMatrices()
	End Method
	Method SetLight(light:TLight,index)
	End Method
	
	Method BeginEntityRender(entity:TEntity)
	End Method
	Method EndEntityRender(entity:TEntity)
	End Method
	
	Method RenderSurface(surface:TSurfaceRes,brush:TBrush)
	End Method
	Method RenderPlane(plane:TInfinitePlane)
	End Method
	Method RenderSprite(sprite:TSprite)
	End Method
	Method RenderTerrain(terrain:TTerrain)
	End Method
	Method RenderBSPTree(tree:TBSPTree)
	End Method
	
	Method UpdateTextureRes:TTextureRes(frame:TTextureFrame,flags)
	End Method
	Method UpdateSurfaceRes:TSurfaceRes(surface:TSurface)
	End Method

	Method MergeSurfaceRes:TSurfaceRes(base:TSurface,animation:TSurface,data)
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function D3D11MaxB3DDriver:TD3D11MaxB3DDriver()
	If D3D11Max2DExDriver()
		Global driver:TD3D11MaxB3DDriver=New TD3D11MaxB3DDriver
		driver._parent=D3D11Max2DExDriver()
		Return driver
	End If
End Function

Rem
	bbdoc: Utility function that sets the MaxB3D D3D11 driver and calls Graphics.
End Rem
Function D3D11Graphics3D:TGraphics(width,height,depth=0,hertz=0,flags=0)
	SetGraphicsDriver D3D11MaxB3DDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
	Return Graphics(width,height,depth,hertz,flags)
End Function

Local driver:TD3D11MaxB3DDriver=D3D11MaxB3DDriver()
If driver SetGraphicsDriver driver,GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
