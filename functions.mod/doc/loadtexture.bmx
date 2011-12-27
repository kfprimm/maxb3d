
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local cube:TMesh=CreateCube()
SetEntityPosition cube,0,0,5

Local texture:TTexture=LoadTexture("media/b3dlogo.jpg")

SetEntityTexture cube,texture

While Not KeyDown(KEY_ESCAPE) 
	Local pitch#,yaw#,roll#
	
	If KeyDown(KEY_UP) pitch=1
	If KeyDown(KEY_DOWN) pitch=-1
	If KeyDown(KEY_RIGHT) yaw=-1
	If KeyDown(KEY_LEFT) yaw=1
	If KeyDown(KEY_A) roll=-1
	If KeyDown(KEY_Z) roll=1
	
	TurnEntity cube,pitch,yaw,roll
	
	RenderWorld
	Flip
Wend
