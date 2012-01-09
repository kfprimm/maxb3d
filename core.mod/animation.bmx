
Strict

Import "surface.bmx"

Const ANIMATION_STOP     = 0
Const ANIMATION_LOOP     = 1
Const ANIMATION_PINGPONG = 2
Const ANIMATION_SINGLE   = 3 

Type TAnimKey
	Field _frame
	Field _object:Object
End Type

Type TAnimSeq
	Field _start,_end,_name$
	
	Function Create:TAnimSeq(first,last,name$="")
		Local seq:TAnimSeq=New TAnimSeq
		seq._start=first
		seq._end=last
		seq._name=name
		Return seq
	End Function
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
	
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
	Method SetKey(frame,key:Object) Abstract
End Type
