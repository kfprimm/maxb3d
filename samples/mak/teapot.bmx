
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader

Graphics 800,600

Local texture:TTexture=LoadTexture("media/spheremap.bmp", TEXTURE_COLOR)

Local teapot:TMesh=CreateCube()'Teapot()
SetEntityTexture teapot,texture
'SetEntityFX teapot, FX_FULLBRIGHT

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity teapot,.5,.7,1.1
	RenderWorld
	Flip
Wend