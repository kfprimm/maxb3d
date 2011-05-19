
Strict

Rem
	bbdoc: MaxB3D core logic
End Rem
Module MaxB3D.Core
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Mostly derived from the MiniB3D source."
ModuleInfo "Credit: Terrain system adapted from Warner's engine."

Import BRL.Max2D

Import MaxB3D.Logging

Import "texture.bmx"
Import "physics.bmx"
Import "camera.bmx"
Import "pivot.bmx"
Import "light.bmx"
Import "mesh.bmx"
Import "plane.bmx"
Import "sprite.bmx"
Import "terrain.bmx"

Private
Function ModuleLog(message$)
	_maxb3d_logger.Write "core",message
End Function

Public

Global _currentworld:TWorld=CreateWorld()
SetWorld _currentworld

Type TWorld
	Field _config:TWorldConfig=New TWorldConfig
	Field _resource_path$[]
	Field _physicsdriver:TPhysicsDriver=B3DPhysicsDriver()
	
	Method New()
		SetAmbientLight 127,127,127
	End Method
	
	Method AddResourcePath(path$)
		_resource_path=_resource_path[.._resource_path.length+1]
		_resource_path[_resource_path.length-1]=path
	End Method
	
	Method SetPhysics(driver:TPhysicsDriver)
		driver.Init()
		_physicsdriver=driver
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
	
	Method Stream:Object(url:Object)
		Local stream:TStream=ReadStream(url)
		If stream Return stream
		If String(url)
			Local uri$=String(url),file$=StripDir(uri)
			For Local path$=EachIn _resource_path
				stream=ReadStream(path+"/"+file)
				If stream Return stream
			Next
			stream=ReadStream(file)
			If stream Return stream
			Return url
		EndIf 
		Return url
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
			pixmap=LoadPixmap(Stream(url))
		EndIf
		
		If pixmap=Null 
			If url ModuleLog "Invalid texture url passed. ("+url.ToString()+")" Else ModuleLog "Invalid texture url passed. ("+url.ToString()+")"
			Return Null
		EndIf
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
			texture=AddTexture(url)
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
		If Not TMeshLoader.Load(mesh,Stream(url))
			If url ModuleLog "Unable to load mesh url. ("+url.ToString()+")" Else ModuleLog "Unable to load mesh url. (null)"
			Return Null
		EndIf
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
		Return mesh
	End Method
	
	Method AddPlane:TPlane(parent:TEntity=Null)
		Local plane:TPlane=New TPlane
		plane.AddToWorld parent,[WORLDLIST_PLANE,WORLDLIST_RENDER]
		Return plane
	End Method
	
	Method AddSprite:TSprite(url:Object,flags=TEXTURE_DEFAULT,parent:TEntity=Null)
		Local sprite:TSprite=New TSprite
		sprite.SetTexture AddTexture(url,flags)
		sprite.AddToWorld parent,[WORLDLIST_SPRITE,WORLDLIST_RENDER]
		Return sprite
	End Method
	
	Method AddTerrain:TTerrain(url:Object,parent:TEntity=Null)
		Local terrain:TTerrain=New TTerrain
		terrain.SetMap url
		terrain.AddToWorld parent,[WORLDLIST_TERRAIN,WORLDLIST_RENDER]
		Return terrain
	End Method
	
	Method AddBody:TBody()
		Local body:TBody=New TBody
		body.AddToWorld Null,[WORLDLIST_BODY]
		Return body
	End Method
	
	Method AddBone:TBone(parent:TEntity=Null)
		Local bone:TBone=New TBone
		bone.AddToWorld parent,[WORLDLIST_BONE]
		Return bone
	End Method
	
	Method Render(tween#=1.0)
		Local driver:TMaxB3DDriver=TMaxB3DDriver(GetGraphicsDriver())
		Assert driver,"MaxB3D driver not set!"
		Assert driver._current,"Graphics not set!"
		
		Local tricount
		For Local camera:TCamera=EachIn _config.List[WORLDLIST_CAMERA]
			If camera.GetVisible() tricount:+RenderCamera(driver,camera)
		Next
		Return tricount
	End Method
	
	Method Update()
		_physicsdriver.Update _config
		For Local mesh:TMesh=EachIn _config.List[WORLDLIST_MESH]
			If mesh._animator
				mesh._animator._frame=( mesh._animator._frame+.2 )Mod mesh._animator.GetFrameCount()
				mesh._animator.Update()
			EndIf
		Next
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
	
	Method RenderCamera(driver:TMaxB3DDriver,camera:TCamera)
		driver.SetCamera camera
		Local index
		For Local i=0 To 7
			Local light:TLight
			If index<CountList(_config.List[WORLDLIST_LIGHT])
				Repeat 
					light=TLight(_config.List[WORLDLIST_LIGHT].ValueAtIndex(index))
					index:+1
				Until light.GetVisible()
			EndIf
			driver.SetLight light,i
		Next
		
		For Local sprite:TSprite=EachIn _config.List[WORLDLIST_SPRITE]
				Local matrix:TMatrix
				If sprite._viewmode<>VIEWMODE_FREE		
					Local x#,y#,z#
					sprite.GetPosition x,y,z,True
				
					matrix = camera.GetMatrix()'.Inverse()
					matrix._m[3,0]=x
					matrix._m[3,1]=y
					matrix._m[3,2]=z
					
					matrix=TMatrix.YawPitchRoll(180,0,sprite._angle).Multiply(matrix)					
					'If sprite._sx<>1.0 Or sprite._sy<>1.0 matrix=TMatrix.Scale(sprite._sx,sprite._sy,1.0).Multiply(matrix)					
					'If sprite._handlex<>0.0 Or sprite._handley<>0.0 matrix=TMatrix.Translation(-sprite._handlex,-sprite._handley,0.0).Multiply(matrix)
				Else				
					matrix = sprite.GetMatrix()					
					'If sprite.scale_x#<>1.0 Or sprite.scale_y#<>1.0
					'	sprite.mat_sp.Scale(sprite.scale_x#,sprite.scale_y#,1.0)
					'EndIf		
				EndIf		
				sprite._view_matrix = matrix	
		Next
		
		Local tricount
		For Local entity:TRenderEntity=EachIn _config.List[WORLDLIST_RENDER]
			If Not entity.GetVisible() Or entity._brush._a=0 Continue
			Local mesh:TMesh=TMesh(entity),plane:TPlane=TPlane(entity),terrain:TTerrain=TTerrain(entity)
			Local sprite:TSprite=TSprite(entity)
			driver.BeginEntityRender entity
			If mesh
				For Local surface:TSurface=EachIn mesh._surfaces	
					Local animation_surface:TSurface,merge_data
					If mesh._animator
						animation_surface=mesh._animator.GetSurface(surface)
						merge_data=mesh._animator.GetMergeData()
					EndIf
					If surface._brush._a=0 Continue				
					Local brush:TBrush=driver.MakeBrush(surface._brush,mesh._brush)
					driver.SetBrush brush,surface.HasAlpha()
					tricount:+driver.RenderSurface(driver.MergeSurfaceRes(surface,animation_surface,merge_data),brush)
				Next
			ElseIf plane
				driver.SetBrush plane._brush,plane._brush._a<>1
				tricount:+driver.RenderPlane(plane)
			ElseIf sprite				
				driver.SetBrush sprite._brush,sprite._brush._a<>1
				driver.RenderSprite(sprite)
				tricount:+4+(4*(sprite._brush._fx&FX_NOCULLING<>0))
			ElseIf terrain
				driver.SetBrush terrain._brush,terrain._brush._a<>1
				Local x#,y#,z#
				camera.GetPosition x,y,z,True
				terrain.Update camera._lastglobal,x,y,z,camera._lastfrustum
				tricount:+driver.RenderTerrain(terrain)
			EndIf	
			driver.EndEntityRender entity		
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
		Return MakeGraphics(_parent.AttachGraphics(widget,flags))		
	End Method
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		Return MakeGraphics(_parent.CreateGraphics(width,height,depth,hertz,flags))
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
	
	Method MakeGraphics:TGraphics(g:TGraphics)
		TMax2DGraphics(g)._driver=Self
		Return g
	End Method
	
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

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateWorld:TWorld()
	Return New TWorld
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetWorld(world:TWorld)
	_currentworld=world
	WorldConfig=_currentworld._config
End Function

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetPhysicsDriver(driver:TPhysicsDriver)
	Return _currentworld.SetPhysics(driver)
End Function

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function BeginMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).BeginMax2D()
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function EndMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).EndMax2D()
End Function