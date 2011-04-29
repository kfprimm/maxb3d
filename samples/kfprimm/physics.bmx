
Strict

Import MaxB3D.Drivers
Import MaxB3D.Newton

Graphics 800,600
SetPhysicsDriver NewtonPhysicsDriver()

Local light:TLight=CreateLight()

Local floor_body:TBody=CreateBody()
SetEntityPosition floor_body,0,0,5
SetEntityBox floor_body,6,0.1,6,-3,-.05,-3

Local floor_mesh:TMesh=CreateCube(floor_body)
SetEntityScale floor_mesh,3,.05,3

Local cube_body:TBody=CreateBody()
SetEntityPosition cube_body,0,3,5

Local cube_mesh:TMesh=CreateCube(cube_body)

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,3,-2

PointEntity camera, floor_mesh

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	UpdateWorld
	RenderWorld
	Flip
Wend