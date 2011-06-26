
Strict

Rem
	bbdoc: GLSL shader driver for MaxB3D
End Rem
Module MaxB3D.GLSL
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import PUB.OpenGL
Import PUB.GLew

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "glsl",message
End Function

Public

Type TGLSLRes Extends TShaderRes
	Field _prog,_vert,_frag
End Type

Type TGLSLDriver Extends TShaderDriver
	Method Compile:TShaderCode(code:TShaderCode)		
		Local res:TGLSLRes=TGLSLRes(code._res)
		If Not code._recompile And res<>Null Return code
		
		If res=Null
			res=New TGLSLRes
			res._prog=glCreateProgram()
		EndIf
		
		Local vert_comp$,frag_comp$
		code.GetComposition vert_comp,frag_comp
		
		Local vs_error$=MakeShader(res._vert,res._prog,GL_VERTEX_SHADER,vert_comp)		
		Local fs_error$=MakeShader(res._frag,res._prog,GL_FRAGMENT_SHADER,frag_comp)
		
		code._recompile=False
		
		If vs_error Or fs_error
			ModuleLog "Error occurred while compiling shader."
			code._res=Null
			Return Null
		Else
			glLinkProgram res._prog
			code._res=res	
			Return code
		EndIf
	End Method
	
	Method MakeShader$(id Var,prog,typ,src$)
		If src="" Return 
		
		If id=0
			id=glCreateShader(typ)
			glAttachShader prog,id
		EndIf
		
		Local str:Byte Ptr=src.ToCString()
		glShaderSource id,1,Varptr str,Null
		MemFree str
		
		glCompileShader id
		Return GetError(id)
	End Method
	
	Method GetError$(shader)
		Local status
		glGetShaderiv shader,GL_COMPILE_STATUS,Varptr status
		If status<>GL_TRUE
			Local max_size
			glGetShaderiv shader,GL_INFO_LOG_LENGTH,Varptr max_size
			Local str:Byte[max_size],size
			glGetShaderInfoLog shader,max_size,Varptr size,str
			'ModuleLog "Fragment compilation error from ~q"+shader.GetName()+"~q."
			Return String.FromCString(str)
		EndIf
	End Method
		
	Method Apply(res:TShaderRes,data:TShaderData)
		Local id
		If res<>Null id=TGLSLRes(res)._prog
		glUseProgram id
	End Method
	
	Method Name$()
		Return "glsl"
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GLSLShaderDriver:TGLSLDriver()
	Global _driver:TGLSLDriver=New TGLSLDriver
	Return _driver
End Function
