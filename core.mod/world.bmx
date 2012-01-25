
Strict

Import "worldconfig.bmx"
Import "collision.bmx"
Import "body.bmx"
Import "pivot.bmx"
Import "custom_entity.bmx"
Import "driver.bmx"
Import "pick.bmx"
Import "meshloader.bmx"
Import "meshloaderempty.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/world",message
End Function

Public

Type TWorld
	Field _config:TWorldConfig=New TWorldConfig
	Field _collisiondriver:TCollisionDriver
	
	Method New()
		SetAmbientLight 127,127,127
		SetCollisionDriver TCollisionDriver._default
		AddTextureFilter "", TEXTURE_COLOR|TEXTURE_MIPMAP
		
		_config.Width  = GraphicsWidth()
		_config.Height = GraphicsHeight()
		
		TMaxB3DDriver._configs :+ [_config]
	End Method
	
	Method AddResourcePath(path$)
		_config.ResourcePath=_config.ResourcePath[.._config.ResourcePath.length+1]
		_config.ResourcePath[_config.ResourcePath.length-1]=path
	End Method
	
	Method ClearTextureFilters()
		_config.TextureFilters = Null
	End Method
	
	Method AddTextureFilter(text$, flags)
		_config.TextureFilters :+ [[text, String(flags)]]
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
	
	Method GetDither()
		Return _config.Dither
	End Method
	Method SetDither(enable)
		_config.Dither=enable
	End Method
	
	Method PickTarget(src:Object,target#[],ax# Var,ay# Var,az# Var,bx# Var,by# Var,bz# Var,radius#)
		If target.length = 1
		
		ElseIf target.length = 2
			Local camera:TCamera = TCamera(src)
			camera.Unproject target[0], target[1], 1, ax, ay, az
			camera.Unproject target[0], target[1], 0, bx, by, bz
		Else
		
		EndIf
	End Method
	
	'EntityPick ( entity,range# )
	'CameraPick ( camera,viewport_x#,viewport_y# )
	'LinePick ( x#,y#,z#,dx#,dy#,dz#[,radius#] )
	Method Picks:TPick[](src:Object, target:Object, sort = False)
		Local ax#,ay#,az#,bx#,by#,bz#,radius#=0.0
		TEntity.GetTargetPosition src,ax,ay,az
		PickTarget src,Float[](target),ax,ay,az,bx,by,bz,radius
		
		Global c_vec_a:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_b:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_radius:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_col_info:Byte Ptr=C_CreateCollisionInfoObject(c_vec_a,c_vec_b,c_vec_radius)

		Global c_line:Byte Ptr=C_CreateLineObject(0.0,0.0,0.0,0.0,0.0,0.0)

		Global c_vec_i:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_j:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_k:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)

		Global c_mat:Byte Ptr=C_CreateMatrixObject(c_vec_i,c_vec_j,c_vec_k)
		Global c_vec_v:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_tform:Byte Ptr=C_CreateTFormObject(c_mat,c_vec_v)
		
		C_UpdateLineObject(c_line,ax,ay,az,bx-ax,by-ay,bz-az)
		
		Local c_col:Byte Ptr=C_CreateCollisionObject(), picks:TPick[]
		
		For Local entity:TEntity=EachIn _config.List[WORLDLIST_ENTITY]		
			If entity._pickmode=PICKMODE_OFF Or Not entity.GetVisible() Then Continue
			If entity._pickmode=PICKMODE_POLYGON And TMesh(entity)=Null Continue
			
			Local matrix:TMatrix = entity._matrix
			C_UpdateVecObject(c_vec_i,matrix._m[0,0],matrix._m[0,1],-matrix._m[0,2])
			C_UpdateVecObject(c_vec_j,matrix._m[1,0],matrix._m[1,1],-matrix._m[1,2])
			C_UpdateVecObject(c_vec_k,-matrix._m[2,0],-matrix._m[2,1],matrix._m[2,2])
		
			C_UpdateMatrixObject(c_mat,c_vec_i,c_vec_j,c_vec_k)
			C_UpdateVecObject(c_vec_v,matrix._m[3,0],matrix._m[3,1],matrix._m[3,2])
			C_UpdateTFormObject(c_tform,c_mat,c_vec_v)
		
			Local tree:Byte Ptr=Null
			If entity._pickmode<>PICKMODE_POLYGON
				C_UpdateCollisionInfoObject(c_col_info,entity._radiusx,entity._boxx,entity._boxy,entity._boxz,entity._boxx+entity._boxwidth,entity._boxy+entity._boxheight,entity._boxz+entity._boxdepth)
			Else
				If TMesh(entity)<>Null tree=TMesh(entity).TreeCheck()		
			EndIf

			If C_Pick(c_col_info,c_line,radius,c_col,c_tform,tree,entity._pickmode)
				Local info:TPick = New TPick
				info.entity = entity
				info.x  = C_CollisionX()
				info.y  = C_CollisionY()
				info.z  = C_CollisionZ()
				
				info.nx = C_CollisionNX()
				info.ny = C_CollisionNY()
				info.nz = C_CollisionNZ()
			
				info.time = C_CollisionTime()
				If TMesh(entity)<>Null And entity._pickmode = PICKMODE_POLYGON info.surface = TMesh(entity)._surfaces[C_CollisionSurface() - 1]
				info.triangle=C_CollisionTriangle()
				
				picks :+ [info]
			EndIf		
		Next
		
		C_DeleteCollisionObject(c_col)
		
		Return picks		
	End Method
	
	Method Pick:TPick(src:Object, target:Object)
		Local picks:TPick[] = Picks(src, target, True)
		If picks.length > 0 Return picks[0]
	End Method
		
	Method AddTexture:TTexture(url:Object,flags=TEXTURE_DEFAULT)
		If TTexture(url) Return TTexture(url)
		If Not Int[](url) And Not TPixmap(url) url = _config.GetStream(url)
		Return New TTexture.Init(_config,url,flags)
	End Method
	
	Method AddBrush:TBrush(url:Object=Null)
		Return New TBrush.Init(_config, url)
	End Method
	
	Method AddPivot:TPivot(parent:TEntity=Null)
		Return TPivot(New TPivot.Init(_config, parent))
	End Method
	
	Method AddCamera:TCamera(parent:TEntity=Null)
		Return TCamera(New TCamera.Init(_config, parent))
	End Method
	
	Method AddLight:TLight(mode,parent:TEntity=Null)
		Local light:TLight=New TLight
		light.SetMode mode
		Return TLight(light.Init(_config, parent))
	End Method	
	
	Method AddMesh:TMesh(url:Object,parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		If String(url) _config.TmpResourcePath=ExtractDir(String(url))
		If Not TMeshLoader.Load(_config,mesh,_config.GetStream(url))
			_config.TmpResourcePath = ""
			If url ModuleLog "Unable to load mesh url. ("+url.ToString()+")" Else ModuleLog "Unable to load mesh url. (null)"
			Return Null
		EndIf
		_config.TmpResourcePath = ""
		Return TMesh(mesh.Init(_config, parent))
	End Method
	
	Method AddFlat:TFlat(parent:TEntity=Null)
		Return TFlat(New TFlat.Init(_config, parent))
	End Method
	
	Method AddSprite:TSprite(url:Object,flags=TEXTURE_DEFAULT,parent:TEntity=Null)
		Local sprite:TSprite=New TSprite 
		If url sprite.SetTexture AddTexture(url,flags)
		Return TSprite(sprite.Init(_config, parent))
	End Method
	
	Method AddTerrain:TTerrain(url:Object,parent:TEntity=Null)
		Local terrain:TTerrain=New TTerrain
		terrain.SetMap url
		Return TTerrain(terrain.Init(_config, parent))
	End Method
	
	Method AddBody:TBody()
		Return TBody(New TBody.Init(_config, Null))
	End Method
	
	Method AddBone:TBone(parent:TEntity=Null)
		Return TBone(New TBone.Init(_config, parent))
	End Method
	
	Method AddBSPModel:TBSPModel(url:Object,parent:TEntity=Null)
		Local bsp:TBSPModel=New TBSPModel
		bsp.SetTree TBSPTree(url)
		Return TBSPModel(bsp.Init(_config, parent))
	End Method
	
	Method AddCustomEntity:TCustomEntity(entity:TCustomEntity,parent:TEntity=Null)
		Return TCustomEntity(entity.Init(_config, parent))
	End Method
	
	Method Render:TRenderInfo(tween#=1.0)
		Local driver:TMaxB3DDriver=TMaxB3DDriver(GetGraphicsDriver())

		Global info:TRenderInfo=New TRenderInfo
		info.Triangles=0
		info.Entities=0

		For Local camera:TCamera=EachIn _config.List[WORLDLIST_CAMERA]
			If Not camera.GetVisible() Continue
			Local i:TRenderInfo=RenderCamera(camera)
			info.Triangles:+i.Triangles
			info.Entities:+i.Entities
		Next
		
		Global _ticks,_lastupdate

		If _lastupdate+1000<MilliSecs()
			info.FPS=_ticks
			_ticks=0
			_lastupdate=MilliSecs()
		Else
			_ticks:+1
		EndIf
		
		Return info
	End Method
	
	Method RenderCamera:TRenderInfo(camera:TCamera)
		Local driver:TMaxB3DDriver=TMaxB3DDriver(GetGraphicsDriver())
		Global info:TRenderInfo=New TRenderInfo
		
		If driver._in_max2d driver.EndMax2D
		
		driver.SetCamera camera,_config
		SetLighting	driver,camera
		
		Local list:TList=CreateList()
		For Local entity:TEntity=EachIn _config.List[WORLDLIST_RENDER]
			If entity.GetVisible()=False Or entity._brush._a=0 Continue
			If camera.InView(entity)
				Local link:TLink=list._head
				If entity._order > 0
					Repeat
						link=link._succ
					Until link=list._head Or TEntity(link.Value())._order <= entity._order
					list.InsertBeforeLink(entity,link)
				ElseIf entity._order < 0
					Repeat
						link=link._pred
					Until link=list._head Or TEntity(link.Value())._order >= entity._order
					list.InsertAfterLink(entity,link)				
				Else
					If entity.HasAlpha()
						entity._alphaorder = camera.GetDistance(entity)
						Repeat
							link=link._pred
							If link=list._head Then Exit
						Until TEntity(link.Value())._order >= 0 And (TEntity(link.Value())._alphaorder >= entity._alphaorder Or TEntity(link.Value())._alphaorder = 0.0)
						list.InsertAfterLink(entity,link)
					Else
						entity._alphaorder = 0
						Repeat
							link=link._succ
						Until link=list._head Or TEntity(link.Value())._order <= 0
						list.InsertBeforeLink(entity,link)
					EndIf
				EndIf	
			EndIf
		Next
		
		UpdateSprites list,driver,camera
		
		Return RenderEntities(list,driver,camera)		
	End Method

	Method Update(speed#)
		_config.UpdateSpeed = speed#
		RunHooks _config.UpdateHook, _config
		_collisiondriver.Update _config,speed
		For Local mesh:TMesh=EachIn _config.List[WORLDLIST_MESH]
			Local animator:TAnimator=mesh._animator
			If animator=Null Continue
			Local seq:TAnimSeq=animator._current
			If seq
				If animator._mode>0		
					animator._frame:+(speed*animator._speed)
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
	
	Method RenderEntities:TRenderInfo(list:TList,driver:TMaxB3DDriver,camera:TCamera)
		Global info:TRenderInfo=New TRenderInfo
		info.Triangles=0
		info.Entities=0
		If Not list.IsEmpty() info.Entities=list.Count()
		For Local entity:TEntity=EachIn list
			Local mesh:TMesh=TMesh(entity),flat:TFlat=TFlat(entity),terrain:TTerrain=TTerrain(entity)
			Local sprite:TSprite=TSprite(entity),bsp:TBSPModel=TBSPModel(entity)
			Local custom:TCustomEntity=TCustomEntity(entity), renderer:TCustomRenderer
			If custom
				renderer = TCustomRenderer(custom.Renderer(driver.Abbr()))
				If renderer = Null Continue
			EndIf
			Local brush:TBrush=entity._brush
			If brush._a=0 Continue
			driver.BeginEntityRender entity
			If mesh
				For Local surface:TSurface=EachIn mesh._surfaces	
					If surface._brush._a=0 Continue
					Local animation_surface:TSurface,merge_data
					If mesh._animator
						If mesh._animator._current
							animation_surface=mesh._animator.GetSurface(surface)
							merge_data=mesh._animator.GetMergeData()
						EndIf
					EndIf
					Local resource:TSurfaceRes=driver.MergeSurfaceRes(surface,animation_surface,merge_data)
					brush=surface._brush.Merge(mesh._brush)
					driver.SetBrush brush,surface.HasAlpha() Or brush.HasAlpha(),_config
					info.Triangles:+driver.RenderSurface(resource,brush)
				Next
			Else
				driver.SetBrush brush, brush.HasAlpha(),_config
				If flat					
					info.Triangles:+driver.RenderFlat(flat)
				ElseIf sprite				
					driver.RenderSprite(sprite)
					info.Triangles:+4+(4*(brush._fx&FX_NOCULLING<>0))
				ElseIf terrain
					Local x#,y#,z#
					camera.GetPosition x,y,z,True
					terrain.Update x,y,z,camera._frustum.ToPtr()
					info.Triangles:+driver.RenderTerrain(terrain)
				ElseIf bsp
					Local tree:TBSPTree=bsp.GetRenderTree(camera.GetEye())
					info.Triangles:+driver.RenderBSPTree(tree)
				ElseIf custom
					info.Triangles:+renderer.Render(custom, driver)
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
	
	Method SetLighting(driver:TMaxB3DDriver,camera:TCamera)
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
	End Method
End Type

Type TRenderInfo
	Field FPS
	Field Triangles
	Field Entities
End Type

