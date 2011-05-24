
Strict

Import "surface.bmx"
Import "bone.bmx"

Const ANIMATION_STOP     = 0
Const ANIMATION_LOOP     = 1
Const ANIMATION_PINGPONG = 2
Const ANIMATION_SINGLE   = 3 

Type TAnimSeq
	Field _start,_end
	
	Method GetLength()
		Return _end-_start
	End Method
End Type

Type TAnimator
	Field _frame#,_lastframe#,_speed#=1.0,_mode
	Field _seq:TAnimSeq[],_current:TAnimSeq=New TAnimSeq

	Method GetSurface:TSurface(surface:TSurface) Abstract
	Method GetMergeData() Abstract
	Method Update() Abstract
	Method GetFrameCount() Abstract
	
	Method InterpolateSurfaces:TSurface(surface0:TSurface,surface1:TSurface,diff#,output:TSurface)
		For Local v=0 To output._vertexcnt-1
			Local x1#,y1#,z1#,x2#,y2#,z2#
			surface0.GetCoord v,x1,y1,z1
			surface1.GetCoord v,x2,y2,z2
			output.SetCoord v,x1+(x2-x1)*diff,y1+(y2-y1)*diff,z1+(z2-z1)*diff			
		Next
		Return output
	End Method
End Type

Type TBonedAnimator Extends TAnimator
	Field _bones:TBone[]
End Type

Type TFrameAnimator Extends TAnimator
	Field _frames:TSurface[]
	Field _inter_frame:TSurface,_anim_frame:TSurface
	
	Method GetSurface:TSurface(surface:TSurface)
		Return _anim_frame
	End Method
	
	Method GetMergeData()
		Return SURFACE_POS|SURFACE_NML
	End Method
	
	Method Update()	
		If Int(_frame)-_frame=0 _anim_frame=_frames[_frame]
		
		Local frame0=Int(Floor(_frame)),frame1=Int(Ceil(_frame))
		If frame1>_current._end-1 frame1=_current._start	
		
		If _inter_frame=Null _inter_frame=_frames[0].Copy()
		
		_anim_frame=InterpolateSurfaces(_frames[frame0],_frames[frame1],_frame-Floor(_frame),_inter_frame)
		_lastframe=_frame
	End Method
	
	Method AddFrame(surface:TSurface)
		_frames=_frames[.._frames.length+1]
		_frames[_frames.length-1]=surface
	End Method
	
	Method GetFrameCount()
		Return _frames.length
	End Method
End Type