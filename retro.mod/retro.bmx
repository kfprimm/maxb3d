
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

Private
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
# TrisRendered
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
# TextureWidth
# TextureHeight
# TextureBuffer
# TextureName
# GetBrushTexture
# ClearTextureFilters
# TextureFilter
# SetCubeFace
# SetCubeMode

# CreateBrush
# LoadBrush
# FreeBrush
# BrushColor
# BrushAlpha
# BrushShininess
# BrushTexture
# BrushBlend
# BrushFX
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

# CreateLight
# LightRange
# LightColor
# LightConeAngles

# CreatePivot

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
