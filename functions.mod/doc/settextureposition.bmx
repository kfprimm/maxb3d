
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

Local u_position#=1,v_position#=1
While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	
	If KeyDown( KEY_DOWN ) u_position=u_position-0.01 
	If KeyDown( KEY_UP ) u_position=u_position+0.01 
	If KeyDown( KEY_LEFT ) v_position=v_position-0.01 
	If KeyDown( KEY_RIGHT ) v_position=v_position+0.01 
	
	SetTexturePosition texture,u_position,v_position
	
	TurnEntity cube,0.1,0.1,0.1
	
	RenderWorld
	BeginMax2D
	DrawText "Use cursor keys to change uv position values",0,0
	DrawText "u_position#="+u_position,0,13
	DrawText "v_position#="+v_position,0,26
	EndMax2D
	Flip
Wend
