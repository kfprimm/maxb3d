
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
MoveEntity camera, 0,0,-3

Local ball:TMesh = CreateSphere()

Local light:TLight = CreateLight()
MoveEntity light, 5,0,0
PointEntity light, camera

While Not KeyDown(KEY_ESCAPE)
	RenderWorld
	Flip
Wend