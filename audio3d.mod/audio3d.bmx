
Strict

Module MaxB3D.Audio3D
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.Audio

Private
Global _listener:TListener=New TListener

Public

Type TAudio3DDriver Extends TAudioDriver
	Field _parent:TAudioDriver
	
	Method CreateSound:TSound( sample:TAudioSample,loop_flag )
		Return _parent.CreateSound(sample,loop_flag)
	End Method
	
	Method AllocChannel:TChannel() 
		Return _parent.AllocChannel()
	End Method

	Method LoadSound:TSound( url:Object, flags:Int = 0)
		Return _parent.LoadSound(url,flags)
	End Method
End Type

Type TListener Extends TEntity
	Field _rolloff#,_doppler#,_distance#
	
	Method Copy:TListener(parent:TEntity=Null)
		Return Null
	End Method
	
	Method GetScales(rolloff# Var,doppler# Var,distance# Var)	
		rolloff=_rolloff;doppler=_doppler;distance=_distance
	End Method
	Method SetScales(rolloff#,doppler#,distance#)
		_rolloff=rolloff;_doppler=doppler;_distance=distance
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
End function