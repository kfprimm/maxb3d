
Strict

Import MaxB3D.Drivers

Graphics 800,600

Const TYPE_CONE		= 1
Const TYPE_SPHERE	= 2

Local camera:TCamera=CreateCamera()
Local light:TLight=CreateLight()

Local sphere:TMesh=CreateSphere(32)
SetEntityPosition sphere,-2,0,5
SetEntityType sphere,TYPE_SPHERE

Local cone:TMesh=CreateCone(32)
SetEntityPosition cone,2,0,5
SetEntityType cone,TYPE_CONE

SetCollisions TYPE_SPHERE,TYPE_CONE,COLLISION_METHOD_POLYGON,COLLISION_RESPONSE_SLIDE

Local sphere_radius#=1.0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	Local x#,y#,z#
	
	If KeyDown(KEY_LEFT) x:-0.1
	If KeyDown(KEY_RIGHT) x:+0.1
	If KeyDown(KEY_UP) y:+0.1
	If KeyDown(KEY_DOWN) y:-0.1
	If KeyDown(KEY_A) z:+0.1
	If KeyDown(KEY_Z) z:-0.1
	
	MoveEntity sphere,x,y,z
	
	If KeyDown(KEY_OPENBRACKET) sphere_radius:-0.1
	If KeyDown(KEY_CLOSEBRACKET) sphere_radius:+0.1
	SetEntityRadius sphere,sphere_radius
	
	UpdateWorld
	RenderWorld
	
	BeginMax2D
	DrawText "Use cursor/A/Z keys to move sphere",0,0
	DrawText "Press [ or ] to change SetEntityRadius radius_x# value",0,20
	DrawText "SetEntityRadius sphere,"+sphere_radius,0,40
	EndMax2D
	
	Flip
Wend



