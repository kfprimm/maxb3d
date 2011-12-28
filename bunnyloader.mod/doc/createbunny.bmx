
Strict

Import MaxB3D.Drivers
Import MaxB3D.BunnyLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-2

Local bunny:TMesh=CreateBunny()

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	
	TurnEntity bunny,0,1,0
	RenderWorld
	Flip
Wend