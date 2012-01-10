
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

Import "driver.bmx"
Import "world.bmx"

Private
Global _currentworld:TWorld

Public

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateWorld:TWorld()
	Return New TWorld
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CurrentWorld:TWorld()
	Return _currentworld
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetWorld(world:TWorld)
	_currentworld=world
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
