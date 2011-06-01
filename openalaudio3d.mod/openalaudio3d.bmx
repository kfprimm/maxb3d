
Strict

Rem
	bbdoc: OpenAL audio driver for MaxB3D Audio3D.
End Rem
Module MaxB3D.OpenALAudio3D
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Audio3D
Import BRL.OpenALAudio

Type TOpenALAudio3DDriver Extends TAudio3DDriver
	Method Startup()
		'TOpenALAudioDriver
	End Method
	
	Method Name$()
		Return "OpenAL 3D"
	End Method
End Type
New TOpenALAudio3DDriver
