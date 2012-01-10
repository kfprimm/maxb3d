
Strict

Module MaxB3D.StringFunctionLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Type TStringFunctionMeshLoader Extends TMeshLoader
	Method Run(config:TWorldConfig,mesh:TMesh,stream:TStream,url:Object)
		Local str$=String(url)
		If str<>""
			Local params$[]=str[str.Find("(")+1..str.FindLast(")")].Split(",")
		
			Local name$ = str[str.Find("//")+2..]
			If str.Find("(") > -1 name = name[..name.Find("(")]
			Return RunFunction(name,params,config,mesh)
		Else
			Return False
		EndIf
	End Method
	
	Method RunFunction(func$,params$[],config:TWorldConfig,mesh:TMesh) Abstract
End Type
