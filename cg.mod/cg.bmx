
Strict

Rem
	bbdoc: NVIDIA Cg shader support for MaxB3D.
End Rem
Module MaxB3D.Cg
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import sys87.CgToolkit

Type TCgRes Extends TShaderRes
	Field _id
End Type

Type TCgShaderDriver Extends TShaderDriver
	Global _first_cg:TCGShaderDriver,_context
	Field _next_cg:TCgShaderDriver
	
	Method New()
		If Not _context _context=cgCreateContext()
		_next_cg=_first_cg
		_first_cg=Self
	End Method
	
	Method Initialize(driver:TGraphicsDriver) Abstract	
	Method Compatible(driver:TGraphicsDriver) Abstract
	
	Method Name$()	
		Return "cg"
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CgShaderDriver:TCgShaderDriver()
	Local driver:TCgShaderDriver=TCgShaderDriver._first_cg
	While driver
		If driver.Compatible(GetGraphicsDriver())
			driver.Initialize(GetGraphicsDriver())
			Return driver
		EndIf
		driver=driver._next_cg
	Wend
End Function