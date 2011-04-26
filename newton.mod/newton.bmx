
Strict

Module MaxB3D.Newton
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

' Seperated to bypass a "feature" that would otherwise result in a linking error...ugh.
Import "driver.bmx" 

Function NewtonPhysicsDriver:TNewtonPhysicsDriver()
	Global _driver:TNewtonPhysicsDriver=New TNewtonPhysicsDriver
	Return _driver
End Function
