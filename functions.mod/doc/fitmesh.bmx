
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()

Local cube:TMesh=CreateCube()
SetEntityColor cube,0,0,255
'SetEntityAlpha cube,0.5
SetEntityPosition cube,0,-1,5

FitMesh cube,-1,-.5,-1,2,1,2
FlipMesh cube

Local cone:TMesh=CreateCone(,,cube)
SetEntityColor cone,255,0,0

Local uniform=True
FitMesh cone,-1,-.5,-1,2,1,2,uniform

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_SPACE)
		uniform=Not uniform
		FitMesh cone,-1,-.5,-1,2,1,2,uniform
	EndIf
	
	RenderWorld
	TurnEntity cube,0,1,0
	DoMax2D
	DrawText "Press spacebar to toggle uniform parameter.",0,0
	DrawText "FitMesh cone,-1,-.5,-1,2,1,2,"+uniform,0,13
	
	Flip
Wend
