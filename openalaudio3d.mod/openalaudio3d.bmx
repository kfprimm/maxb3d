
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

Type TOpenALAudio3DDriver Extends TAudio3DDriver
	Method OnStartup()
		Return True
	End Method
	
	Method SetListener(matrix:TMatrix)	
  	Local x#,y#,z#,dx#,dy#,dz#=1.0,dw#=1.0
		matrix.GetPosition x,y,z
		matrix.TransformVector dx,dy,dz,dw
		
		alListenerfv AL_POSITION,[x,y,z]
		alListenerfv AL_VELOCITY,[0.0,0.0,0.0]
		alListenerfv AL_ORIENTATION,[dx,dy,dz,0.0,1.0,0.0]
		
		DebugLog "eeded"
	End Method

	Method SetTarget(target:Object,channel:TChannel)
		Local source=TTypeId.ForName("TOpenALSource").FindField("_id").GetInt(TOpenALChannel(channel)._source) ' Ugh...hack.
		If target
			Local x#,y#,z#
			TEntity.GetTargetPosition target,x,y,z
			
			alDistanceModel AL_INVERSE_DISTANCE_CLAMPED
			alSourcefv source,AL_POSITION, [x,y,z]			
		Else
			alDistanceModel AL_NONE
		EndIf
	End Method
	
	Method ParentName$()
		Return "OpenAL"
	End Method
End Type
New TOpenALAudio3DDriver
