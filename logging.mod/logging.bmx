
Strict

Rem
	bbdoc: MaxB3D logging utility
End Rem
Module MaxB3D.Logging
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import BRL.System
Import BRL.StandardIO

' Example function
Private
Function ModuleLog(message$)
	_maxb3d_logger.Write "logging",message
End Function

Public

Type TMaxB3DLogger
	Method Write(id$,message$)
		Print "["+id+"] "+CurrentDate()+"-"+CurrentTime()+": "+message
	End Method
End Type

Global _maxb3d_logger:TMaxB3DLogger=New TMaxB3DLogger
