
Strict

Import MaxB3D.Drivers

Graphics 800,600,0

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local sphere:TMesh=CreateSphere(32)
SetEntityPosition sphere,0,0,2

Local enable
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_SPACE) Then enable=Not enable
	SetWireFrame enable
	
	RenderWorld
	
	DoMax2D
	DrawText "Press spacebar to toggle between Wireframe True/False",0,0
	If enable=True Then DrawText "Wireframe True",0,20 Else DrawText "Wireframe False",0,20
	
	Flip
Wend
