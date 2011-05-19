
Strict

Import MaxB3D.Drivers

'SetGraphicsDriver GLMaxB3DDriver()
Graphics 800,600

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

'Local light:TLight=CreateLight()
'SetEntityRotation light,90,0,0

Local cube:TMesh=CreateCube()

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	TurnEntity cube,.5,0,0
	RenderWorld
	Flip
Wend
