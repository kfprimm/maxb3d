
Strict

Import MaxB3D.Drivers
Import MaxB3D.PLYLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local mesh:TMesh=LoadMesh("media/bun_zipper.ply")
FitMesh mesh,-1,-1,-1,2,2,2

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity mesh,1,1,0
	RenderWorld
	Flip
Wend