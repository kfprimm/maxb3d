
Strict

Import MaxB3D.Drivers
Import MaxB3D.MD2Loader

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local gargoyle:TMesh=LoadMesh( "media/Gargoyle/Gargoyle.md2" )

Local garg_tex:TTexture=LoadTexture( "media/Gargoyle/Gargoyle.bmp" )
SetEntityTexture gargoyle,garg_tex

Local walking_seq:TAnimSeq=ExtractMeshAnimSeq(gargoyle,32,46)
SetMeshAnim gargoyle,walking_seq,ANIMATION_LOOP,0.1

SetEntityPosition gargoyle,0,-45,100
SetEntityRotation gargoyle,0,180,0 

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	TurnEntity gargoyle,0,1,0
	UpdateWorld	
	RenderWorld
	Flip
Wend
