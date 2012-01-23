
Strict

Import MaxB3D.Drivers
Import MaxB3D.MonkeyHeadLoader
Import MaxB3D.TeapotLoader

Import MaxB3DEx.Helper

Graphics 800,600

Local light:TLight = CreateLight()

Local camera:TCamera = CreateCamera()

Local mesh:TMesh = CreateMonkeyHead()
SetEntityScale mesh,10,10,10
SetEntityPosition mesh,0,0,3
SetEntityPickMode mesh,PICKMODE_POLYGON

Local sphere:TMesh = CreateSphere(32)
SetEntityScale sphere,.125,.125,.125
SetEntityColor sphere,255,0,0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If MouseDown(1)
		Local pick:TPick = WorldPick(camera, [Float(MouseX()), Float(MouseY())])
		If pick
			SetEntityPosition sphere,pick.x,pick.y,pick.z
		EndIf
	EndIf
	
	FlyCam camera
	
	SetWireFrame KeyDown(KEY_F1)
	''TurnEntity mesh,0,1,0

	RenderWorld
	Flip
Wend
