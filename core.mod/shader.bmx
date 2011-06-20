
Strict

Import "resource.bmx"

Const SHADER_VERTEX   = 1
Const SHADER_PIXEL    = 2
Const SHADER_GEOMETRY = 3

Type TShader
	Field _code$,_recompile
	Field _type
	Field _res:TShaderRes
	
	Method GetCode$()
		Return _code
	End Method
	Method SetCode(text$)
		_code=text
		_recompile=True
	End Method
End Type

Type TShaderRes Extends TDriverResource
	
End Type