
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local cube:TMesh=CreateCube()

Local smooth=False

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_SPACE)
		smooth=Not smooth
		UpdateMeshNormals cube,smooth
	EndIf
	
	TurnEntity cube,1,1,0
	RenderWorld
	DoMax2D
	DrawText "Press spacebar to toggle between vertex or triangle dependent smoothing.",0,0
	DrawText "Smoothing = "+smooth,0,20
	Flip
Wend
