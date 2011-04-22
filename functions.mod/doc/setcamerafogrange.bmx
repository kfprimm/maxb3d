
Strict ' NOT FUNCTIONING PROPERLY

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
SetEntityPosition camera, 0,1,0
SetCameraFogRange camera, -1,-10

Local light:TLight = CreateLight()
SetEntityRotation light, 90,0,0

Local plane:TPlane = CreatePlane()
Local grass_tex:TTexture = LoadTexture("media/mossyground.bmp")

' PLANES NOT INFINITE (YET!) WILL REMOVE LATER!
SetTextureScale grass_tex, .05,.05
SetEntityScale plane, 20,20,20

SetEntityTexture plane, grass_tex

SetCameraFogMode camera, FOGMODE_LINEAR

Local fog_range = 10

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	
	If KeyDown( KEY_OPENBRACKET ) fog_range = fog_range - 1
	If KeyDown( KEY_CLOSEBRACKET ) fog_range = fog_range + 1
	
	SetCameraFogRange camera, 1,fog_range
	
	If KeyDown( KEY_LEFT )  TurnEntity camera,0,-1,0
	If KeyDown( KEY_RIGHT ) TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN )  MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP )    MoveEntity camera,0,0,0.05
	
	RenderWorld
	
	BeginMax2D
	DrawText "Use cursor keys to move about the infinite plane",0,0
  DrawText "Press [ or ] to change SetCameraFogRange value",0,20
  DrawText "SetCameraFogRange camera,1,"+fog_range,0,40
	EndMax2D
	
	Flip
Wend
