
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local teapot:TMesh=CreateTeapot()
SetEntityPosition teapot,0,0,5

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	TurnEntity teapot,1,1,0
	RenderWorld
	Flip
Wend
