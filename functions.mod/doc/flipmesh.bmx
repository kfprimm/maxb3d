
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
Local light:TLight = CreateLight()

Local sphere:TMesh = CreateSphere()
SetEntityScale sphere,100,100,100
SetEntityTexture sphere, LoadTexture("media/sky.bmp")
FlipMesh sphere

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	RenderWorld
	DoMax2D
	SetColor 0,0,0
	DrawText "You are viewing a flipped sphere mesh - makes a great sky!",0,0
	Flip
Wend

