
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local cube:TMesh=CreateCube()

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_RIGHT) TurnEntity camera,0,-1,0
	If KeyDown(KEY_LEFT) TurnEntity camera,0,1,0
	If KeyDown(KEY_DOWN) MoveEntity camera,0,0,-0.05
	If KeyDown(KEY_UP) MoveEntity camera,0,0,0.05

	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "Render Information",0,0
	DrawText "Frames/second (FPS): "+info.FPS,0,13
	DrawText "Triangles rendered:  "+info.Triangles,0,26
	DrawText "Entities rendered:   "+info.Entities,0,39
	
	Flip
Wend