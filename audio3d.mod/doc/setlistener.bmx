
Strict

Import MaxB3D.Drivers
Import MaxB3D.OpenALAudio3D

GLGraphics3D 800,600
SetAudioDriver "Audio3D OpenAL"

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,1,-10

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local plane:TPlane=CreatePlane()
SetEntityScale plane,1000,0,1000

Local ground_tex:TTexture=LoadTexture("media/Chorme-2.bmp")
SetEntityTexture plane,ground_tex

Local cube:TMesh=CreateCube()
Local cube_tex:TTexture=LoadTexture("media/b3dlogo.jpg")
SetEntityTexture cube,cube_tex
SetEntityPosition cube,0,1,0

SetListener camera
Local sound:TSound=LoadSound("media/ufo.wav") 

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	
	If KeyDown(KEY_RIGHT) TurnEntity camera,0,-1,0
	If KeyDown(KEY_LEFT) TurnEntity camera,0,1,0
	If KeyDown(KEY_DOWN) MoveEntity camera,0,0,-0.05
	If KeyDown(KEY_UP) MoveEntity camera,0,0,0.05
	
	If MouseHit(1) EmitSound sound,cube
	
	RenderWorld	
	BeginMax2D
	DrawText "Use cursor keys to move about",0,0
	DrawText "Press left mouse button to make a sound be emitted from the cube",0,20
	EndMax2D
	Flip
Wend
