
Strict

Import MaxB3D.Drivers

Graphics 800,600
SetAmbientLight 32,32,32

Local light:TLight=CreateLight()
SetEntityRotation light,45,45,0

Local camera:TCamera=CreateCamera()

Local sphere:TMesh=CreateSphere(100)
SetEntityColor Sphere,255,0,0
SetEntityPosition sphere,0,0,4

Local shine#=0

While Not KeyDown(KEY_ESCAPE)
	If KeyDown(KEY_1) And shine#>0 Then shine:-0.01
	If KeyDown(KEY_2) And shine#<1 Then shine:+0.01

	SetEntityShine sphere,shine

	RenderWorld
	
	BeginMax2D
	DrawText "Press keys 1-2 to change EntityShininess Setting",0,0
	DrawText "Entity Shininess: "+shine,0,20
	EndMax2D
	
	Flip
Wend
