
Strict

Import MaxB3D.Drivers

GLGraphics3D 800,600
SetAmbientLight 0,0,0

Local sphere:TMesh=CreateSphere(32)

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

'directional light
Local light1:TLight=CreateLight( LIGHT_DIRECTIONAL )
TurnEntity light1,0,-30,0
SetEntityColor light1,255,0,0

'point light
Local light2:TLight=CreateLight( LIGHT_POINT )
SetEntityPosition light2,5,0,-10
SetEntityColor light2,0,255,0
SetLightRange light2,15

'spot light
Local light3:TLight=CreateLight( LIGHT_SPOT )
SetEntityPosition light3,0,0,-10
SetEntityColor light3,0,0,255
SetLightAngles light3,0,10
SetLightRange light3,15

Local on1=True,on2=True,on3=True

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_F1) on1=Not on1
	If KeyHit(KEY_F2) on2=Not on2
	If KeyHit(KEY_F3) on3=Not on3
	
	If on3 SetEntityRotation light3,Sin(MilliSecs()*.07)*5,Sin(MilliSecs()*.05)*5,0	
	
	SetEntityVisible light1,on1
	SetEntityVisible light2,on2
	SetEntityVisible light3,on3
	
	RenderWorld
	
	BeginMax2D
	DrawText "(F1) Light1="+on1,0,0
	DrawText "(F2) Light2="+on2,0,13
	DrawText "(F3) Light3="+on3,0,26
	EndMax2D
	
	Flip
Wend
