
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader

Graphics 800,600

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,10,-10

Local cube_cam:TCamera=CreateCamera()
SetEntityVisible cube_cam,False

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local teapot:TMesh=CreateTeapot()
SetEntityScale teapot,3,3,3
SetEntityPosition teapot,0,10,0

Local ground_tex:TTexture=LoadTexture("media/sand.bmp")
SetTextureScale ground_tex,10,10

Local ground:TFlat=CreateFlat()
SetEntityColor ground,168,133,55
SetEntityScale ground,1000,1,1000
SetEntityTexture ground,ground_tex

Local sky:TMesh=CreateSphere(24)
SetEntityScale sky,500,500,500
FlipMesh sky
SetEntityFX sky,FX_FULLBRIGHT
Local sky_tex:TTexture=LoadTexture("media/sky.bmp")
SetEntityTexture sky,sky_tex

'cactus=LoadMesh("media/cactus2.x")
'FitMesh cactus,-5,0,-5,2,6,.5

'camel=LoadMesh("media/camel.x")
'FitMesh camel,5,0,-5,6,5,4

'ufo_piv=CreatePivot()
'PositionEntity ufo_piv,0,15,0
'ufo=LoadMesh("media/green_ufo.x",ufo_piv)
'PositionEntity ufo,0,0,10

Local cube_tex:TTexture=CreateTexture(256,256,TEXTURE_COLOR|TEXTURE_CUBEMAP|TEXTURE_VRAM,6)

SetEntityTexture teapot,cube_tex

Local mxs#,mys#
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	FlyCam camera
	
	'TurnEntity ufo_piv,0,2,0

	UpdateCubemap cube_tex,cube_cam,teapot

	RenderWorld
	
	DoMax2D
	DrawText "Use mouse to look around",0,0
	DrawText "Use cursor keys to change camera position",0,20
	
	Flip
Wend

Function FlyCam(camera:TCamera)
	Local pitch#,yaw#,roll#
	GetEntityRotation camera,pitch,yaw,roll
	SetEntityRotation camera,pitch-(GraphicsHeight()/2.0-MouseY()),yaw+(GraphicsWidth()/2.0-MouseX()),roll
	MoveEntity camera,KeyDown(KEY_A)-KeyDown(KEY_D),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	MoveMouse GraphicsWidth()/2.0,GraphicsHeight()/2.0
End Function

Function UpdateCubemap(texture:TTexture,camera:TCamera,entity:TEntity)
	Local width,height
	GetTextureSize texture,width,height

	Local x#,y#,z#
	GetEntityPosition entity,x,y,z,True
	SetEntityVisible entity,False
	
	SetEntityPosition camera,x,y,z,True
	
	SetCameraViewport camera,0,0,width,height
	
	SetBuffer TextureBuffer(texture,CUBETEX_LEFT)
	SetEntityRotation camera,0,90,0
	RenderCamera camera	
	
	SetBuffer TextureBuffer(texture,CUBETEX_FRONT)
	SetEntityRotation camera,0,0,0
	RenderCamera camera
	
	SetBuffer TextureBuffer(texture,CUBETEX_RIGHT)
	SetEntityRotation camera,0,-90,0
	RenderCamera camera
	
	SetBuffer TextureBuffer(texture,CUBETEX_BACK)
	SetEntityRotation camera,0,180,0
	RenderCamera camera
	
	SetBuffer TextureBuffer(texture,CUBETEX_UP)
	SetEntityRotation camera,-90,0,0
	RenderCamera camera
	
	SetBuffer TextureBuffer(texture,CUBETEX_DOWN)
	SetEntityRotation camera,90,0,0
	RenderCamera camera
	
	SetEntityVisible entity,True
	SetBuffer BackBuffer()
End Function