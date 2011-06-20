
Strict

Import BRL.Math

Type TMatrix
	Field _m#[4,4]
	
	Method ToString$()
		Return "["+_m[0,0]+","+_m[1,0]+","+_m[2,0]+","+_m[3,0]+"]~n["+_m[0,1]+","+_m[1,1]+","+_m[2,1]+","+_m[3,1]+"]~n["+_m[0,2]+","+_m[1,2]+","+_m[2,2]+","+_m[3,2]+"]~n["+_m[0,3]+","+_m[1,3]+","+_m[2,3]+","+_m[3,3]+"]"
	End Method
	
	Method Copy:TMatrix()
		Local matrix:TMatrix=New TMatrix
		matrix.Overwrite(Self)
		Return matrix
	End Method
	
	Function Identity:TMatrix()
		Local matrix:TMatrix=New TMatrix
		matrix._m[0,0]=1.0;matrix._m[1,1]=1.0;matrix._m[2,2]=1.0;matrix._m[3,3]=1.0
		Return matrix
	End Function
	
	Function PerspectiveFovRH:TMatrix(fovy#,aspect#,near#,far#)		
		Local sine#,cot#,dz#
		Local radians#=(fovy/2.0)
		dz=far-near
		sine=Sin(radians)
		If dz=0 Or sine=0 Or aspect=0 Return
		cot=Cos(radians)/sine
		Local matrix:TMatrix=New TMatrix
		matrix._m[0,0]=cot/aspect
		matrix._m[1,1]=cot
		matrix._m[2,2]=-(far+near)/dz
		matrix._m[2,3]=-1
		matrix._m[3,2]=-2*near*far/dz
		matrix._m[3,3]=0
		Return matrix
	End Function
	
	Function PerspectiveFovLH:TMatrix(fovy#,aspect#,near#,far#)		
		Local yscale#=1.0/Tan(fovy/2.0)
		Local xscale#=yscale/aspect
		Local matrix:TMatrix=New TMatrix
		matrix._m[0,0]=xscale
		matrix._m[1,1]=yscale
		matrix._m[2,2]=far/(far-near)
		matrix._m[2,3]=near*far/(far-near)
		matrix._m[3,2]=-1
		matrix._m[3,3]=0
		Return matrix
	End Function
		
	Function Translation:TMatrix(x#,y#,z#)
		Local matrix:TMatrix=Identity()
		matrix._m[3,0]=x;matrix._m[3,1]=y;matrix._m[3,2]=z
		Return matrix
	End Function
	
	Function Scale:TMatrix(x#,y#,z#)
		Local matrix:TMatrix=Identity()
		matrix._m[0,0]=x;matrix._m[1,1]=y;matrix._m[2,2]=z
		Return matrix
	End Function
	
	Function Pitch:TMatrix(angle#)
		Local matrix:TMatrix=Identity()
		matrix._m[1,1]=Cos(angle)
		matrix._m[2,1]=Sin(angle)
		matrix._m[1,2]=-Sin(angle)
		matrix._m[2,2]=Cos(angle)
		Return matrix
	End Function
	
	Function Yaw:TMatrix(angle#)
		Local matrix:TMatrix=Identity()
		matrix._m[0,0]=Cos(angle)
		matrix._m[2,0]=Sin(angle)
		matrix._m[0,2]=-Sin(angle)
		matrix._m[2,2]=Cos(angle)
		Return matrix
	End Function
	
	Function Roll:TMatrix(angle#)
		Local matrix:TMatrix=Identity()
		matrix._m[0,0]=Cos(angle)
		matrix._m[0,1]=-Sin(angle)
		matrix._m[1,0]=Sin(angle)
		matrix._m[1,1]=Cos(angle)
		Return matrix
	End Function
	
	Function YawPitchRoll:TMatrix(yaw#,pitch#,roll#)
		'Return TMatrix.Yaw(yaw).Multiply(TMatrix.Pitch(pitch).Multiply(TMatrix.Roll(roll)))
		Return TMatrix.Roll(roll).Multiply(TMatrix.Pitch(pitch).Multiply(TMatrix.Yaw(yaw)))
	End Function
	
	Method Multiply:TMatrix(matrix:TMatrix)
		Local result:TMatrix=Identity()
		result._m[0,0] = _m[0,0] * matrix._m[0,0] + _m[0,1] * matrix._m[1,0] + _m[0,2] * matrix._m[2,0] + _m[0,3] * matrix._m[3,0]
		result._m[0,1] = _m[0,0] * matrix._m[0,1] + _m[0,1] * matrix._m[1,1] + _m[0,2] * matrix._m[2,1] + _m[0,3] * matrix._m[3,1]
		result._m[0,2] = _m[0,0] * matrix._m[0,2] + _m[0,1] * matrix._m[1,2] + _m[0,2] * matrix._m[2,2] + _m[0,3] * matrix._m[3,2]
		result._m[0,3] = _m[0,0] * matrix._m[0,3] + _m[0,1] * matrix._m[1,3] + _m[0,2] * matrix._m[2,3] + _m[0,3] * matrix._m[3,3]
		result._m[1,0] = _m[1,0] * matrix._m[0,0] + _m[1,1] * matrix._m[1,0] + _m[1,2] * matrix._m[2,0] + _m[1,3] * matrix._m[3,0]
		result._m[1,1] = _m[1,0] * matrix._m[0,1] + _m[1,1] * matrix._m[1,1] + _m[1,2] * matrix._m[2,1] + _m[1,3] * matrix._m[3,1]
		result._m[1,2] = _m[1,0] * matrix._m[0,2] + _m[1,1] * matrix._m[1,2] + _m[1,2] * matrix._m[2,2] + _m[1,3] * matrix._m[3,2]
		result._m[1,3] = _m[1,0] * matrix._m[0,3] + _m[1,1] * matrix._m[1,3] + _m[1,2] * matrix._m[2,3] + _m[1,3] * matrix._m[3,3]
		result._m[2,0] = _m[2,0] * matrix._m[0,0] + _m[2,1] * matrix._m[1,0] + _m[2,2] * matrix._m[2,0] + _m[2,3] * matrix._m[3,0]
		result._m[2,1] = _m[2,0] * matrix._m[0,1] + _m[2,1] * matrix._m[1,1] + _m[2,2] * matrix._m[2,1] + _m[2,3] * matrix._m[3,1]
		result._m[2,2] = _m[2,0] * matrix._m[0,2] + _m[2,1] * matrix._m[1,2] + _m[2,2] * matrix._m[2,2] + _m[2,3] * matrix._m[3,2]
		result._m[2,3] = _m[2,0] * matrix._m[0,3] + _m[2,1] * matrix._m[1,3] + _m[2,2] * matrix._m[2,3] + _m[2,3] * matrix._m[3,3]
		result._m[3,0] = _m[3,0] * matrix._m[0,0] + _m[3,1] * matrix._m[1,0] + _m[3,2] * matrix._m[2,0] + _m[3,3] * matrix._m[3,0]
		result._m[3,1] = _m[3,0] * matrix._m[0,1] + _m[3,1] * matrix._m[1,1] + _m[3,2] * matrix._m[2,1] + _m[3,3] * matrix._m[3,1]
		result._m[3,2] = _m[3,0] * matrix._m[0,2] + _m[3,1] * matrix._m[1,2] + _m[3,2] * matrix._m[2,2] + _m[3,3] * matrix._m[3,2]
		result._m[3,3] = _m[3,0] * matrix._m[0,3] + _m[3,1] * matrix._m[1,3] + _m[3,2] * matrix._m[2,3] + _m[3,3] * matrix._m[3,3]
		Return result
	End Method
	
	Method Inverse:TMatrix()
		Local matrix:TMatrix=New TMatrix
	
		Local tx#=0
		Local ty#=0
		Local tz#=0
	
	  	matrix._m[0,0] = _m[0,0]
	  	matrix._m[1,0] = _m[0,1]
	  	matrix._m[2,0] = _m[0,2]

		matrix._m[0,1] = _m[1,0]
		matrix._m[1,1] = _m[1,1]
		matrix._m[2,1] = _m[1,2]
	
		matrix._m[0,2] = _m[2,0]
		matrix._m[1,2] = _m[2,1]
		matrix._m[2,2] = _m[2,2]
		matrix._m[0,3] = 0 
		matrix._m[1,3] = 0
		matrix._m[2,3] = 0
		matrix._m[3,3] = 1
	
		tx = _m[3,0]
		ty = _m[3,1]
		tz = _m[3,2]
	
		matrix._m[3,0] = -( (_m[0,0] * tx) + (_m[0,1] * ty) + (_m[0,2] * tz) )
		matrix._m[3,1] = -( (_m[1,0] * tx) + (_m[1,1] * ty) + (_m[1,2] * tz) )
		matrix._m[3,2] = -( (_m[2,0] * tx) + (_m[2,1] * ty) + (_m[2,2] * tz) )
	
		Return matrix
	End Method
	
	Method Overwrite(matrix:TMatrix)
		MemCopy _m,matrix._m,64
	End Method
	
	Method GetPosition(x# Var,y# Var,z# Var)
		x=_m[3,0];y=_m[3,1];z=_m[3,2]
	End Method
	Method GetRotation(pitch# Var,yaw# Var,roll# Var)
		pitch=ATan2(_m[2,1],Sqr(_m[2,0]*_m[2,0]+_m[2,2]*_m[2,2]))
		yaw=ATan2(_m[2,0],_m[2,2])
		roll=ATan2(_m[0,1],_m[1,1])
	End Method
	Method GetScale(x# Var,y# Var,z# Var)
		x=_m[0,0];y=_m[1,1];z=_m[2,2]
	End Method
	
	Method TransformVector(x# Var,y# Var,z# Var,w# Var)
		Local _x#=x,_y#=y,_z#=z,_w#=w
		x=_m[0,0]*_x+_m[1,0]*_y+_m[2,0]*_z+_m[3,0]*_w
		y=_m[0,1]*_x+_m[1,1]*_y+_m[2,1]*_z+_m[3,1]*_w
		z=_m[0,2]*_x+_m[1,2]*_y+_m[2,2]*_z+_m[3,2]*_w
		w=_m[0,3]*_x+_m[1,3]*_y+_m[2,3]*_z+_m[3,3]*_w
	End Method
	
	Method Interpolate:TMatrix(matrix:TMatrix,t#)
		Local out:TMatrix=TMatrix.Identity()
		out._m[3,0]=matrix._m[3,0]+(_m[3,0]-matrix._m[3,0])*t
		out._m[3,1]=matrix._m[3,1]+(_m[3,1]-matrix._m[3,1])*t
		out._m[3,2]=matrix._m[3,2]+(_m[3,2]-matrix._m[3,2])*t
		Return out
	End Method
	
	Method ToPtr:Float Ptr()
		Return Varptr _m[0,0]
	End Method
	
	Function FromPtr:TMatrix(matrix_ptr:Float Ptr,transposed=False)
		Local matrix:TMatrix=New TMatrix
		If Not transposed
			MemCopy matrix._m,matrix_ptr,64
		Else
			For Local i=0 To 3
				For Local j=0 To 3
					matrix._m[j,i]=matrix_ptr[i*3+j]
				Next
			Next
		EndIf
		Return matrix
	End Function
End Type

Type TQuaternion
	Field w#,x#,y#,z#

	Function Matrix:TMatrix(w#,x#,y#,z#)
		Local q#[]=[w,x,y,z]
		
		Local wx#=q[0]*q[1],wy#=q[0]*q[2],wz#=q[0]*q[3]
		Local xx#=q[1]*q[1],xy#=q[1]*q[2],xz#=q[1]*q[3]		
		Local yy#=q[2]*q[2],yz#=q[2]*q[3]
		Local zz#=q[3]*q[3]		
		
		Local matrix:TMatrix=New TMatrix
		matrix._m[0,0]=1-2*(yy+zz)
		matrix._m[0,1]=  2*(xy-wz)
		matrix._m[0,2]=  2*(xz+wy)
		matrix._m[1,0]=  2*(xy+wz)
		matrix._m[1,1]=1-2*(xx+zz)
		matrix._m[1,2]=  2*(yz-wx)
		matrix._m[2,0]=  2*(xz-wy)
		matrix._m[2,1]=  2*(yz+wx)
		matrix._m[2,2]=1-2*(xx+yy)
		matrix._m[3,3]=1
	
		For Local iy=0 To 3
			For Local ix=0 To 3
				xx#=matrix._m[ix,iy]
				If xx#<0.0001 And xx#>-0.0001 Then xx#=0
				matrix._m[ix,iy]=xx#
			Next
		Next
		
		Return matrix	
	End Function
	
	Function Euler(w#,x#,y#,z#,pitch# Var,yaw# Var,roll# Var)
		Local matrix:TMatrix=Matrix(w,x,y,z)
		matrix.GetRotation pitch,yaw,roll	
	End Function
			
	Function Slerp(Ax#,Ay#,Az#,Aw#,Bx#,By#,Bz#,Bw#,Cx# Var,Cy# Var,Cz# Var,Cw# Var,t#)
	
		If Abs(ax-bx)<0.001 And Abs(ay-by)<0.001 And Abs(az-bz)<0.001 And Abs(aw-bw)<0.001
			cx#=ax
			cy#=ay
			cz#=az
			cw#=aw
			Return True
		EndIf
		
		Local cosineom#=Ax#*Bx#+Ay#*By#+Az#*Bz#+Aw#*Bw#
		Local scaler_w#
		Local scaler_x#
		Local scaler_y#
		Local scaler_z#
		
		If cosineom# <= 0.0
			cosineom#=-cosineom#
			scaler_w#=-Bw#
			scaler_x#=-Bx#
			scaler_y#=-By#
			scaler_z#=-Bz#
		Else
			scaler_w#=Bw#
			scaler_x#=Bx#
			scaler_y#=By#
			scaler_z#=Bz#
		EndIf
		
		Local scale0#
		Local scale1#
		
		If (1.0 - cosineom#)>0.0001
			Local omega#=ACos(cosineom#)
			Local sineom#=Sin(omega#)
			scale0#=Sin((1.0-t#)*omega#)/sineom#
			scale1#=Sin(t#*omega#)/sineom#
		Else
			scale0#=1.0-t#
			scale1#=t#
		EndIf
			
		cw#=scale0#*Aw#+scale1#*scaler_w#
		cx#=scale0#*Ax#+scale1#*scaler_x#
		cy#=scale0#*Ay#+scale1#*scaler_y#
		cz#=scale0#*Az#+scale1#*scaler_z#
		
	End Function
End Type

Type TFrustum
	Field _m#[6,4]
	
	Function Extract:TFrustum(modelview:TMatrix,projection:TMatrix)
		Local clip#[16],t#		
		
		Local modl:Float Ptr=modelview._m,proj:Float Ptr=projection._m
		
		clip[ 0] = modl[ 0] * proj[ 0] + modl[ 1] * proj[ 4] + modl[ 2] * proj[ 8] + modl[ 3] * proj[12]
		clip[ 1] = modl[ 0] * proj[ 1] + modl[ 1] * proj[ 5] + modl[ 2] * proj[ 9] + modl[ 3] * proj[13]
		clip[ 2] = modl[ 0] * proj[ 2] + modl[ 1] * proj[ 6] + modl[ 2] * proj[10] + modl[ 3] * proj[14]
		clip[ 3] = modl[ 0] * proj[ 3] + modl[ 1] * proj[ 7] + modl[ 2] * proj[11] + modl[ 3] * proj[15]
		
		clip[ 4] = modl[ 4] * proj[ 0] + modl[ 5] * proj[ 4] + modl[ 6] * proj[ 8] + modl[ 7] * proj[12]
		clip[ 5] = modl[ 4] * proj[ 1] + modl[ 5] * proj[ 5] + modl[ 6] * proj[ 9] + modl[ 7] * proj[13]
		clip[ 6] = modl[ 4] * proj[ 2] + modl[ 5] * proj[ 6] + modl[ 6] * proj[10] + modl[ 7] * proj[14]
		clip[ 7] = modl[ 4] * proj[ 3] + modl[ 5] * proj[ 7] + modl[ 6] * proj[11] + modl[ 7] * proj[15]
		
		clip[ 8] = modl[ 8] * proj[ 0] + modl[ 9] * proj[ 4] + modl[10] * proj[ 8] + modl[11] * proj[12]
		clip[ 9] = modl[ 8] * proj[ 1] + modl[ 9] * proj[ 5] + modl[10] * proj[ 9] + modl[11] * proj[13]
		clip[10] = modl[ 8] * proj[ 2] + modl[ 9] * proj[ 6] + modl[10] * proj[10] + modl[11] * proj[14]
		clip[11] = modl[ 8] * proj[ 3] + modl[ 9] * proj[ 7] + modl[10] * proj[11] + modl[11] * proj[15]
		
		clip[12] = modl[12] * proj[ 0] + modl[13] * proj[ 4] + modl[14] * proj[ 8] + modl[15] * proj[12]
		clip[13] = modl[12] * proj[ 1] + modl[13] * proj[ 5] + modl[14] * proj[ 9] + modl[15] * proj[13]
		clip[14] = modl[12] * proj[ 2] + modl[13] * proj[ 6] + modl[14] * proj[10] + modl[15] * proj[14]
		clip[15] = modl[12] * proj[ 3] + modl[13] * proj[ 7] + modl[14] * proj[11] + modl[15] * proj[15]
		
		Local frustum:TFrustum=New TFrustum
		
		frustum._m[0,0] = clip[ 3] - clip[ 0]
		frustum._m[0,1] = clip[ 7] - clip[ 4]
		frustum._m[0,2] = clip[11] - clip[ 8]
		frustum._m[0,3] = clip[15] - clip[12]
		
		frustum._m[1,0] = clip[ 3] + clip[ 0]
		frustum._m[1,1] = clip[ 7] + clip[ 4]
		frustum._m[1,2] = clip[11] + clip[ 8]
		frustum._m[1,3] = clip[15] + clip[12]
		
		frustum._m[2,0] = clip[ 3] + clip[ 1]
		frustum._m[2,1] = clip[ 7] + clip[ 5]
		frustum._m[2,2] = clip[11] + clip[ 9]
		frustum._m[2,3] = clip[15] + clip[13]
				
		frustum._m[3,0] = clip[ 3] - clip[ 1]
		frustum._m[3,1] = clip[ 7] - clip[ 5]
		frustum._m[3,2] = clip[11] - clip[ 9]
		frustum._m[3,3] = clip[15] - clip[13]
		
		frustum._m[4,0] = clip[ 3] - clip[ 2]
		frustum._m[4,1] = clip[ 7] - clip[ 6]
		frustum._m[4,2] = clip[11] - clip[10]
		frustum._m[4,3] = clip[15] - clip[14]
		
		frustum._m[5,0] = clip[ 3] + clip[ 2]
		frustum._m[5,1] = clip[ 7] + clip[ 6]
		frustum._m[5,2] = clip[11] + clip[10]
		frustum._m[5,3] = clip[15] + clip[14]
		
		frustum.Normalize
		
		Return frustum
	End Function
	
	Method Normalize()
		For Local i=0 To 5
			Local t# = Sqr( _m[i,0]*_m[i,0] + _m[i,1]*_m[i,1] + _m[i,2]*_m[i,2] )
			_m[i,0]:/t;_m[i,1]:/t;_m[i,2]:/t;_m[i,3]:/t
		Next
	End Method
	
	Method IntersectsPoint#(x#,y#,z#,radius#=0.001)
		Local d#
		For Local p=0 To 5
			d# = _m[p,0] * x + _m[p,1] * y + _m[p,2] * -z + _m[p,3]
			If d <= -radius Then Return 0
		Next
		Return d + radius
	End Method
	
	Method ToPtr:Float Ptr()
		Return Varptr _m[0,0]
	End Method
End Type
