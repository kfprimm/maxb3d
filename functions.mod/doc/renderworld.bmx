
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	Local info:TRenderInfo=RenderWorld()
	BeginMax2D
	DrawText "Render Information:",0,0
	DrawText "Frames/second (FPS):"+info.FPS,0,13
	DrawText "Triangles rendered: "+info.Triangles,0,26
	EndMax2D
	Flip
Wend