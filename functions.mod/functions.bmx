
Strict

Module MaxB3D.Functions
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import MaxB3D.Core

Function RenderWorld(tween#=1.0)
	Return _currentworld.Render(tween)
End Function
Function UpdateWorld()
	Return _currentworld.Update()
End Function
Function SetCollisions(src,dest,methd,response)
	Return _currentworld.SetCollisions(src,dest,methd,response)
End Function
Function GetAmbientLight(red Var,green Var,blue Var)
	Return _currentworld.GetAmbientLight(red,green,blue)
End Function
Function SetAmbientLight(red,green,blue)
	Return _currentworld.SetAmbientLight(red,green,blue)
End Function
Function GetWireFrame()
	Return _currentworld.GetWireFrame()
End Function
Rem
	bbdoc: Enable/disable global wireframe rendering.
	about: @SetWireframe can enable wireframe rendering for the entire scene. Alternatively, calling #SetEntityFX with @FX_WIREFRAME will cause only 
			a single entity's wireframe to be rendered.
End Rem
Function SetWireFrame(enable)
	Return _currentworld.SetWireFrame(enable)
End Function

'Textures
Function CreateTexture:TTexture(width,height,flags=TEXTURE_COLOR|TEXTURE_MIPMAP,frames=1)
	Local texture:TTexture=_currentworld.AddTexture([width,height],flags)
	texture.SetPixmap(CreatePixmap(width,height,PF_RGBA8888))
	Return texture
End Function
Function LoadTexture:TTexture(url:Object,flags=TEXTURE_COLOR|TEXTURE_MIPMAP)
	Return _currentworld.AddTexture(url,flags)
End Function
Function LockTexture:TPixmap(texture:TTexture)
	Return texture.Lock()
End Function
Function UnlockTexture(texture:TTexture)
	Return texture.Unlock()
End Function
Function GetTextureFlags(texture:TTexture)
	Return texture.GetFlags()
End Function
Function SetTextureFlags(texture:TTexture,flags)
	Return texture.SetFlags(flags)
End Function
Function GetTextureBlend(texture:TTexture)
	Return texture.GetBlend()
End Function
Function SetTextureBlend(texture:TTexture,blend)
	Return texture.SetBlend(blend)
End Function
Function GetTextureCoords(texture:TTexture)
	Return texture.GetCoords()
End Function
Function SetTextureCoords(texture:TTexture,coords)
	Return texture.SetCoords(coords)
End Function
Function GetTextureScale(texture:TTexture,x# Var,y# Var)
	Return texture.GetScale(x,y)
End Function
Function SetTextureScale(texture:TTexture,x#,y#)
	Return texture.SetScale(x,y)
End Function

'Brushes
Function CreateBrush:TBrush(url:Object=Null)
	Return _currentworld.AddBrush(url)
End Function
Function GetBrushColor(brush:TBrush,red Var,green Var,blue Var)
	Return brush.GetColor(red,green,blue)
End Function
Function SetBrushColor(brush:TBrush,red,green,blue)
	Return brush.SetColor(red,green,blue)
End Function
Function GetBrushAlpha#(brush:TBrush)
	Return brush.GetAlpha()
End Function
Function SetBrushAlpha(brush:TBrush,alpha#)
	Return brush.SetAlpha(alpha)
End Function
Function GetBrushShine#(brush:TBrush)
	Return brush.GetShine()
End Function
Function SetBrushShine(brush:TBrush,shine#)
	Return brush.SetShine(shine)
End Function
Function GetBrushTexture:TTexture(brush:TBrush,index=0)
	Return brush.GetTexture(index)
End Function
Function SetBrushTexture(brush:TBrush,texture:TTexture,index=0,frame=0)
	Return brush.SetTexture(texture,index,frame)
End Function
Function GetBrushFrame(brush:TBrush,index=0)
	Return brush.GetFrame(index)
End Function
Function SetBrushFrame(brush:TBrush,frame,index=0)
	Return brush.SetFrame(frame,index)
End Function
Function GetBrushFX(brush:TBrush)
	Return brush.GetFX()
End Function
Rem
	bbdoc: Set various rendering effects for a brush.
	about:
End Rem
Function SetBrushFX(brush:TBrush,fx)
	Return brush.SetFX(fx)
End Function

'Entities
Function CopyEntity:TEntity(entity:TEntity,parent:TEntity=Null)
	Return entity.Copy(parent)
End Function
Function FreeEntity(entity:TEntity)
	Return entity.Free()
End Function
Function GetEntityParent:TEntity(entity:TEntity)
	Return entity.GetParent()
End Function
Function SetEntityParent(entity:TEntity,parent:TEntity)
	Return entity.SetParent(parent)
End Function
Function GetEntityVisible(entity:TEntity)
	Return entity.GetVisible()
End Function
Function SetEntityVisible(entity:TEntity,visible)
	Return entity.SetVisible(visible)
End Function
Function GetEntityName$(entity:TEntity)
	Return entity.GetName()
End Function
Function SetEntityName$(entity:TEntity,name$)
	Return entity.SetName(name)
End Function
Function GetEntityBrush:TBrush(entity:TEntity)
	Return entity.GetBrush()
End Function
Function SetEntityBrush(entity:TEntity,brush:TBrush)
	Return entity.SetBrush(brush)
End Function
Function GetEntityColor(entity:TEntity,red Var,green Var,blue Var)
	Return entity.GetColor(red,green,blue)
End Function
Function SetEntityColor(entity:TEntity,red,green,blue)
	Return entity.SetColor(red,green,blue)
End Function
Function GetEntityAlpha#(entity:TEntity)
	Return entity.GetAlpha()
End Function
Function SetEntityAlpha(entity:TEntity,alpha#)
	Return entity.SetAlpha(alpha)
End Function
Function GetEntityShine#(entity:TEntity)
	Return entity.GetShine()
End Function
Function SetEntityShine(entity:TEntity,shine#)
	Return entity.SetShine(shine)
End Function
Function GetEntityTexture:TTexture(entity:TEntity,index=0)
	Return entity.GetTexture(index)
End Function
Function SetEntityTexture(entity:TEntity,texture:TTexture,index=0)
	Return entity.SetTexture(texture,index)
End Function
Function GetEntityFX(entity:TEntity)
	Return entity.GetFX()
End Function
Function SetEntityFX(entity:TEntity,fx)
	Return entity.SetFX(fx)
End Function
Function TurnEntity(entity:TEntity,pitch#,yaw#,roll#,glob=False)
	Return entity.Turn(pitch,yaw,roll,glob)
End Function
Function PointEntity(entity:TEntity,target:Object,roll#=0.0)
	Return entity.Point(target,roll)
End Function
Function MoveEntity(entity:TEntity,x#,y#,z#)
	Return entity.Move(x,y,z)
End Function
Function TranslateEntity(entity:TEntity,x#,y#,z#,glob=True)
	Return entity.Translate(x,y,z,glob)
End Function
Function GetEntityScale(entity:TEntity,x# Var,y# Var,z# Var,glob=False)
	Return entity.GetScale(x,y,z,glob)
End Function
Function SetEntityScale(entity:TEntity,x#,y#,z#,glob=False)
	Return entity.SetScale(x,y,z,glob)
End Function
Function GetEntityRotation(entity:TEntity,pitch# Var,yaw# Var,roll# Var,glob=False)
	Return entity.GetRotation(pitch,yaw,roll,glob)
End Function
Function SetEntityRotation(entity:TEntity,pitch#,yaw#,roll#,glob=False)
	Return entity.SetRotation(pitch,yaw,roll,glob)
End Function
Function GetEntityPosition(entity:TEntity,x# Var,y# Var,z# Var,glob=False)
	Return entity.GetPosition(x,y,z,glob)
End Function
Function SetEntityPosition(entity:TEntity,x#,y#,z#,glob=False)
	Return entity.SetPosition(x,y,z,glob)
End Function
Function GetEntityCollisions:TCollision[](entity:TEntity)
	Return entity.GetCollisions()
End Function
Function GetEntityBox(entity:TEntity,x# Var,y# Var,z# Var,width# Var,height# Var,depth# Var)
	Return entity.GetBox(x,y,z,width,height,depth)
End Function
Function SetEntityBox(entity:TEntity,x#,y#,z#,width#,height#,depth#)
	Return entity.SetBox(x,y,z,width,height,depth)
End Function
Function GetEntityRadius(entity:TEntity,x# Var,y# Var)
	Return entity.GetRadius(x,y)
End Function
Function SetEntityRadius(entity:TEntity,x#,y#=-1)
	Return entity.SetRadius(x,y)
End Function
Function GetEntityType(entity:TEntity)
	Return entity.GetType()
End Function
Function SetEntityType(entity:TEntity,typ,recursive=False)
	Return entity.SetType(typ,recursive)
End Function
Function ResetEntity(entity:TEntity)
	Return entity.Reset()
End Function
Function GetEntityDistance(entity:TEntity,target:Object)
	Return entity.GetDistance(target)
End Function

'Lights
Function CreateLight:TLight(typ=LIGHT_DIRECTIONAL,parent:TEntity=Null)
	Return _currentworld.AddLight(typ,parent)
End Function
Function GetLightRange#(light:TLight)
	Return light.GetRange()
End Function
Function SetLightRange(light:TLight,range#)
	Return light.SetRange(range)
End Function
Function GetLightAngles(light:TLight,inner# Var,outer# Var)
	Return light.GetAngles(inner,outer)
End Function
Function SetLightAngles(light:TLight,inner#,outer#)
	Return light.SetAngles(inner,outer)
End Function

'Cameras
Function CreateCamera:TCamera(parent:TEntity=Null)
	Return _currentworld.AddCamera(parent)
End Function
Function GetCameraMode(camera:TCamera)
	Return camera.GetMode()
End Function
Function SetCameraMode(camera:TCamera,mode)
	Return camera.SetMode(mode)
End Function
Function GetCameraFogMode(camera:TCamera)
	Return camera.GetFogMode()
End Function
Function SetCameraFogMode(camera:TCamera,mode)
	Return camera.SetFogMode(mode)
End Function
Function GetCameraFogColor(camera:TCamera,red Var,green Var,blue Var)
	Return camera.GetFogColor(red,green,blue)
End Function
Function SetCameraFogColor(camera:TCamera,red,green,blue)
	Return camera.SetFogColor(red,green,blue)
End Function
Function GetCameraFogRange(camera:TCamera,near# Var,far# Var)
	Return camera.GetFogRange(near,far)
End Function
Function SetCameraFogRange(camera:TCamera,near#,far#)
	Return camera.SetFogRange(near,far)
End Function
Function GetCameraViewport(camera:TCamera,x Var,y Var,width Var,height Var)
	Return camera.GetViewport(x,y,width,height)
End Function
Function SetCameraViewport(camera:TCamera,x,y,width,height)
	Return camera.SetViewport(x,y,width,height)
End Function
Function GetCameraClsMode(camera:TCamera)
	Return camera.GetClsMode()
End Function
Function SetCameraClsMode(camera:TCamera,mode)
	Return camera.SetClsMode(mode)
End Function
Function GetCameraRange(camera:TCamera,near# Var,far# Var)
	Return camera.GetRange(near,far)
End Function
Function SetCameraRange(camera:TCamera,near#,far#)
	Return camera.SetRange(near,far)
End Function
Function GetCameraZoom#(camera:TCamera)
	Return camera.GetZoom()
End Function
Function SetCameraZoom(camera:TCamera,zoom#)
	Return camera.SetZoom(zoom)
End Function

'Pivots
Function CreatePivot:TPivot(parent:TEntity=Null)
	Return _currentworld.AddPivot(parent)
End Function

'Meshes
Function CreateMesh:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*null*",parent)
End Function
Function LoadMesh:TMesh(url:Object,parent:TEntity=Null)
	Return _currentworld.AddMesh(url,parent)
End Function
Function GetMeshSurface:TSurface(mesh:TMesh,index)
	Return mesh.GetSurface(index)
End Function
Function AddMeshSurface:TSurface(mesh:TMesh,vertexcount=0,trianglecount=0)
	Return mesh.AddSurface(vertexcount,trianglecount)
End Function
Function CloneMesh:TMesh(mesh:TMesh,parent:TEntity=Null)
	Return mesh.Clone(parent)
End Function
Function ScaleMesh(mesh:TMesh,x#,y#,z#)
	Return mesh.Scale(x,y,z)
End Function
Function GetMeshSize(mesh:TMesh,width#,height#,depth#)
	Return mesh.GetSize(width,height,depth)
End Function
Function FitMesh(mesh:TMesh,x#,y#,z#,width#,height#,depth#,uniform=False)
	Return mesh.Fit(x,y,z,width,height,depth,uniform)
End Function
Function FlipMesh(mesh:TMesh)
	Return mesh.Flip()
End Function
Function UpdateMeshNormals(mesh:TMesh)
	Return mesh.UpdateNormals()
End Function

'Planes
Function CreatePlane:TPlane(parent:TEntity=Null)
	Return _currentworld.AddPlane(parent)
End Function

'Surfaces
Function CountSurfaceVertices(surface:TSurface)
	Return surface.CountVertices()
End Function
Function CountSurfaceTriangles(surface:TSurface)
	Return surface.CountTriangles()
End Function
Function UpdateSurfaceNormals(surface:TSurface)
	Return surface.UpdateNormals()
End Function
Function AddSurfaceVertex(surface:TSurface,x#,y#,z#,u#=0.0,v#=0.0)
	Return surface.AddVertex(x,y,z,u,v)
End Function
Function GetSurfaceCoord(surface:TSurface,index,x# Var,y# Var,z# Var)
	Return surface.GetCoord(index,x,y,z)
End Function
Function SetSurfaceCoord(surface:TSurface,index,x#,y#,z#)
	Return surface.SetCoord(index,x,y,z)
End Function
Function GetSurfaceColor(surface:TSurface,index,red Var,green Var,blue Var,alpha# Var)
	Return surface.GetColor(index,red,green,blue,alpha)
End Function
Function SetSurfaceColor(surface:TSurface,index,red,green,blue,alpha#)
	Return surface.SetColor(index,red,green,blue,alpha)
End Function
Function GetSurfaceNormal(surface:TSurface,index,nx# Var,ny# Var,nz# Var)
	Return surface.GetNormal(index,nx,ny,nz)
End Function
Function SetSurfaceNormal(surface:TSurface,index,nx#,ny#,nz#)
	Return surface.SetNormal(index,nx,ny,nz)
End Function
Function AddSurfaceTriangle(surface:TSurface,v0,v1,v2)
	Return surface.AddTriangle(v0,v1,v2)
End Function
Function GetSurfaceTriangle(surface:TSurface,index,v0 Var,v1 Var,v2 Var)
	Return surface.GetTriangle(index,v0,v1,v2)
End Function
Function SetSurfaceTriangle(surface:TSurface,index,v0,v1,v2)
	Return surface.SetTriangle(index,v0,v1,v2)
End Function
Function GetSurfaceBrush:TBrush(surface:TSurface)
	Return surface.GetBrush()
End Function
Function SetSurfaceBrush(surface:TSurface,brush:TBrush)
	Return surface.SetBrush(brush)
End Function