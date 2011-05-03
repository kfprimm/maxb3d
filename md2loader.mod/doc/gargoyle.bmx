
Strict

Import MaxB3D.Drivers
Import MaxB3D.Loaders

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local gargoyle:TMesh=LoadMesh( "gargoyle.md2" )
Local garg_tex:TTexture=LoadTexture( "gargoyle.bmp" )
SetEntityTexture gargoyle,garg_tex

'AnimateMesh gargoyle,1,0.1,32,46

SetEntityPosition gargoyle,0,-45,100
SetEntityRotation gargoyle,0,180,0

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	UpdateWorld
	RenderWorld
	Flip
Wend