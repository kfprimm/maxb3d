
Strict

Import MaxB3D.Drivers
Import MaxB3D.Newton

Graphics 800,600
SetPhysicsDriver NewtonPhysicsDriver()

Local light:TLight=CreateLight()

Local floor_body:TBody=CreateBody()
SetEntityPosition floor_body,0,0,5
SetEntityBox floor_body,-3,-.05,-3,6,0.1,6

Local floor_mesh:TMesh=CreateCube(floor_body)
SetEntityScale floor_mesh,3,.05,3

Local texture:TTexture=LoadTexture("media/crate.jpg")

For Local y=0 To 99
	Local cube_body:TBody=CreateBody()
	SetEntityPosition cube_body,0,.3+(2*y),5
	SetEntityBox cube_body,-1,-1,-1,2,2,2
	SetBodyMass cube_body, 4
	
	Local cube_mesh:TMesh=CreateCube(cube_body)
	SetEntityTexture cube_mesh,texture
Next

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,3,-4

PointEntity camera, floor_mesh

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	FlyCam camera
	UpdateWorld
	RenderWorld
	Flip
Wend

Function FlyCam(camera:TCamera)
	MoveEntity camera,0,0,KeyDown(KEY_W)-KeyDown(KEY_S)
End Function