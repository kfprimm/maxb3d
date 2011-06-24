
Strict

Rem
	bbdoc: OpenGL Cg support for MaxB3D.
End Rem
Module MaxB3D.CgGL
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Cg
Import BRL.GLGraphics

Type TCgRes Extends TShaderRes
	Field _id
End Type

Type TCgGLShaderDriver Extends TCgShaderDriver
	Field _vert_profile,_frag_profile
	
	Method Initialize(driver:TGraphicsDriver)
		_vert_profile = cgGLGetLatestProfile(CG_GL_VERTEX)
		_frag_profile =	cgGLGetLatestProfile(CG_GL_FRAGMENT)
	  If _vert_profile=CG_PROFILE_UNKNOWN Or _frag_profile Return False
		cgGLSetOptimalOptions _vert_profile
		cgGLSetOptimalOptions _frag_profile
	End Method	
	
	Method Compatible(driver:TGraphicsDriver)
		Local d:TMaxB3DDriver=TMaxB3DDriver(driver)
		If d=Null Return False
		'Return TGLGraphicsDriver(d._parent)=True
	End Method
	
	Method Compile:TShaderCode(code:TShaderCode)
		Local progs[]
		For Local frag:TShaderFrag=EachIn code._frag
'			Local res:TCgRes=TCgRes(frag._res)
'			If res=Null res=New TCgRes
'			If res._id=0 Or frag._recompile
'				Local str:Byte Ptr=frag._code.ToCString()
'				res._id=cgCreateProgram(_context,CG_SOURCE,str,_prfile
'			EndIf
		Next
		Return code
	End Method
	
	Method Apply(res:TShaderRes)
	End Method	
End Type
New TCgGLShaderDriver
