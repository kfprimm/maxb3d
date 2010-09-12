
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()
Local light:TLight=CreateLight()

Local cone:TMesh=CreateCone()

Local x#,y#,z#=10

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_LEFT) x:-.01
	If KeyDown(KEY_RIGHT) x:+.01
	If KeyDown(KEY_UP) y:+.01
	If KeyDown(KEY_DOWN) y:-.01
	If KeyDown(KEY_A) z:+.01
	If KeyDown(KEY_Z) z:-.01
	
	SetEntityPosition cone,x,y,z
	
	RenderWorld
	
	BeginMax2D
	DrawText "Use the arrow/A/Z/ keys to move the cone.",0,0
	EndMax2D
	Flip
Wend