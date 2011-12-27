
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
	TMaxB3DLogger.Write "logging",message
End Function

Public

Type TMaxB3DLogger
	Global _stream:TStream
	
	Function SetStream(stream:TStream)
		_stream=stream
	End Function
	
	Function Write(id$,message$)
		_stream.WriteLine "["+id+"] "+CurrentDate()+"-"+CurrentTime()+": "+message
		_stream.Flush
	End Function
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetLoggingStream(stream:TStream)
	Return TMaxB3DLogger.SetStream(stream)
End Function

SetLoggingStream StandardIOStream
