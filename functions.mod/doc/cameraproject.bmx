
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera = CreateCamera()
SetEntityPosition camera,0,2,-10

Local light:TLight = CreateLight()
SetEntityRotation light,90,0,0

Local flat:TFlat = CreateFlat()
SetEntityTexture flat, LoadTexture("media/Chorme-2.bmp")
SetEntityScale flat,200,0,200

Local cube:TMesh = CreateCube()
SetEntityTexture cube, LoadTexture("media/b3dlogo.jpg")
SetEntityPosition cube,0,1,0

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()

	If KeyDown( KEY_RIGHT ) Then TurnEntity camera,0,-1,0
	If KeyDown( KEY_LEFT  ) Then TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN  ) Then MoveEntity camera,0,0,-0.05
	If KeyDown( KEY_UP    ) Then MoveEntity camera,0,0,0.05

	RenderWorld
	DoMax2D

	Local x#, y#
	CameraProject camera,cube,x,y
		
	If CameraInView(camera, cube) DrawText "Cube",x,y

	DrawText "Use cursor keys to move about",0,0
	DrawText "ProjectedX: "+x,0,20
	DrawText "ProjectedY: "+y,0,40
	DrawText "CameraInView: "+CameraInView(camera, cube),0,60

	Flip
Wend
