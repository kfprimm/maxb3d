
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
	Field _id
End Type

Type TGLSLDriver Extends TShaderDriver
	Method Compile:TShaderCode(code:TShaderCode)		
		Local prog_res:TGLSLRes=TGLSLRes(code._res)
		If prog_res=Null
			prog_res=New TGLSLRes
			prog_res._id=glCreateProgram()
		EndIf
		
		For Local frag:TShaderFrag=EachIn code._frag
			Local res:TGLSLRes=TGLSLRes(code._res)
			If res=Null res=New TGLSLRes
			If frag._recompile
				If Not res._id
					Local typ=GL_VERTEX_SHADER
					If frag._type=SHADER_PIXEL typ=GL_FRAGMENT_SHADER
					res._id=glCreateShader(typ)
					glAttachShader prog_res._id,res._id
				EndIf
				Local str:Byte Ptr=frag.GetCode().ToCString()
				glShaderSource res._id,1,Varptr str,Null
				MemFree str
				
				glCompileShader res._id
				
				Local status
				glGetShaderiv(res._id,GL_COMPILE_STATUS,Varptr status)
				If status<>GL_TRUE
					Local max_size
					glGetShaderiv res._id,GL_INFO_LOG_LENGTH,Varptr max_size
					Local str:Byte[max_size],size
					glGetShaderInfoLog res._id,max_size,Varptr size,str
					'ModuleLog "Fragment compilation error from ~q"+shader.GetName()+"~q."
					'ModuleLog String.FromCString(str)
				EndIf
			EndIf			
			frag._recompile=False
		Next		
		
		glLinkProgram prog_res._id
		code._res=prog_res		
		Return code
	End Method
	
	Method Apply(res:TShaderRes)
		Local id
		If res<>Null id=TGLSLRes(res)._id
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
