
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader
Import MaxB3D.MonkeyHeadLoader

GLGraphics3D 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

Local shader:TShader=LoadShader("media/shaders/toon/toon.shd")

Local head:TMesh=CreateMonkeyHead()
SetEntityShader head,shader

RotateMesh head,0,180,0
UpdateMeshNormals head


While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity head,1,1,0
	
	Local info:TRenderInfo=RenderWorld()
	BeginMax2D
	DrawText "FPS: "+info.FPS,0,0
	EndMax2D
	Flip
Wend

