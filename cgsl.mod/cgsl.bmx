
Strict

Rem
	bbdoc: NVIDIA Cg shader support for MaxB3D.
End Rem
Module MaxB3D.CgSL
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import "driver.bmx"
Import "gl.bmx"
'Import "d3d9.bmx"

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CgSLShaderDriver:TCgShaderDriver()
	Local driver:TCgShaderDriver=TCgShaderDriver._first_cg
	While driver
		If driver.Compatible(GetGraphicsDriver())
			driver.Initialize(GetGraphicsDriver())
			Return driver
		EndIf
		driver=driver._next_cg
	Wend
End Function