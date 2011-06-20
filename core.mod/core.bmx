
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
Import "driver.bmx"
Import "world.bmx"

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
Function BeginMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).BeginMax2D()
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function EndMax2D()
	Return TMaxB3DDriver(GetGraphicsDriver()).EndMax2D()
End Function

Function _maxb3d_world_initialize:Object(id,data:Object,context:Object)
	If GetWorld()=Null SetWorld CreateWorld()
End Function
AddHook _creategraphicshook,_maxb3d_world_initialize