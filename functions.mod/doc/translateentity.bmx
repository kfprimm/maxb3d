
Strict

Framework MaxB3D.Drivers
Import BRL.Random

SetGraphicsDriver GLMaxB3DDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
Graphics 640,480,0

Local camera:TCamera=CreateCamera()
Local light:TLight=CreateLight()
SetEntityRotation light,180,0,0

Local cone:TMesh=CreateCone( 32 )

SetEntityRotation cone,Rnd( 0,360 ),Rnd( 0,360 ),Rnd( 0,360 )

TranslateEntity cone,0,0,10

While Not KeyDown( KEY_ESCAPE )
	Local x#=0,y#=0,z#=0
	
	If KeyDown( KEY_LEFT )=True Then x=-0.1
	If KeyDown( KEY_RIGHT )=True Then x=0.1
	If KeyDown( KEY_DOWN )=True Then y=-0.1
	If KeyDown( KEY_UP )=True Then y=0.1
	If KeyDown( KEY_A )=True Then z=-0.1
	If KeyDown( KEY_Z )=True Then z=0.1
	
	TranslateEntity cone,x,y,z
	
	If KeyHit( KEY_SPACE )=True Then SetEntityRotation cone,Rnd( 0,360 ),Rnd( 0,360 ),Rnd( 0,360 )
	
	RenderWorld
	
	BeginMax2D
	DrawText "Use cursor/A/Z keys to translate cone, spacebar to rotate cone by random amount",0,0
	DrawText "X Translation: "+x,0,20
	DrawText "Y Translation: "+y,0,40
	DrawText "Z Translation: "+z,0,60
	EndMax2D
	
	Flip
Wend
