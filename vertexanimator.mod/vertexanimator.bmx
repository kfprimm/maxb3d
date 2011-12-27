
Strict

Rem
  bbdoc: Vertex animator for MaxB3D meshes
End Rem
Module MaxB3D.VertexAnimator
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Type TVertexAnimator Extends TAnimator
	Field _frames:TAnimKey[]
	Field _inter_frame:TSurface,_anim_frame:TSurface
	
	Method GetSurface:TSurface(surface:TSurface)
		Return _anim_frame
	End Method
	
	Method GetMergeData()
		Return SURFACE_POS|SURFACE_NML
	End Method
	
	Method Update()	
		If Int(_frame)-_frame=0 _anim_frame=TSurface(FindKey(_frame)._object)
		
		Local frame0=Int(Floor(_frame)),frame1=Int(Ceil(_frame))
		If frame1>_current._end-1 frame1=_current._start	
		
		If _inter_frame=Null _inter_frame=TSurface(_frames[0]._object).Copy()
		
		_anim_frame=InterpolateSurfaces(TSurface(FindKey(frame0)._object),TSurface(FindKey(frame1)._object),_frame-Floor(_frame),_inter_frame)
		_lastframe=_frame
	End Method
		
	Method GetFrameCount()
		Return _frames.length
	End Method
	
	Method AddKey(frame,key:Object)
		_frames=_frames[.._frames.length+1]
		_frames[_frames.length-1]=New TAnimKey
		_frames[_frames.length-1]._frame=frame
		_frames[_frames.length-1]._object=key
	End Method
	
	Method SetKey(frame,key:Object)
		For Local k:TAnimKey=EachIn _frames
			If k._frame=frame k._object=key;Return
		Next
		AddKey frame,key
	End Method
	
	Method FindKey:TAnimKey(frame)
		Local key:TAnimKey,curr_frame
		For Local k:TAnimKey=EachIn _frames
			If k._frame=frame Return k
			If key=Null key=k;Continue
			If k._frame<frame And k._frame>key._frame key=k
		Next
		Return key
	End Method
End Type
