
Strict

Rem
	bbdoc: Autodesk 3DS loader for MaxB3D
End Rem
Module MaxB3D.A3DSLoader

ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "a3dsloader",message
End Function

Public

Const 3DS_MAIN3DS  = $4D4D

Type TMeshLoader3DS Extends TMeshLoader	
	Method Run(mesh:TMesh,stream:TStream,url:Object)	
		If stream=Null Return false
		Return True
	End Method
	
	Method ReadChunk(stream:TStream,length Var)
		Local id=ReadShort(stream)
		Return ReadInt(stream)
	End Method
		
	Method Name$()
		Return "Autodesk 3DS"
	End Method
	Method ModuleName$()
		Return "a3dsloader"
	End Method
End Type
New TMeshLoader3DS
