
Strict

Import "surface.bmx"
Import "bone.bmx"

Type TAnimator
	Field _frame#
	
	Method GetSurface:TSurface(surface:TSurface) Abstract
	Method GetMergeData() Abstract
	Method Update() Abstract
	Method GetFrameCount() Abstract
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
		
		If _inter_frame=Null _inter_frame=_frames[0].Copy()

		Local start_frame:TSurface=_frames[Int(Floor(_frame))]
		Local end_frame:TSurface=_frames[Int(Ceil(_frame))]
		Local diff#=Ceil(_frame)-Floor(_frame)

		For Local v=0 To _inter_frame._vertexcnt-1
			Local x1#,y1#,z1#,x2#,y2#,z2#
			start_frame.GetCoord v,x1,y1,z1
			end_frame.GetCoord v,x2,y2,z2
			_inter_frame.SetCoord v,(x2-x1)*diff,(y2-y1)*diff,(z2-z1)*diff			
		Next
		_anim_frame=_inter_frame
	End Method
	
	Method AddFrame(surface:TSurface)
		_frames=_frames[.._frames.length+1]
		_frames[_frames.length-1]=surface
	End Method
	
	Method GetFrameCount()
		Return _frames.length
	End Method
End Type