
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader

Graphics 800,600

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local teapot:TMesh=CreateTeapot()

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	TurnEntity teapot,1,1,0
	RenderWorld
	Flip
Wend
