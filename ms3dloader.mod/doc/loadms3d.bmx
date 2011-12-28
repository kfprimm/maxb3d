
Strict

Import MaxB3D.Drivers
Import MaxB3D.MS3DLoader

Graphics 800,600 

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-4

Local cube:TMesh=CreateCube()

Local model:TMesh=LoadMesh("media/dwarf1.ms3d",cube)
FitMesh model,-1,-1,-1,2,2,2


While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	TurnEntity model,0,1,0
	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0
	Flip
Wend
