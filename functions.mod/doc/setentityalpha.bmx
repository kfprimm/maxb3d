
Strict

Import MaxB3D.Drivers

Graphics 640,480

Local camera:TCamera = CreateCamera()

Local light:TLight = CreateLight()
SetEntityRotation light,90,0,0

Local cube:TMesh = CreateCube()
SetEntityPosition cube,0,0,5
SetEntityFX cube,FX_FULLBRIGHT

Local back:TMesh = CreateCube()
SetEntityPosition back,0,0,15
SetEntityScale back,10,2,1
SetEntityColor back,255,0,0

Local alpha#=1

While Not KeyDown( KEY_ESCAPE )
	If KeyDown( KEY_1 ) alpha=Min(Max(alpha-0.01,0.0),1.0)
	If KeyDown( KEY_2 ) alpha=Min(Max(alpha+0.01,0.0),1.0)
	SetEntityAlpha cube,alpha
	
	TurnEntity cube,0.4,0.4,0.1
	TurnEntity back,1,0,0
	
	RenderWorld
	DoMax2D
	DrawText "Press keys 1-2 to change EntityAlpha",0,0
	DrawText "Entity Alpha: "+alpha,0,20

	Flip
Wend

