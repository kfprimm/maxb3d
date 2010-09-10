
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local cam1:TCamera=CreateCamera()
SetCameraViewport cam1,0,0,GraphicsWidth(),GraphicsHeight()/2

Local cam2:TCamera=CreateCamera()
SetCameraViewport cam2,0,GraphicsHeight()/2,GraphicsWidth(),GraphicsHeight()/2

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local plane:TPlane=CreatePlane()
Local grass_tex:TTexture=LoadTexture("media/mossyground.bmp")
SetEntityTexture plane,grass_tex
SetEntityPosition plane,0,0,5

While Not KeyDown( KEY_ESCAPE )
	
	If KeyDown( KEY_RIGHT ) TurnEntity cam1,0,-1,0
	If KeyDown( KEY_LEFT ) TurnEntity cam1,0,1,0
	If KeyDown( KEY_DOWN ) MoveEntity cam1,0,0,-0.05
	If KeyDown( KEY_UP ) MoveEntity cam1,0,0,0.05
	
	RenderWorld
	
	BeginMax2D
	DrawText "Use cursor keys to move the first camera about the infinite plane",0,0
	EndMax2D
	Flip
Wend

