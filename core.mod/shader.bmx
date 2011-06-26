
Strict

Import BRL.Hook
Import MaxB3D.Math
Import "resource.bmx"

Const SHADER_VERTEX   = 1
Const SHADER_PIXEL    = 2
Const SHADER_GEOMETRY = 4

Type TShaderData
	Field _projection:TMatrix
	Field _modelviewproj:TMatrix
End Type

Type TShaderRes Extends TDriverResource
End Type

Type TShaderFrag
	Field _code$,_type
	Field _recompilehook=AllocHookId()
	
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
		RunHooks _recompilehook,Self
	End Method
End Type

Type TShaderCode
	Field _driver$,_frag:TShaderFrag[]
	Field _composition$
	Field _res:TShaderRes,_recompile
	
	Method AddFrag(frag:TShaderFrag)
		AddFrags([frag])
	End Method
	Method AddFrags(frags:TShaderFrag[])
		For Local frag:TShaderFrag=EachIn frags
			AddHook frag._recompilehook,RecompileHook,Self
		Next
		_recompile=True
		_frag:+frags
	End Method
	
	Method GetComposition(vert$ Var,frag$ Var)
		vert="";frag=""
		For Local f:TShaderFrag=EachIn _frag
			Select f._type
			Case SHADER_PIXEL
				frag:+f._code
			Case SHADER_VERTEX
				vert:+f._code
			End Select
		Next		
	End Method
	
	Function RecompileHook:Object(id,data:Object,context:Object)
		TShaderCode(context)._recompile=True
		Return data
	End Function
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
	
	Method Use(shader:TShader,data:TShaderData)
		Local res:TShaderRes
		If shader<>Null
			Local code:TShaderCode=shader.GetCode(Name())
			If code code=Compile(code)
			If code res=code._res
		EndIf
		Apply res,data
		Return True
	End Method
	
	Method Compile:TShaderCode(code:TShaderCode) Abstract
	Method Apply(res:TShaderRes,data:TShaderData) Abstract
	Method Name$() Abstract
End Type