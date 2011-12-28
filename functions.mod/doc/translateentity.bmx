
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,180,0,0

Local cone:TMesh=CreateCone( 32 )
SetEntityRotation cone,Rnd( 0,360 ),Rnd( 0,360 ),Rnd( 0,360 )

TranslateEntity cone,0,0,10

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	Local x#=0,y#=0,z#=0
	
	If KeyDown( KEY_LEFT ) x=-0.1
	If KeyDown( KEY_RIGHT ) x=0.1
	If KeyDown( KEY_DOWN ) y=-0.1
	If KeyDown( KEY_UP ) y=0.1
	If KeyDown( KEY_A ) z=-0.1
	If KeyDown( KEY_Z ) z=0.1
	
	TranslateEntity cone,x,y,z
	
	If KeyHit( KEY_SPACE ) SetEntityRotation cone,Rnd( 0,360 ),Rnd( 0,360 ),Rnd( 0,360 )
	
	RenderWorld
	
	DoMax2D
	DrawText "Use cursor/A/Z keys to translate cone, spacebar to rotate cone by random amount",0,0
	DrawText "X Translation: "+x,0,20
	DrawText "Y Translation: "+y,0,40
	DrawText "Z Translation: "+z,0,60
	
	Flip
Wend
