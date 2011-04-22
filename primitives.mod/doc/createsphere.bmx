
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local sphere:TMesh=CreateSphere()
SetEntityPosition sphere,0,0,5

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	RenderWorld
	Flip
Wend