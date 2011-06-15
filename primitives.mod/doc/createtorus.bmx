
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-10

Local torus:TMesh=CreateTorus(2,.25,16,4)

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	RenderWorld
	Flip
Wend
