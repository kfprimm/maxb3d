
Strict

Import MaxB3D.Core
Import sys87.CgToolkit

Type TCgRes Extends TShaderRes
	Field _id
End Type

Type TCgShaderDriver Extends TShaderDriver
	Global _first_cg:TCGShaderDriver,_context
	Field _next_cg:TCgShaderDriver
	Field _vert_profile,_frag_profile
	
	Method New()
		If Not _context _context=cgCreateContext()
		_next_cg=_first_cg
		_first_cg=Self
	End Method
	
	Method Initialize(driver:TGraphicsDriver) Abstract	
	Method Compatible(driver:TGraphicsDriver) Abstract
	
	Method Name$()	
		Return "cgsl"
	End Method
End Type
