
Strict

Import "resource.bmx"

Const SHADER_VERTEX   = 1
Const SHADER_PIXEL    = 2
Const SHADER_GEOMETRY = 4

Type TShaderRes Extends TDriverResource
End Type

Type TShaderFrag
	Field _code$,_recompile
	Field _type
	
	Function Create:TShaderFrag(code$,typ)
		Local frag:TShaderFrag=New TShaderFrag
		frag.SetCode code
		frag._type=typ
		Return frag
	End Function
	
	Method GetCode$()
		Return _code
	End Method
	Method SetCode(code$)
		_code=code
		_recompile=True
	End Method
End Type

Type TShaderCode
	Field _driver$,_frag:TShaderFrag[]
	Field _res:TShaderRes
	
	Method AddFrag(frag:TShaderFrag)
		AddFrags([frag])
	End Method
	Method AddFrags(frags:TShaderFrag[])
		_frag:+frags
	End Method
End Type

Type TShader
	Field _name$
	Field _meta_key$[],_meta_value$[]
	Field _code:TShaderCode[]	
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
	
	Method GetMetaData$(name$)
		For Local i=0 To _meta_key.length-1
			If _meta_key[i]=name Return _meta_value[i]
		Next
	End Method
	Method SetMetaData$(name$,data$)
		For Local i=0 To _meta_key.length-1
			If _meta_key[i]=name
				_meta_value[i]=data
				Return
			EndIf
		Next
		_meta_key:+[name]
		_meta_value:+[data]
	End Method
	
	Method ImportCode(shader:TShader)
		_code:+shader._code
	End Method
	
	Method AddCode:TShaderCode(driver$="")
		Local code:TShaderCode=GetCode(driver)
		If code<>Null Return code
		code=New TShaderCode
		code._driver=driver
		_code:+[code]
		Return code
	End Method
	Method GetCode:TShaderCode(driver$)
		If _code.length=0 Return Null
		For Local code:TShaderCode=EachIn _code
			If code._driver=driver Return code
		Next
		Local code:TShaderCode=GetCode("")
		If code Return code
		Return Null
	End Method
End Type

Type TShaderDriver
	Global _first:TShaderDriver
	Field _next:TShaderDriver
	
	Method New()
		_next=_first
		_first=Self		
	End Method
	
	Method Use(shader:TShader)
		Local res:TShaderRes
		If shader<>Null
			Local code:TShaderCode=Compile(shader)
			If code res=code._res
		EndIf
		Apply res	
		Return True
	End Method
	
	Method Compile:TShaderCode(shader:TShader) Abstract
	Method Apply(res:TShaderRes) Abstract
	Method Name$() Abstract
End Type