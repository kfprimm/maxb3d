
Strict

Import MaxB3D.Drivers

Const TEXTURE_SIZE = 128

Graphics 800,600

Local grid_tex:TTexture=CreateTexture( 16,16 )
SetTextureScale grid_tex,10,10

SetBuffer TextureBuffer( grid_tex )
SetClsColor 255,255,255;Cls;SetClsColor 0,0,0
SetColor 192,192,192;DrawRect 0,0,8,8;DrawRect 8,8,8,8

SetBuffer BackBuffer()

Local plane:TPlane=CreatePlane()
SetEntityScale plane,1000,1,1000
SetEntityTexture plane,grid_tex

Local pivot:TPivot=CreatePivot()
SetEntityPosition pivot,0,2,0

Local t_sphere:TMesh=CreateSphere( 8 )
SetEntityShine t_sphere,.2
For Local t=0 To 359 Step 36
	Local sphere:TMesh=TMesh(CopyEntity( t_sphere,pivot ))
	SetEntityColor sphere,Rnd(256),Rnd(256),Rnd(256)
	TurnEntity sphere,0,t,0
	MoveEntity sphere,0,0,10
Next
FreeEntity t_sphere

Local texture:TTexture=CreateTexture( TEXTURE_SIZE,TEXTURE_SIZE )

Local cube:TMesh=CreateCube()
SetEntityTexture cube,texture
SetEntityPosition cube,0,7,0
SetEntityScale cube,3,3,3

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local camera:TCamera=CreateCamera()

Local plan_cam:TCamera=CreateCamera()
TurnEntity plan_cam,90,0,0
SetEntityPosition plan_cam,0,20,0
SetCameraViewport plan_cam,0,0,TEXTURE_SIZE,TEXTURE_SIZE
SetEntityColor plan_cam,0,128,0
SetEntityVisible plan_cam,False

SetColor 255,255,255

Local d#=-20
While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_A) d=d+1
	If KeyDown(KEY_Z) d=d-1
	If KeyDown(KEY_LEFT) TurnEntity camera,0,-3,0
	If KeyDown(KEY_RIGHT) TurnEntity camera,0,+3,0
	
	SetEntityPosition camera,0,7,0
	MoveEntity camera,0,0,d
	
	TurnEntity cube,.1,.2,.3
	TurnEntity pivot,0,1,0
	
	UpdateWorld
	
	SetBuffer TextureBuffer( texture )
	RenderCamera plan_cam
	
	SetBuffer BackBuffer()
	Local info:TRenderInfo=RenderWorld()
	
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0

	Flip
Wend