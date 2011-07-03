
Strict

Import MaxB3D.Drivers
Import MaxB3D.MonkeyHeadLoader

Graphics 800,600 

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

Local head:TMesh=CreateMonkeyHead()

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity head,1,1,0
	RenderWorld
	Flip
Wend