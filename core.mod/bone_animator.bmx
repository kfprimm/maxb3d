
Strict

Import "bone.bmx"

Type TBoneAnimator Extends TAnimator
	Field _root:TBone
	Field _bone:TBone[]
	Field _key:TAnimKey[][]
	
	Method AddBone(bone:TBone,keys:TAnimKey[])
		_bone:+[bone];_key:+[keys]		
		If _root=Null _root=bone
	End Method
	
	Method GetSurface:TSurface(surface:TSurface)
	End Method
	Method GetMergeData()
	End Method
	Method Update()
		For Local i=0 To _bone.length-1
			Local frame0,frame1
			For Local j=0 To _key[i].length-1
				If _key[i][j]._frame-_frame=0
					frame0=j
					frame1=j
					Exit
				EndIf
				If _key[i][j]._frame<_frame frame0=j
				If _key[i][j]._frame>_frame
					frame1=j
					Exit
				EndIf
			Next
			
			Local key0:TAnimKey=_key[i][frame0]
			Local key1:TAnimKey=_key[i][frame1]
						
			Local key:TBoneKey=New TBoneKey
			If key0=key1
				key=TBoneKey(key0._object)
			Else
				Local t#=key0._frame+(key1._frame-key0._frame)*(_frame-key0._frame)
				
				key=TBoneKey(key0._object)
			EndIf
			
			Local x#,y#,z#,w#=1
			
			_bone[i].GetPosition x,y,z
			
			x:+key._px;y:+key._py;z:+key._pz
			TQuaternion.Matrix(key._rw,key._rx,key._ry,key._rz).TransformVec4 x,y,z,w
			
			
			_bone[i].SetPosition x,y,z
		Next
	End Method
	Method GetFrameCount()
	End Method
	
	Method SetKey(frame,key:Object)
		_root.SetAnimKey frame,key
	End Method
End Type
