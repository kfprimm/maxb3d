
Strict

Import MaxB3D.Drivers

GLGraphics3D 800,600

Local camera:TCamera = CreateCamera()
SetEntityPosition camera, 0,1,0
SetCameraFogRange camera, -10,-1

Local light:TLight = CreateLight()
SetEntityRotation light, 90,0,0

Local grass_tex:TTexture = LoadTexture("media/mossyground.bmp")

Local flat:TFlat = CreateFlat()
SetEntityScale flat,1000,1,1000
SetEntityTexture flat,grass_tex

Local red = 0,green = 0,blue = 0, fogmode, fogtext$="FOGMODE_NONE"
While Not KeyDown(KEY_ESCAPE)
	
	If KeyDown( KEY_LEFT )  TurnEntity camera,0,-1,0
	If KeyDown( KEY_RIGHT ) TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN )  MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP )    MoveEntity camera,0,0,0.05
	
	If KeyHit( KEY_SPACE) 
		Select fogmode
		Case FOGMODE_NONE
			fogmode=FOGMODE_LINEAR
			fogtext="FOGMODE_LINEAR"
		Case FOGMODE_LINEAR
			fogmode=FOGMODE_NONE
			fogtext="FOGMODE_NONE"
		End Select
	EndIf
	
	SetCameraFogMode camera, fogmode	
	
	RenderWorld
	
	DoMax2D	
	DrawText "Use cursor keys to move about the infinite plane.", 0,0
	DrawText "Press spacebar to toggle between fog modes.", 0,20
	DrawText "SetCameraFogMode camera,"+fogtext, 0,40
	
	Flip
Wend
