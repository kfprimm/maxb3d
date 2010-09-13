
Strict

Module MaxB3D.Core
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import BRL.Max2D

Import "texture.bmx"
Import "camera.bmx"
Import "pivot.bmx"
Import "light.bmx"
Import "mesh.bmx"
Import "plane.bmx"

Global _currentworld:TWorld=CreateWorld()
SetWorld _currentworld

Type TWorld
	Field _config:TWorldConfig=New TWorldConfig
		
	Method New()
		SetAmbientLight 127,127,127
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
	
	Method Render(tween#=1.0)
		Local tricount
		For Local camera:TCamera=EachIn _config.List[WORLDLIST_CAMERA]
			If camera.GetVisible() tricount:+RenderCamera(camera)
		Next
		Return tricount
	End Method
	
	Method Update()
		UpdateCollisions()
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
	
	Method UpdateCollisions()
		Global c_vec_a:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_b:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_radius:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
							
		Global c_vec_i:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_j:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_k:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
	
		Global c_mat:Byte Ptr=C_CreateMatrixObject(c_vec_i,c_vec_j,c_vec_k)
					
		Global c_vec_v:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		
		Global c_tform:Byte Ptr=C_CreateTFormObject(c_mat,c_vec_v)
	
		For Local i=0 To MAX_COLLISION_TYPES-1
			If _config.CollisionType[i]=Null Then Continue
			For Local entity:TEntity=EachIn _config.CollisionType[i]
				entity._collision=Null
		
				If entity.GetVisible()=False Continue
				
				Local x#,y#,z#
				entity.GetPosition x,y,z,True
				C_UpdateVecObject(c_vec_a,x,y,z)
				C_UpdateVecObject(c_vec_b,entity._oldx,entity._oldy,entity._oldz)
				C_UpdateVecObject(c_vec_radius,entity._radiusx,entity._radiusy,entity._radiusx)
	
				Local c_col_info:Byte Ptr=C_CreateCollisionInfoObject(c_vec_a,c_vec_b,c_vec_radius)	
				Local c_coll:Byte Ptr=Null
	
				Local response
				Repeat	
					Local hit=False		
					c_coll=C_CreateCollisionObject()	
					Local entity2_hit:TEntity=Null					
					For Local col_pair:TCollisionPair=EachIn _config.CollisionPairs					
						If col_pair.src=i
							If _config.CollisionType[col_pair.dest]=Null Then Continue
						
							For Local entity2:TEntity=EachIn _config.CollisionType[col_pair.dest]
								If entity2.GetVisible()=False Then Continue				
								If entity=entity2 Then Continue
								
								If QuickCheck(entity,entity2)=False Then Continue
			
								C_UpdateVecObject(c_vec_i,entity2._matrix._m[0,0],entity2._matrix._m[0,1],-entity2._matrix._m[0,2])
								C_UpdateVecObject(c_vec_j,entity2._matrix._m[1,0],entity2._matrix._m[1,1],-entity2._matrix._m[1,2])
								C_UpdateVecObject(c_vec_k,-entity2._matrix._m[2,0],-entity2._matrix._m[2,1],entity2._matrix._m[2,2])
						
								C_UpdateMatrixObject(c_mat,c_vec_i,c_vec_j,c_vec_k)
								C_UpdateVecObject(c_vec_v,entity2._matrix._m[3,0],entity2._matrix._m[3,1],-entity2._matrix._m[3,2])
								C_UpdateTFormObject(c_tform,c_mat,c_vec_v)
			
								If col_pair.methd<>COLLISION_METHOD_POLYGON
									C_UpdateCollisionInfoObject(c_col_info,entity2._radiusx,entity2._boxx,entity2._boxy,entity2._boxz,entity2._boxx+entity2._boxwidth,entity2._boxy+entity2._boxheight,entity2._boxz+entity2._boxdepth)
								EndIf
					
								Local tree:Byte Ptr
								If TMesh(entity2)<>Null tree=TMesh(entity2).TreeCheck()
			
								hit=C_CollisionDetect(c_col_info,c_coll,c_tform,tree,col_pair.methd)
			
								If hit Then entity2_hit=entity2;response=col_pair.response							
							Next						
						EndIf					
					Next
					
					If entity2_hit<>Null		
						Local collision:TCollision=New TCollision
						collision.x=C_CollisionX()
						collision.y=C_CollisionY()
						collision.z=C_CollisionZ()
						collision.nx=C_CollisionNX()
						collision.ny=C_CollisionNY()
						collision.nz=C_CollisionNZ()
						collision.entity=entity2_hit
						collision.triangle=C_CollisionTriangle()						
						If TMesh(entity2_hit)<>Null collision.surface=C_CollisionSurface()						
						
						entity._collision=entity._collision[..entity._collision.length+1]
						entity._collision[entity._collision.length-1]=collision	
							
						If C_CollisionResponse(c_col_info,c_coll,response)=False Then Exit						
					Else				
						Exit								
					EndIf				
					C_DeleteCollisionObject(c_coll)									
				Forever
	
				C_DeleteCollisionObject(c_coll)	
				If C_CollisionFinal(c_col_info) entity.SetPosition(C_CollisionPosX(),C_CollisionPosY(),C_CollisionPosZ(),True)		
				C_DeleteCollisionInfoObject(c_col_info)		
				entity.GetPosition entity._oldx,entity._oldy,entity._oldz,True
			Next										
		Next	
	End Method
	
	Function QuickCheck(entity:TEntity,entity2:TEntity)
		Local x#,y#,z#
		entity.GetPosition x,y,z,True
		If entity._oldx=x And entity._oldy=y And entity._oldz=z Return False
		Return True	
	End Function
	
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
			If mesh
				driver.BeginRender mesh
				For Local surface:TSurface=EachIn mesh._surfaces	
					If surface._brush._a=0 Continue				
					Local brush:TBrush=driver.MakeBrush(surface._brush,mesh._brush)
					driver.SetBrush brush,surface.HasAlpha(),surface
					tricount:+driver.RenderSurface(surface,brush)
				Next
				driver.EndRender mesh
			ElseIf plane
				driver.SetBrush plane._brush,plane._brush._a<>1
				tricount:+driver.RenderPlane(plane)
			EndIf			
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
	
	Method SetBrush(brush:TBrush,hasalpha,surface:TSurface=Null) Abstract
	Method SetCamera(camera:TCamera) Abstract
	Method SetLight(light:TLight,index) Abstract	
	
	Method RenderSurface(surface:TSurface,brush:TBrush) Abstract
	Method BeginRender(entity:TEntity) Abstract
	Method EndRender(entity:TEntity) Abstract
	
	Method RenderPlane(plane:TPlane) Abstract
	
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

Function BeginMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).BeginMax2D()
End Function
Function EndMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).EndMax2D()
End Function