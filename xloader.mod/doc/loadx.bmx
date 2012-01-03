
Strict

Import MaxB3D.Drivers
Import MaxB3D.XLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()

Local mesh:TMesh=LoadMesh("media/teapot.x")
SetEntityPosition mesh,0,0,3

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	TurnEntity mesh,0,1,0
	RenderWorld
	Flip
Wend
