
Strict

Module MaxB3D.Core
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import BRL.Max2D

Import "texture.bmx"
Import "physics.bmx"
Import "camera.bmx"
Import "pivot.bmx"
Import "light.bmx"
Import "mesh.bmx"
Import "plane.bmx"
Import "terrain.bmx"

Global _currentworld:TWorld=CreateWorld()
SetWorld _currentworld

Type TWorld
	Field _config:TWorldConfig=New TWorldConfig
	Field _physicsdriver:TPhysicsDriver=B3DPhysicsDriver()
	
	Method New()
		SetAmbientLight 127,127,127
	End Method
	
	Method SetPhysics(driver:TPhysicsDriver)
		driver.Init()
	End Method
	
	Method GetAmbientLight(red Var,green Var,blue Var)
		red=_config.AmbientRed
		green=_config.AmbientGreen
		blue=_config.AmbientBlue
	End Method
	Method SetAmbientLight(red,green,blue)
		_config.AmbientRed=red
		_config.AmbientGreen=green
		_config.AmbientBlue=blue
	End Method
	
	Method GetWireFrame()
		Return _config.Wireframe
	End Method
	Method SetWireFrame(enable)
		_config.Wireframe=enable
	End Method
	
	Method AddTexture:TTexture(url:Object,flags=TEXTURE_DEFAULT)
		Local texture:TTexture=New TTexture,pixmap:TPixmap
		If Int[](url)
			Local arr[]=Int[](url),width,height
			If arr.length=0 Return Null
			If arr.length=1 width=arr[0];height=arr[0]
			If arr.length>1 width=arr[0];height=arr[1]		
			pixmap=CreatePixmap(width,height,PF_RGBA8888)
		ElseIf TPixmap(url) 
			pixmap=TPixmap(url)
		Else
			pixmap=LoadPixmap(url)
		EndIf
		
		If pixmap=Null Return Null
		texture.SetPixmap pixmap
		texture.SetFlags flags
		_config.AddObject texture,WORLDLIST_TEXTURE
		Return texture
	End Method
	
	Method AddBrush:TBrush(url:Object=Null)
		Local brush:TBrush=New TBrush
		Local red=255,green=255,blue=255,texture:TTexture
		If Int[](url)
			Local clr[]=Int[](url)
			If clr.length>0 red=clr[0]
			If clr.length>1 green=clr[1]
			If clr.length>2 blue=clr[2]
		ElseIf Float[](url)
			Local clr[]=Int[](url)
			If clr.length>0 red=clr[0]*255
			If clr.length>1 green=clr[1]*255
			If clr.length>2 blue=clr[2]*255
		ElseIf TTexture(url)
			texture=TTexture(url)
		ElseIf url<>Null
			texture=_currentworld.AddTexture(url)
		EndIf
		brush.SetTexture texture,0
		brush.SetColor red,green,blue
		_config.AddObject brush,WORLDLIST_BRUSH
		Return brush
	End Method
	
	Method AddEntity(entity:TEntity,parent:TEntity,otherlist)
		entity.SetParent(parent)
		entity.AddLink _config.AddObject(entity,WORLDLIST_ENTITY)
		entity.AddLink _config.AddObject(entity,otherlist)
	End Method
	
	Method AddPivot:TPivot(parent:TEntity=Null)
		Local pivot:TPivot=New TPivot
		pivot.AddToWorld parent,[WORLDLIST_PIVOT]
		Return pivot		
	End Method
	
	Method AddCamera:TCamera(parent:TEntity=Null)
		Local camera:TCamera=New TCamera
		camera.AddToWorld parent,[WORLDLIST_CAMERA]
		Return camera
	End Method
	
	Method AddLight:TLight(mode,parent:TEntity=Null)
		Local light:TLight=New TLight
		light.SetMode mode
		light.AddToWorld parent,[WORLDLIST_LIGHT]
		Return light
	End Method	
	
	Method AddMesh:TMesh(url:Object,parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		If Not TMeshLoader.Load(url,mesh) Return Null
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
		Return mesh
	End Method
	
	Method AddPlane:TPlane(parent:TEntity=Null)
		Local plane:TPlane=New TPlane
		plane.AddToWorld parent,[WORLDLIST_PLANE,WORLDLIST_RENDER]
		Return plane
	End Method
	
	Method AddTerrain:TTerrain(url:Object,parent:TEntity=Null)
		Local terrain:TTerrain=New TTerrain
		terrain.SetMap url
		terrain.AddToWorld parent,[WORLDLIST_TERRAIN,WORLDLIST_RENDER]
		Return terrain
	End Method
	
	Method Render(tween#=1.0)
		Local tricount
		For Local camera:TCamera=EachIn _config.List[WORLDLIST_CAMERA]
			If camera.GetVisible() tricount:+RenderCamera(camera)
		Next
		Return tricount
	End Method
	
	Method Update()
		_physicsdriver.Update _config
	End Method

	Method SetCollisions(src,dest,methd,response)
		Local pair:TCollisionPair=New TCollisionPair
		pair.src=src;pair.dest=dest
		pair.methd=methd;pair.response=response
		
		For Local pair2:TCollisionPair=EachIn _config.CollisionPairs
			If pair2.src=pair2.src And pair2.dest=pair2.dest
				pair2.methd=pair2.methd
				pair2.response=pair2.response
				Return
			EndIf
		Next		
		_config.CollisionPairs.AddLast pair
	End Method
	
	Method RenderCamera(camera:TCamera)
		Local driver:TMaxB3DDriver=TMaxB3DDriver(GetGraphicsDriver())
		Assert driver,"MaxB3D driver not set!"
		Assert driver._current,"Graphics not set!"
		driver.SetCamera camera
		Local index
		For Local light:TLight=EachIn _config.List[WORLDLIST_LIGHT]
			driver.SetLight light,index
			index:+1
			If index>7 index=0
		Next
		Local tricount
		For Local entity:TRenderEntity=EachIn _config.List[WORLDLIST_RENDER]
			If Not entity.GetVisible() Or entity._brush._a=0 Continue
			Local mesh:TMesh=TMesh(entity)
			Local plane:TPlane=TPlane(entity)
			Local terrain:TTerrain=TTerrain(entity)
			driver.BeginRender entity
			If mesh				
				For Local surface:TSurface=EachIn mesh._surfaces	
					If surface._brush._a=0 Continue				
					Local brush:TBrush=driver.MakeBrush(surface._brush,mesh._brush)
					driver.SetBrush brush,surface.HasAlpha()
					tricount:+driver.RenderSurface(surface,brush)
				Next
			ElseIf plane
				driver.SetBrush plane._brush,plane._brush._a<>1
				tricount:+driver.RenderPlane(plane)
			ElseIf terrain
				driver.SetBrush terrain._brush,terrain._brush._a<>1
				Local x#,y#,z#
				camera.GetPosition x,y,z,True
				terrain.Update camera._lastglobal,x,y,z,camera._lastfrustum
				tricount:+driver.RenderTerrain(terrain)
			EndIf	
			driver.EndRender entity		
		Next
		Return tricount
	End Method
End Type

Type TMaxB3DDriver Extends TMax2DDriver
	Global _parent:TMax2DDriver
	
	Field _texture:TTexture[8],_current:TGraphics
	
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
		Return _parent.AttachGraphics(widget,flags)
	End Method
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		Local g:TGraphics=_parent.CreateGraphics(width,height,depth,hertz,flags)
		TMax2DGraphics(g)._driver=Self
		Return g
	End Method
	
	Method SetGraphics( g:TGraphics )
		_parent.SetGraphics(g)
		WorldConfig.Width=GraphicsWidth()
		WorldConfig.Height=GraphicsHeight()
		_current=g
	End Method
	
	Method Flip( sync )
		Return _parent.Flip(sync)
	End Method
	
	Method BeginMax2D() Abstract
	Method EndMax2D() Abstract
	
	Method SetBrush(brush:TBrush,hasalpha) Abstract
	Method SetCamera(camera:TCamera) Abstract
	Method SetLight(light:TLight,index) Abstract	
	
	Method RenderSurface(surface:TSurface,brush:TBrush) Abstract
	Method BeginRender(entity:TEntity) Abstract
	Method EndRender(entity:TEntity) Abstract
	
	Method RenderPlane(plane:TPlane) Abstract
	
	Method RenderTerrain(terrain:TTerrain) Abstract
	
	Method UpdateTextureRes:TTextureRes(texture:TTexture) Abstract
	Method UpdateSurfaceRes:TSurfaceRes(surface:TSurface) Abstract
	
	Function MakeBrush:TBrush(brush:TBrush,master:TBrush)
		Local red#,green#,blue#,alpha#,shine#,blend,fx
		red=master._r;green=master._g;blue=master._b;alpha=master._a
		blend=master._blend;fx=master._fx
		
		red:*brush._r;green:*brush._g;blue:*brush._b;alpha:*brush._a
		Local shine2#=brush._shine
		If shine=0.0 Then shine=shine2
		If shine<>0.0 And shine2<>0.0 Then shine:*shine2
		If blend=0 Then blend=brush._blend
		fx=fx|brush._fx
		
		Local newbrush:TBrush=New TBrush
		newbrush.SetColor red*255,green*255,blue*255
		newbrush.SetAlpha alpha
		newbrush.SetShine shine
		newbrush.SetBlend blend
		newbrush.SetFX fx
		
		For Local i=0 To 7
			newbrush.SetTexture brush._texture[i],i',brush._textureframe[i]
			If master._texture[i] newbrush.SetTexture master._texture[i],i',master._textureframe[i]
		Next
		
		Return newbrush
	End Function
End Type

Function CreateWorld:TWorld()
	Return New TWorld
End Function
Function SetWorld(world:TWorld)
	_currentworld=world
	WorldConfig=_currentworld._config
End Function

Function SetPhysicsDriver(driver:TPhysicsDriver)
	Return _currentworld.SetPhysics(driver)
End Function

Function BeginMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).BeginMax2D()
End Function
Function EndMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).EndMax2D()
End Function