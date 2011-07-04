
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,2,-10

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local ground_tex:TTexture=LoadTexture("media/Chorme-2.bmp")

Local flat:TFlat=CreateFlat()
SetEntityScale flat,1000,1,1000
SetEntityTexture flat,ground_tex

Local cube:TMesh=CreateCube()
Local cube_tex:TTexture=LoadTexture("media/b3dlogo.jpg")
SetEntityTexture cube,cube_tex
SetEntityPosition cube,0,1,0

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	
	If KeyDown( KEY_RIGHT ) TurnEntity camera,0,-1,0
	If KeyDown( KEY_LEFT ) TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN ) MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP ) MoveEntity camera,0,0,0.05
	
	Local x#,y#
	CameraProject camera,cube,x,y
	
	RenderWorld
	DoMax2D
	If CameraInView(camera,cube) DrawText "Cube",x,y	
	DrawText "Use cursor keys to move about",0,0
	DrawText "Projected X: "+x,0,20
	DrawText "Projected Y: "+y,0,40
	DrawText "CameraInView: "+CameraInView(camera,cube),0,60
	
	Flip
Wend
