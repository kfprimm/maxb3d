
Strict

Rem
	bbdoc: Blitz3D style wrapper for MaxB3D
End Rem
Module MaxB3D.Retro
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.GLDriver
Import MaxB3D.D3D9Driver
Import MaxB3D.Primitives

Import MaxB3D.B3DCollision

Import MaxB3D.A3DSLoader
Import MaxB3D.B3DLoader
Import MaxB3D.MD2Loader
Import MaxB3D.XLoader

Import BRL.BMPLoader
Import BRL.JPGLoader
Import BRL.PNGLoader
Import BRL.TGALoader

Private
Global _currentworld:TWorld
Global _renderinfo:TRenderInfo = New TRenderInfo

Public

Function Graphics3D(width, height, depth = 32, mode = 0)
	Select mode
	Case 0
?Debug
		depth = 0  
?Not Debug
		depth = 32
?
	Case 1
		depth = 32
	Case 2
		depth = 0
	End select
	Graphics width,height,depth
End Function
Rem
# Dither
# WBuffer
# AntiAlias
End Rem
Function Wireframe(enable)
	_currentworld.SetWireFrame enable
End Function
'# HWMultiTex
Function AmbientLight(red, green, blue)
	_currentworld.SetAmbientLight red, green, blue
End Function
Rem
# ClearCollisions
# Collisions
End Rem
Function UpdateWorld(speed#)
	_currentworld.Update(speed, speed)
End Function
Function RenderWorld(tween#)
	_renderinfo = _currentworld.Render(tween)
End Function
Rem
# CaptureWorld
# ClearWorld
# LoaderMatrix
End Rem
Function TrisRendered()
	return _renderinfo.triangles
End Function

Rem
# CreateTexture
# LoadTexture
# LoadAnimTexture
# FreeTexture
# TextureBlend
# TextureCoords
# ScaleTexture
# PositionTexture
# RotateTexture
End Rem
Function TextureWidth(texture:TTexture)
	Local width,height
	texture.GetSize width,height
	Return width
End Function
Function TextureHeight(texture:TTexture)
	Local width,height
	texture.GetSize width,height
	Return height
End Function
Rem
# TextureName
# GetBrushTexture
End Rem
Function ClearTextureFilters()
	Return _currentworld.ClearTextureFilters()
End Function
Function TextureFilter(text$, flags)
	Return _currentworld.AddTextureFilter(text, flags)
End Function
Rem
# SetCubeFace
# SetCubeMode
End Rem

Function CreateBrush:TBrush(red=255,green=255,blue=255)
	Return _currentworld.AddBrush([red,green,blue])
End Function
Function CopyBrush:TBrush(brush:TBrush)
	Return brush.Copy()
End Function
Function BrushColor(brush:TBrush,red,green,blue)
	Return brush.SetColor(red,green,blue)
End Function
Function BrushAlpha(brush:TBrush,alpha#)
	Return brush.SetAlpha(alpha)
End Function
Function BrushShininess(brush:TBrush,shine#)
	Return brush.SetShine(shine)
End Function
Function BrushTexture(brush:TBrush,texture:TTexture,index=0,frame=0)
	Return brush.SetTexture(texture,index,frame)
End Function
Function BrushFX(brush:TBrush,fx)
	Return brush.SetFX(fx)
End Function
Function BrushBlend(brush:TBrush,fx)
	Return brush.SetBlend(fx)
End Function

Rem
# LoadBrush
# FreeBrush
# GetEntityBrush
# GetSurfaceBrush

# CreateMesh
# LoadMesh
# LoadAnimMesh
# CreateCube
# CreateSphere
# CreateCylinder
# CreateCone
# CopyMesh
# AddMesh
# FlipMesh
# PaintMesh
# LightMesh
# FitMesh
# ScaleMesh
# RotateMesh
# PositionMesh
# UpdateNormals
# MeshesIntersect
# MeshWidth
# MeshHeight
# MeshDepth
# CountSurfaces
# GetSurface

# CreateSurface
# PaintSurface
# ClearSurface
# FindSurface
# AddVertex
# AddTriangle
# VertexCoords
# VertexNormal
# VertexColor
# VertexTexCoords
# CountVertices
# CountTriangles
# VertexX
# VertexY
# VertexZ
# VertexNX
# VertexNY
# VertexNZ
# VertexRed
# VertexGreen
# VertexBlue
# VertexAlpha
# VertexU
# VertexV
# VertexW
# TriangleVertex

# CreateCamera
# CameraProjMode
# CameraFogMode
# CameraFogRange
# CameraFogColor
# CameraViewport
# CameraClsMode
# CameraClsColor
# CameraRange
# CameraZoom
# CameraPick
# PickedX
# PickedY
# PickedZ
# PickedNX
# PickedNY
# PickedNZ
# PickedTime
# PickedEntity
# PickedSurface
# PickedTriangle
# CameraProject
# ProjectedX
# ProjectedY
# ProjectedZ
# EntityInView

End Rem

Function CreateLight:TLight(typ=LIGHT_DIRECTIONAL,parent:TEntity=Null)
	Return _currentworld.AddLight(typ,parent)
End Function
Function LightRange(light:TLight,range#)
	Return light.SetRange(range)
End Function
Function LightColor(light:TLight,red,green,blue)
	Return light.SetColor(red,green,blue)
End Function
Function LightConeAngles(light:TLight,inner#,outer#)
	Return light.SetAngles(inner,outer)
End Function

Function CreatePivot:TPivot(parent:TEntity=Null)
	Return _currentworld.AddPivot(parent)
End Function

Rem
# CreateSprite
# LoadSprite
# RotateSprite
# ScaleSprite
# HandleSprite
# SpriteViewMode

# LoadMD2
# AnimateMD2
# MD2AnimTime
# MD2AnimLength
# MD2Animating

# LoadBSP
# BSPAmbientLight
# BSPLighting

# CreatePlane

# CreateMirror

# CreateTerrain
# LoadTerrain
# TerrainSize
# TerrainDetail
# TerrainShading
# TerrainHeight
# ModifyTerrain
# TerrainX
# TerrainY
# TerrainZ

# CreateListener
# Load3DSound
# EmitSound

# ScaleEntity
# PositionEntity
# MoveEntity
# TranslateEntity
# RotateEntity
# TurnEntity
# PointEntity
# AlignToVector

# LoadAnimSeq
# SetAnimKey
# AddAnimSeq
# ExtractAnimSeq
# Animate
# SetAnimTime
# AnimSeq
# AnimLength
# AnimTime
# Animating
End Rem

Function FreeEntity(entity:TEntity)
	Return entity.Free()
End Function
Function CopyEntity:TEntity(entity:TEntity, parent:TEntity = Null)
	Return entity.Copy(parent)
End Function
Function EntityColor(entity:TEntity, red, green, blue)
	Return entity.SetColor(red, green, blue)
End Function
Function EntityAlpha(entity:TEntity, alpha#)
	Return entity.SetAlpha(alpha)
End Function
Function EntityShininess(entity:TEntity, shine#)
	Return entity.SetShine(shine)
End Function
Function EntityTexture(entity:TEntity, texture:TTexture, frame = 0, index = 0)
	Return entity.SetTexture(texture, frame, index)
End Function
Function EntityBlend(entity:TEntity, blend)
	Return entity.SetBlend(blend)
End Function
Function EntityFX(entity:TEntity, fx)
	Return entity.SetFX(fx)
End Function
'# EntityAutoFade
Function PaintEntity(entity:TEntity, brush:TBrush)
	Return entity.SetBrush(brush)
End Function
Function EntityOrder(entity:TEntity, order)
	Return entity.SetOrder(order)
End Function
Function HideEntity(entity:TEntity)
	Return entity.SetVisible(False)
End Function
Function ShowEntity(entity:TEntity)
	Return entity.SetVisible(True)
End Function
Function NameEntity(entity:TEntity, name$)
	Return entity.SetName(name)
End Function
Function EntityParent(entity:TEntity, parent:TEntity, glob = True)
	Return entity.SetParent(parent, glob)
End Function
Function GetParent:TEntity(entity:TEntity)
	Return entity.GetParent()
End Function

Function EntityX#(entity:TEntity, glob = False)
	Local x#,y#,z#
	entity.GetPosition x,y,z,glob
	Return x
End Function
Function EntityY#(entity:TEntity, glob = False)
	Local x#,y#,z#
	entity.GetPosition x,y,z,glob
	Return y
End Function
Function EntityZ#(entity:TEntity, glob = False)
	Local x#,y#,z#
	entity.GetPosition x,y,z,glob
	Return z
End Function
Rem
# EntityRoll
# EntityYaw
# EntityPitch
# EntityClass
# EntityName
# CountChildren
# GetChild
# FindChild
# EntityPick
# LinePick
# EntityVisible
# EntityDistance
# DeltaYaw
# DeltaPitch
# TFormPoint
# TFormVector
# TFormNormal
# TFormedX
# TFormedY
# TFormedZ
# GetMatElement

# ResetEntity
# EntityRadius
# EntityBox
# EntityType
# EntityPickMode
# EntityCollided
# CountCollisions
# CollisionX
# CollisionY
# CollisionZ
# CollisionNX
# CollisionNY
# CollisionNZ
# CollisionTime
# CollisionEntity
# CollisionSurface
# CollisionTriangle
End Rem
Function GetEntityType(entity:TEntity)
	Return entity.GetType()
End Function

Rem
# VectorYaw
# VectorPitch

# CountGfxModes3D
# GfxMode3D
# GfxMode3DExists
# GfxDriver3D
# GfxDriverCaps3D
# Windowed3D
# HWTexUnits
End Rem

SetWorld CreateWorld()
