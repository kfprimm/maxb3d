
Strict

Rem
	bbdoc: Netwon Game Dynamics for MaxB3D
End Rem
Module MaxB3D.Newton
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

' Separated to bypass a "feature" that would otherwise result in a linking error...ugh.
Import "driver.bmx" 

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function NewtonCollisionDriver:TNewtonCollisionDriver()
	Global _driver:TNewtonCollisionDriver=New TNewtonCollisionDriver
	Return _driver
End Function
