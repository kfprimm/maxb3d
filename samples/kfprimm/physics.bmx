
Strict

Import MaxB3D.Drivers
Import MaxB3D.Newton

Graphics 800,600
SetPhysicsDriver NewtonPhysicsDriver()

Local light:TLight=CreateLight()

Local flr:TMesh=CreateCube()
SetEntityScale flr,3,.05,3
SetEntityPosition flr,0,0,5

Local obj:TMesh=CreateCube()
SetEntityPosition obj,0,3,5

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,3,-2
PointEntity camera, flr

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	UpdateWorld
	RenderWorld
	Flip
Wend