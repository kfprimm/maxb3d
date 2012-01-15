
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
MoveEntity camera,0,0,-5

Local sprite:TSprite = CreateSprite()
SetSpriteAngle sprite,20

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	RenderWorld
	Flip
Wend