
Strict

Import MaxB3D.Drivers
Import MaxB3D.MS3DLoader

GLGraphics3D 800,600 

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,10,-20

Local model:TMesh=LoadMesh("media/zombie02.ms3d")

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	TurnEntity model,0,1,0
	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0
	Flip
Wend
