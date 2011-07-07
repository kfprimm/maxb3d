
Strict

Import MaxB3D.Drivers

Graphics 800,600
SetAmbientLight 50, 50, 50

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,2,-50
SetCameraZoom camera,4

Local light:TLight=CreateLight()
TurnEntity light,30,40,0

Local oSphere:TMesh=CreateSphere()
SetEntityColor oSphere,250,50,0

Local pCone:TMesh=CreateCone(8,True,oSphere)
SetEntityScale pCone,.8,2.0,.8
SetEntityPosition pCone,8,0,0
SetEntityColor pCone,255,255,0

Local cSphere:TMesh=CreateSphere(8,pCone)
SetEntityColor cSphere,150,150,0
SetEntityScale cSphere,.4/.8,.4/2.0,.4/.8
SetEntityPosition cSphere,0,2,0

Local ismoving=False,count=0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()

	If GetChar() Then isMoving = Not isMoving
	
	If ismoving
		TurnEntity oSphere,0,.5,0
		TurnEntity pCone,.2,0,0
		
		count:+1
		SetEntityPosition cSphere,0,2+Sin(count Mod 360), 0
	EndIf
	
	RenderWorld
	
	DoMax2D	
	SetColor 255, 255, 255
	DrawText "Global",185,20
	DrawText "Local",495,20
	
	SetColor 250, 50, 0
	DrawText "oSphere: "+XYZ(oSphere,True),20,50
	DrawText XYZ(oSphere,False),400,50
	
	SetColor 255, 255, 0
	DrawText " pCone: "+XYZ(pCone,True),20,75
	DrawText XYZ(pCone,False),400,75
	
	SetColor 150, 150, 0
	DrawText "cSphere: " + XYZ( cSphere, True ),20,100
	DrawText XYZ( cSphere, False ),400,100
	
	Flip
Wend

Function Round#(x#,m#)
	Local s#=Sgn(x)
	x=Abs(x);m=Abs(m)
	Local diff# = x Mod m
	If diff < .5 * m
		Return ( x - diff ) * s
	Else
		Return ( m + x - diff ) * s
	End If
End Function

Function XYZ$( entity:TEntity, globalFlag )
	Local x#,y#,z#	
	GetEntityPosition entity,x#,y#,z#,globalFlag	
	x=Round(x,0.001);y=Round(y,0.001);z=Round(z,0.001)	
	Return RSet(Round(x,0.001),8) + RSet(Round(y,0.001),8) + RSet(Round(z,0.001),8)
End Function
