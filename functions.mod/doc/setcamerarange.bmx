
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera() 
SetEntityPosition camera,0,1,0 

Local light:TLight=CreateLight() 
SetEntityRotation light,90,0,0 

Local grass_tex:TTexture=LoadTexture("media/mossyground.bmp") 

Local flat:TFlat=CreateFlat() 
SetEntityScale flat,1000,1,1000
SetEntityTexture flat,grass_tex 

Local cam_range=10 

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	If KeyDown(KEY_OPENBRACKET) cam_range=cam_range-1 
	If KeyDown(KEY_CLOSEBRACKET) cam_range=cam_range+1 
	
	SetCameraRange camera,1,cam_range 
	
	If KeyDown(205) TurnEntity camera,0,-1,0 
	If KeyDown(203) TurnEntity camera,0,1,0 
	If KeyDown(208) MoveEntity camera,0,0,-0.05 
	If KeyDown(200) MoveEntity camera,0,0,0.05 
	
	RenderWorld 
	DoMax2D
	DrawText "Use cursor keys to move about the infinite plane",0,0
	DrawText "Press [ or ] to change CameraRange value",0,13
	DrawText "CameraRange camera,1,"+cam_range,0,26
	
	Flip
Wend