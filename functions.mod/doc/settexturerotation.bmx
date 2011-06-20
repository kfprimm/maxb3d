
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local texture:TTexture=LoadTexture( "media/b3dlogo.jpg" )

Local cube:TMesh=CreateCube()
SetEntityPosition cube,0,0,5
SetEntityTexture cube,texture

Local angle#
While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	
	If KeyDown( KEY_RIGHT ) angle=angle-1
	If KeyDown( KEY_LEFT ) angle=angle+1 
	
	SetTextureRotation texture,angle
	
	TurnEntity cube,0.1,0.1,0.1
	
	RenderWorld
	BeginMax2D
	DrawText "Use left and right cursor keys to change texture angle value",0,0
	DrawText "angle#="+angle#,0,13
	EndMax2D
	Flip
Wend
