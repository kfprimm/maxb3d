
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local cube:TMesh=CreateCube()
SetEntityColor cube,128,34,0

Local grass:TImage=LoadImage("media/MossyGround.BMP")
MidHandleImage grass

Local rotation#
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity cube,1,1,0
	
	rotation:+.5
	
	RenderWorld
	BeginMax2D
	SetRotation 0
	SetScale 1,1
	DrawText "Drawing text...",0,0
	SetRotation rotation
	SetScale Sin(MilliSecs()/10.0),Sin(MilliSecs()/10.0)
	DrawImage grass,MouseX(),MouseY()
	EndMax2D
	Flip
Wend
