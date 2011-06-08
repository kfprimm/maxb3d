
Strict

Import MaxB3D.Drivers
Import MaxB3D.BunnyLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

Local bunny:TMesh=CreateBunny()
SetEntityFX bunny,FX_FULLBRIGHT|FX_NOCULLING

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity bunny,0,1,0
	RenderWorld
	Flip
Wend