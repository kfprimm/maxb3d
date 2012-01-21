
Strict

Import "entity.bmx"
Import "animation.bmx"

Type TAnimEntity Extends TEntity
	Field _animator:TAnimator
	Field _animseq:TAnimSeq[]
	
	Method CopyData:TEntity(entity:TEntity)
		Local anim:TAnimEntity = TAnimEntity(entity)
		
		_animator = anim._animator
		_animseq = anim._animseq[..]
		
		Return Super.CopyData(entity)
	End Method
	
	Method SetAnim(seq:TAnimSeq,mode=ANIMATION_LOOP,speed#=1.0)
		_animator._current=seq
		_animator._mode=mode
		_animator._speed=speed
		If seq _animator._frame=seq._start
	End Method
	
	Method AddAnimSeq:TAnimSeq(start_frame,end_frame)
		Local seq:TAnimSeq=New TAnimSeq
		seq._start=start_frame
		seq._end=end_frame
		_animseq=_animseq[.._animseq.length+1]
		_animseq[_animseq.length-1]=seq
		Return seq
	End Method
	
	Method ExtractAnimSeq:TAnimSeq(start_frame,end_frame)
		Local seq:TAnimSeq=New TAnimSeq
		seq._start=start_frame
		seq._end=end_frame
		Return seq
	End Method
	
	Method GetAnimSeq:TAnimSeq()
		Return _animator._current
	End Method
	Method SetAnimSeq(seq:TAnimSeq)
		_animator._current=seq
	End Method
	
	Method GetAnimMode()
		Return _animator._mode
	End Method
	Method SetAnimMode(mode)
		_animator._mode=mode
	End Method
	
	Method GetAnimSpeed#()
		Return _animator._speed
	End Method
	Method SetAnimSpeed(speed#)
		_animator._speed=speed
	End Method

'	Method CapAnimKey(frame)
		
'	End Method
	
	Method SetAnimKey(frame,key:Object)
		_animator.SetKey(frame,key)
	End Method
	
	Method GetFrame#()
		Return _animator._frame
	End Method
End Type
