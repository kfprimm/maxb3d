
Strict

Rem
	bbdoc: MaxB3D core system.
End Rem
Module MaxB3D.Core
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Mostly derived from the MiniB3D source."
ModuleInfo "Credit: Terrain system adapted from Warner's engine."

Import BRL.Max2D

Import MaxB3D.Logging
Import "driver.bmx"
Import "world.bmx"

Private
Function _maxb3d_world_initialize:Object(id,data:Object,context:Object)
	If GetWorld()=Null SetWorld CreateWorld()
End Function
AddHook _creategraphicshook,_maxb3d_world_initialize

Public

Global _currentworld:TWorld

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateWorld:TWorld()
	Return New TWorld
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GetWorld:TWorld()
	Return _currentworld
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
Function DoMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).DoMax2D()
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function EndMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).EndMax2D()
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function TextureBuffer:TBuffer(texture:TTexture,frame=0)
	Return TMaxB3DDriver(GetGraphicsDriver()).TextureBuffer(texture,frame)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function MeshLoaders$[]()
	Return TMeshLoader.List()
End Function
