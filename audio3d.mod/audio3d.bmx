
Strict

Rem
	bbdoc: 3D Audio system for MaxB3D
End Rem
Module MaxB3D.Audio3D
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.Audio

Private
Global _listener:TListener=New TListener
Global _audio3ddriver:TAudio3DDriver

Public

Type TAudio3DDriver Extends TAudioDriver
	Field _parent:TAudioDriver
		
	Method Startup()
		If _parent=Null
			Local driver:TAudioDriver=_succ
			While driver
				If driver.Name()=ParentName() Exit
				driver=driver._succ
			Wend
			If driver=Null Return False
			_parent=driver
		EndIf
		If Not _parent.Startup() Return False
		_audio3ddriver=Self
		SetListener _listener._matrix
		Return OnStartup()
	End Method
		
	Method EmitSound(sound:TSound,target:Object)
		TSound3D(sound).Emit(target)
	End Method
		
	Method CreateSound:TSound( sample:TAudioSample,loop_flag )
		Return _parent.CreateSound(sample,loop_flag)
	End Method
	
	Method AllocChannel:TChannel() 
		Return _parent.AllocChannel()
	End Method

	Method LoadSound:TSound( url:Object, flags:Int = 0)
		Return TSound3D.FromSound(_parent.LoadSound(url,flags),Self)
	End Method

	Method Name$()
		Return "Audio3D "+ParentName()
	End Method

	Method OnStartup() Abstract	
	Method SetListener(matrix:TMatrix) Abstract
	Method SetTarget(target:Object,channel:TChannel) Abstract
	Method ParentName$() Abstract
End Type

Type TSound3D Extends TSound
	Field _driver:TAudio3DDriver
	Field _parent:TSound
	
	Function FromSound:TSound3D(sound:TSound,driver:TAudio3DDriver)
		Local sound3d:TSound3D=New TSound3D
		sound3d._parent=sound
		sound3d._driver=driver
		Return sound3d
	End Function
	
	Method Emit(target:Object)
		Local channel:TChannel=_parent.Cue()
		_driver.SetTarget target,channel
		channel.SetPaused False
	End Method
	
	Method Play:TChannel( alloced_channel:TChannel=Null )
		_driver.SetTarget Null,alloced_channel
		Return _parent.Play(alloced_channel)
	End Method
	
	Method Cue:TChannel( alloced_channel:TChannel=Null )
		Return _parent.Cue(alloced_channel)
	End Method
End Type

Type TListener Extends TEntity
	Field _rolloff#,_doppler#,_distance#
	
	Method New()
		Assert _listener=Null, "Only one listener can exist!"
	End Method
	
	Method Copy:TListener(parent:TEntity=Null)
		Return Null
	End Method
		
	Method GetScales(rolloff# Var,doppler# Var,distance# Var)	
		rolloff=_rolloff;doppler=_doppler;distance=_distance
	End Method
	Method SetScales(rolloff#,doppler#,distance#)
		_rolloff=rolloff;_doppler=doppler;_distance=distance
	End Method
	
	Method RefreshMatrix()
		Super.RefreshMatrix()
		If _audio3ddriver _audio3ddriver.SetListener _matrix
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GetListener:TListener()
	Return _listener
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetListener(parent:TEntity,rolloff#=1.0,doppler#=1.0,distance#=1.0)
	_listener.SetParent parent
	_listener.SetScales rolloff,doppler,distance
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GetListenerScales(listener:TListener,rolloff# Var,doppler# Var,distance# Var)
	Return listener.GetScales(rolloff,doppler,distance)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function SetListenerScales(listener:TListener,rolloff#,doppler#,distance#)
	Return listener.SetScales(rolloff,doppler,distance)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function EmitSound(sound:TSound,target:Object)
	Return _audio3ddriver.EmitSound(sound,target)
End Function