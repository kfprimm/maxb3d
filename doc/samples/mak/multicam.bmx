
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local pixmap:TPixmap=CreatePixmap(64,64,PF_RGBA8888)
For Local y=0 To PixmapHeight(pixmap)-1
	For Local x=0 To PixmapWidth(pixmap)-1
		Local color=$FF00FFFF
		If (x>31 And y<32) Or (y>31 And x<32) color=$FFFF8000
		WritePixel pixmap,x,y,color
	Next
Next
Local texture:TTexture = LoadTexture(pixmap)

Local cone:TMesh=CreateCone(20)
SetEntityTexture cone,texture

Local sphere:TMesh=CreateSphere(10)
SetEntityPosition sphere,2,0,0
SetEntityTexture sphere,texture

Local cylinder:TMesh=CreateCylinder(20)
SetEntityPosition cylinder,-2,0,0
SetEntityTexture cylinder,texture

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local pivot:TPivot=CreatePivot()

Local z_cam:TCamera=CreateCamera( pivot )
SetCameraViewport z_cam,0,0,320,240
SetEntityPosition z_cam,0,0,-5

Local y_cam:TCamera=CreateCamera( pivot )
SetCameraViewport y_cam,320,0,320,240
SetEntityPosition y_cam,0,5,0
TurnEntity y_cam,90,0,0

Local x_cam:TCamera=CreateCamera( pivot )
SetCameraViewport x_cam,0,240,320,240
TurnEntity x_cam,0,-90,0
SetEntityPosition x_cam,-5,0,0

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()

	If KeyDown(KEY_RIGHT) MoveEntity pivot,-.1,0,0
	If KeyDown(KEY_LEFT) MoveEntity pivot,.1,0,0
	If KeyDown(KEY_UP) MoveEntity pivot,0,.1,0
	If KeyDown(KEY_DOWN) MoveEntity pivot,0,-.1,0
	If KeyDown(KEY_A) MoveEntity pivot,0,0,.1
	If KeyDown(KEY_Z) MoveEntity pivot,0,0,-.1

	RenderWorld
	DoMax2D
	DrawText "Front",0,0
	DrawText "Top",320,0
	DrawText "Left",0,240
	
	Flip
Wend