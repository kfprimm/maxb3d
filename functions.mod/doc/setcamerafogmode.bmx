
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

Local red = 0,green = 0,blue = 0, fogmode
While Not KeyDown(KEY_ESCAPE)
	
	If KeyDown( KEY_LEFT )  TurnEntity camera,0,-1,0
	If KeyDown( KEY_RIGHT ) TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN )  MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP )    MoveEntity camera,0,0,0.05
	
	If KeyHit( KEY_SPACE) fogmode = Not fogmode
	
	SetCameraFogMode camera, fogmode	
	
	RenderWorld
	
	BeginMax2D	
	DrawText "Use cursor keys to move about the infinite plane", 0,0
	DrawText "Press spacebar to toggle between CameraFogMode 0/1", 0,20
	DrawText "SetCameraFogMode camera,"+fogmode, 0,40
	EndMax2D
	
	Flip

Wend
