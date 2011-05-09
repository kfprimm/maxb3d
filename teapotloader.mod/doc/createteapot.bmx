
Strict

Import MaxB3D.Drivers
Import MaxB3D.TeapotLoader

'SetGraphicsDriver GLMaxB3DDriver()
Graphics 800,600
SetAmbientLight 127,0,0
Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local teapot:TMesh=CreateTeapot()
SetEntityFX teapot,FX_WIREFRAME
For Local surface:TSurface=EachIn teapot._surfaces
	For Local v=0 To CountSurfaceVertices(surface)-1
		SetSurfaceColor surface,v,255,0,0,1.0
	Next
Next

EndMax2D
While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	TurnEntity teapot,1,1,0
	RenderWorld
	Flip
Wend
