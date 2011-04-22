
Strict ' NOT FUNCTIONING PROPERLY

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
SetEntityPosition camera, 0,1,0

Local light:TLight = CreateLight()
SetEntityRotation light, 90,0,0

Local plane:TPlane = CreatePlane()
Local grass_tex:TTexture = LoadTexture("media/mossyground.bmp")

' PLANES NOT INFINITE (YET!) WILL REMOVE LATER!
SetTextureScale grass_tex, .05,.05
SetEntityScale plane, 20,20,20

SetEntityTexture plane, grass_tex

SetCameraFogMode camera, FOGMODE_LINEAR
SetCameraFogRange camera, 1,10

Local red = 0,green = 0,blue = 0
While Not KeyDown(KEY_ESCAPE)
	If KeyDown( KEY_1 ) And red>0      red=red-1
	If KeyDown( KEY_2 ) And red<255    red=red+1
	If KeyDown( KEY_3 ) And green>0    green=green-1
	If KeyDown( KEY_4 ) And green<255  green=green+1
	If KeyDown( KEY_5 ) And blue>0     blue=blue-1
	If KeyDown( KEY_6 ) And blue<255   blue=blue+1
	
	SetCameraFogColor camera,red,green,blue
	
	If KeyDown( KEY_LEFT )  TurnEntity camera,0,-1,0
	If KeyDown( KEY_RIGHT ) TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN )  MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP )    MoveEntity camera,0,0,0.05
	
	RenderWorld
	
	BeginMax2D	
	DrawText "Use cursor keys to move about the infinite plane",0,0
	DrawText "Press keys 1-6 to change CameraFogColor red#,green#,blue# values",0,20
	DrawText "Fog Red: "+red,0,40
	DrawText "Fog Green: "+green,0,60
	DrawText "Fog Blue: "+blue,0,80
	EndMax2D
	
	Flip

Wend