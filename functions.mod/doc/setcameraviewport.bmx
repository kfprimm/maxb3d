
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local cam1:TCamera=CreateCamera()
SetCameraViewport cam1,0,0,GraphicsWidth(),GraphicsHeight()/2

Local cam2:TCamera=CreateCamera()
SetCameraViewport cam2,0,GraphicsHeight()/2,GraphicsWidth(),GraphicsHeight()/2

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local grass_tex:TTexture=LoadTexture("media/mossyground.bmp")

Local flat:TFlat=CreateFlat()
SetEntityTexture flat,grass_tex
SetEntityScale flat,1000,1,1000

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	
	If KeyDown( KEY_RIGHT ) TurnEntity cam1,0,-1,0
	If KeyDown( KEY_LEFT ) TurnEntity cam1,0,1,0
	If KeyDown( KEY_DOWN ) MoveEntity cam1,0,0,-0.05
	If KeyDown( KEY_UP ) MoveEntity cam1,0,0,0.05
	
	RenderWorld
	
	DoMax2D
	DrawText "Use cursor keys to move the first camera about the infinite plane",0,0
	
	Flip
Wend

