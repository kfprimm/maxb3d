
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local pivot:TPivot=CreatePivot()
SetEntityPosition pivot,0,1,0

Local camera:TCamera=CreateCamera(pivot)
SetEntityPosition camera,0,0,10

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local plane:TPlane=CreatePlane()
SetEntityScale plane,1000,1,1000

Local ground_tex:TTexture=LoadTexture("media/Chorme-2.bmp")
SetEntityTexture plane,ground_tex

Local sprite:TSprite=LoadSprite("media/b3dlogo.jpg")
SetEntityPosition sprite,0,1,0
SetEntityFX sprite,FX_NOCULLING

Local pitch#,yaw#,roll#
Local view_mode=1,view_mode_info$="FIXED"
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_DOWN) And pitch<0 pitch=pitch+1
	If KeyDown(KEY_UP) And pitch>-89 pitch=pitch-1
	If KeyDown(KEY_RIGHT)  yaw=yaw+1
	If KeyDown(KEY_LEFT) Then yaw=yaw-1
	If KeyDown(KEY_A) Then roll=roll+1
	If KeyDown(KEY_S) Then roll=roll-1
	
	If KeyHit(KEY_1) view_mode=1 ; view_mode_info="FIXED"
	If KeyHit(KEY_2) view_mode=2 ; view_mode_info="FREE"
	If KeyHit(KEY_3) view_mode=3 ; view_mode_info="UPRIGHT1"
	If KeyHit(KEY_4) view_mode=4 ; view_mode_info="UPRIGHT2"
	
	SetSpriteViewMode sprite,view_mode
	
	SetEntityRotation pivot,pitch,yaw,0
	PointEntity camera,sprite,roll

	RenderWorld
	
	BeginMax2D
	DrawText "Use cursor keys to orbit camera around sprite",0,0
	DrawText "Press A and S keys to roll camera",0,20
	DrawText "Press keys 1-4 to change sprite view mode",0,40
	DrawText "SetSpriteViewMode: VIEWMODE_"+view_mode_info,0,60
	EndMax2D
	
	Flip
Wend