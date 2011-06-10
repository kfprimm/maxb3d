
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

Rem
# Graphics3D
# Dither
# WBuffer
# AntiAlias
# Wireframe
# HWMultiTex
# AmbientLight
# ClearCollisions
# Collisions
# UpdateWorld
# CaptureWorld
# RenderWorld
# ClearWorld
# LoaderMatrix
# TrisRendered

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

# FreeEntity
# CopyEntity
# EntityColor
# EntityAlpha
# EntityShininess
# EntityTexture
# EntityBlend
# EntityFX
# EntityAutoFade
# PaintEntity
# EntityOrder
# ShowEntity
# HideEntity
# NameEntity
# EntityParent
# GetParent

# EntityX
# EntityY
# EntityZ
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
# GetEntityType

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