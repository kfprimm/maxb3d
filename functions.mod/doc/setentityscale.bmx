
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()
Local light:TLight=CreateLight()

Local cone:TMesh=CreateCone(32)
SetEntityPosition cone,0,0,5

Local x_scale#=1.0,y_scale#=1.0,z_scale#=1.0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_LEFT) x_scale:-0.01
	If KeyDown(KEY_RIGHT) x_scale:+0.01
	If KeyDown(KEY_UP) y_scale:+0.01
	If KeyDown(KEY_DOWN) y_scale:-0.01
	If KeyDown(KEY_A) z_scale:+0.01
	If KeyDown(KEY_Z) z_scale:-0.01
	
	SetEntityScale cone,x_scale,y_scale,z_scale
	
	RenderWorld
	
	BeginMax2D
	DrawText "Use cursors/A/Z to scale the cone.",0,0
	DrawText "X Scale: "+x_scale,0,20
	DrawText "Y Scale: "+y_scale,0,40
	DrawText "Z Scale: "+z_scale,0,60
	EndMax2D
	
	Flip
Wend
