
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader
Import MaxB3D.MonkeyHeadLoader
Import MaxB3D.Shaders

GLGraphics3D 800,600
SetShaderDriver GLSLShaderDriver()

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-3

Local shader:TShader=LoadShader("media/shaders/toon/toon.shd")

Local head:TMesh=CreateMonkeyHead()
SetEntityColor head,102,102,204
SetEntityShader head,shader

RotateMesh head,0,180,0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity head,0,1,0
	
	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0

	Flip
Wend

