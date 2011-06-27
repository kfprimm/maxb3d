
Strict

Rem
	bbdoc: OpenAL audio driver for MaxB3D Audio3D.
End Rem
Module MaxB3D.OpenALAudio3D
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Audio3D
Import BRL.OpenALAudio

Import BRL.Reflection ' Ugh...required for hack.

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "openalaudio3d",message
End Function

Public

Type TOpenALAudio3DDriver Extends TAudio3DDriver
	Field _parentname$
	
	Method OnStartup()
		Return True
	End Method
	
	Method SetListener(matrix:TMatrix)	
  	Local x#,y#,z#,dx#,dy#,dz#=1.0
		matrix.GetPosition x,y,z
		matrix.TransformVec3 dx,dy,dz
		
		dx:-x;dy:-y;dz:-z
		
		alListenerfv AL_POSITION,[x,y,z]
		alListenerfv AL_VELOCITY,[0.0,0.0,0.0]
		alListenerfv AL_ORIENTATION,[dx,dy,dz,0.0,1.0,0.0]
	End Method

	Method SetTarget(target:Object,channel:TChannel)
		Local source=TTypeId.ForName("TOpenALSource").FindField("_id").GetInt(TOpenALChannel(channel)._source) ' Ugh...hack.
		If target
			Local x#,y#,z#
			TEntity.GetTargetPosition target,x,y,z
			
			alDistanceModel AL_INVERSE_DISTANCE_CLAMPED
			alSourcefv source,AL_POSITION,[x,y,z]			
			alSourcei source,AL_SOURCE_RELATIVE,False
			alSourcef source,AL_MIN_GAIN,0.0
			alSourcef source,AL_MAX_GAIN,100.0
		Else
			alDistanceModel AL_NONE
		EndIf
	End Method
	
	Method ParentName$()
		Return _parentname
	End Method
End Type

If OpenALInstalled()
	EnableOpenALAudio
	For Local name$=EachIn AudioDrivers()
		If name[..6]="OpenAL" 
			Local driver:TOpenALAudio3DDriver=New TOpenALAudio3DDriver
			driver._parentname=name
		EndIf 
	Next
Else
	ModuleLog "OpenAL not installed on system. No AL drivers available."
EndIf
