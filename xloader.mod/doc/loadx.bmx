
Strict

Import MaxB3D.Drivers
Import MaxB3D.XLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local mesh:TMesh=LoadMesh("media/teapot.x")
'FitMesh mesh,-1,-1,-1,2,2,2
SetEntityPosition mesh,0,0,10

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	TurnEntity mesh,0,1,0
	RenderWorld
	Flip
Wend
