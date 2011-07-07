
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local sphere:TMesh=CreateSphere(32)
SetEntityPosition sphere,0,0,5

Local red,green,blue

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_1) red:-1
	If KeyDown(KEY_2) red:+1
	If KeyDown(KEY_3) green:-1
	If KeyDown(KEY_4) green:+1
	If KeyDown(KEY_5) blue:-1
	If KeyDown(KEY_6) blue:+1
	
	SetEntityColor camera,red,green,blue
	
	RenderWorld
	
	DoMax2D
	DrawText "Press keys 1-6 to change the red, green, and blue values.",0,0
	DrawText "Red: "+red,0,20
	DrawText "Green: "+green,0,40
	DrawText "Blue: "+blue,0,60
	
	Flip
Wend
