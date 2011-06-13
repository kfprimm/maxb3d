
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
Import "camera.bmx"
Import "collision.bmx"
Import "body.bmx"
Import "pivot.bmx"
Import "light.bmx"
Import "mesh.bmx"
Import "plane.bmx"
Import "sprite.bmx"
Import "terrain.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core",message
End Function

Public

Global _currentworld:TWorld

Type TWorld
	Field _config:TWorldConfig=New TWorldConfig
	Field _resource_path$[],_tmp_res_path$
	Field _collisiondriver:TCollisionDriver
	
	Method New()
		SetAmbientLight 127,127,127
		SetCollisionDriver TCollisionDriver._default
	End Method
	
	Method AddResourcePath(path$)
		_resource_path=_resource_path[.._resource_path.length+1]
		_resource_path[_resource_path.length-1]=path
	End Method
	
	Method SetCollisionDriver(driver:TCollisionDriver)
		If driver
			driver.Init()
			_collisiondriver=driver
		EndIf
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
			For Local path$=EachIn _resource_path+[_tmp_res_path]
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
			pixmap=CreatePixmap(width,height,PF_BGRA8888)
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
		If String(url) _tmp_res_path=ExtractDir(String(url))
		If Not TMeshLoader.Load(mesh,Stream(url))
			_tmp_res_path=""
			If url ModuleLog "Unable to load mesh url. ("+url.ToString()+")" Else ModuleLog "Unable to load mesh url. (null)"
			Return Null
		EndIf
		_tmp_res_path=""
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
	
	Method Render:TRenderInfo(tween#=1.0)
		Local driver:TMaxB3DDriver=TMaxB3DDriver(GetGraphicsDriver())
		Assert driver,"MaxB3D driver not set!"
		Assert driver._current,"Graphics not set!"
		
		Global info:TRenderInfo=New TRenderInfo
		info.Triangles=0
		
		Global _ticks,_lastupdate
		
		If _lastupdate+1000<MilliSecs()
			info.FPS=_ticks
			_ticks=0
			_lastupdate=MilliSecs()
		Else
			_ticks:+1
		EndIf
		
		Local tricount
		For Local camera:TCamera=EachIn _config.List[WORLDLIST_CAMERA]
			If camera.GetVisible()
				Local i:TRenderInfo=RenderCamera(driver,camera)
				info.Triangles:+i.Triangles
			EndIf
		Next
		Return info
	End Method
	
	Method Update(anim_speed#,collision_speed#)
		_collisiondriver.Update _config,collision_speed
		For Local mesh:TMesh=EachIn _config.List[WORLDLIST_MESH]
			Local animator:TAnimator=mesh._animator
			If animator=Null Continue
			Local seq:TAnimSeq=animator._current
			If seq
				If animator._mode>0		
					animator._frame:+(anim_speed*animator._speed)
					If animator._frame>seq._end Or animator._frame<seq._start
						Select animator._mode
						Case ANIMATION_LOOP
							If animator._frame>seq._end animator._frame=seq._start'+(animator._frame-seq._end)
							If animator._frame<seq._start animator._frame=seq._end'-(seq._begin-animator._frame)
						Case ANIMATION_PINGPONG
							If animator._frame>seq._end animator._frame=seq._end'+(animator._frame-seq._end)
							If animator._frame<seq._start animator._frame=seq._start'-(seq._begin-animator._frame)
							animator._speed:*-1
						Case ANIMATION_SINGLE
							animator._mode=ANIMATION_STOP
						End Select
					EndIf
				EndIf
				animator.Update()
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
	
	Method RenderCamera:TRenderInfo(driver:TMaxB3DDriver,camera:TCamera)
		driver.SetCamera camera
		Local index
		For Local i=0 To 7
			Local light:TLight
			If index<CountList(_config.List[WORLDLIST_LIGHT])
				Repeat 
					light=TLight(_config.List[WORLDLIST_LIGHT].ValueAtIndex(index))
					index:+1
				Until light.GetVisible() Or index>=CountList(_config.List[WORLDLIST_LIGHT])
			EndIf
			driver.SetLight light,i
		Next
		
		UpdateSprites _config.List[WORLDLIST_SPRITE],driver,camera
				
		Global info:TRenderInfo=New TRenderInfo
		info.Triangles=0
		For Local entity:TEntity=EachIn _config.List[WORLDLIST_RENDER]
			If Not entity.GetVisible() Or entity._brush._a=0 Continue
			Local mesh:TMesh=TMesh(entity),plane:TPlane=TPlane(entity),terrain:TTerrain=TTerrain(entity)
			Local sprite:TSprite=TSprite(entity)
			Local brush:TBrush=entity._brush
			If brush._a=0 Continue
			driver.BeginEntityRender entity
			If mesh
				For Local surface:TSurface=EachIn mesh._surfaces	
					Local animation_surface:TSurface,merge_data
					If mesh._animator
						If mesh._animator._current
							animation_surface=mesh._animator.GetSurface(surface)
							merge_data=mesh._animator.GetMergeData()
						EndIf
					EndIf
					If surface._brush._a=0 Continue					
					Local resource:TSurfaceRes=driver.MergeSurfaceRes(surface,animation_surface,merge_data)				'driver.UpdateSurfaceRes(surface)
					brush=driver.MakeBrush(surface._brush,mesh._brush)
					driver.SetBrush brush,surface.HasAlpha() Or brush._fx&FX_FORCEALPHA
					info.Triangles:+driver.RenderSurface(resource,brush)
				Next
			Else
				driver.SetBrush brush,brush._a<>1
				If plane					
					info.Triangles:+driver.RenderPlane(plane)
				ElseIf sprite				
					driver.RenderSprite(sprite)
					info.Triangles:+4+(4*(brush._fx&FX_NOCULLING<>0))
				ElseIf terrain
					Local x#,y#,z#
					camera.GetPosition x,y,z,True
					terrain.Update x,y,z,camera._lastfrustum
					info.Triangles:+driver.RenderTerrain(terrain)
				EndIf	
			EndIf
			driver.EndEntityRender entity		
		Next
		Return info
	End Method
	
	Method UpdateSprites(sprites:TList,driver:TMaxB3DDriver,camera:TCamera)	
		For Local sprite:TSprite=EachIn sprites
			Local matrix:TMatrix
			If True
				If sprite._viewmode<>VIEWMODE_FREE		
					Local x#,y#,z#
					sprite.GetPosition x,y,z,True
				
					matrix = camera.GetMatrix()'.Inverse()
					matrix._m[3,0]=x
					matrix._m[3,1]=y
					matrix._m[3,2]=z
					
					matrix=TMatrix.YawPitchRoll(180,0,sprite._angle).Multiply(matrix)					
					If sprite._sx<>1.0 Or sprite._sy<>1.0 matrix=TMatrix.Scale(sprite._sx,sprite._sy,1.0).Multiply(matrix)					
					'If sprite._handlex<>0.0 Or sprite._handley<>0.0 matrix=TMatrix.Translation(-sprite._handlex,-sprite._handley,0.0).Multiply(matrix)
				Else				
					matrix = sprite.GetMatrix()					
					'If sprite.scale_x#<>1.0 Or sprite.scale_y#<>1.0
					'	sprite.mat_sp.Scale(sprite.scale_x#,sprite.scale_y#,1.0)
					'EndIf		
				EndIf
			Else
				matrix=sprite._matrix
			EndIf
			sprite._view_matrix=matrix	
		Next
	End Method
End Type

Type TMaxB3DDriver Extends TMax2DDriver
	Global _parent:TMax2DDriver
	
	Field _texture:TTexture[8],_current:TGraphics,_caps:TCaps
	Field _prevwidth,_prevheight
	
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
		If Not _currentworld
			_currentworld=CreateWorld()
			SetWorld _currentworld
		EndIf
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

Type TRenderInfo
	Field FPS
	Field Triangles
End Type

Type TCaps
	Field PointSprites
	Field MaxPointSize#
	Field Extra:Object
	
	Method Copy:TCaps()
		Local caps:TCaps=New TCaps
		caps.PointSprites=PointSprites
		caps.MaxPointSize=MaxPointSize
		caps.Extra=Extra
		Return caps
	End Method
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
Function SetCollisionDriver(driver:TCollisionDriver)
	Return _currentworld.SetCollisionDriver(driver)
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
