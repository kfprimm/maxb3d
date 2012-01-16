
Strict

Import MaxB3D.Drivers

Graphics 800,600
SeedRnd MilliSecs()

Local camera:TCamera = CreateCamera()
SetEntityPosition camera,0,0,-5

Local cube:TMesh = CreateCube()
SetEntityFX cube,FX_VERTEXCOLOR|FX_FULLBRIGHT

For Local surface:TSurface = EachIn cube
	Local vertices, triangles
	GetSurfaceCounts surface,vertices,triangles
	For Local i = 0 To triangles-1
		SetSurfaceColor surface,i,Rand(0,200),Rand(0,255),Rand(0,255),1
	Next
Next

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity cube,.2,.2,0	 	
	RenderWorld
	Flip
Wend
