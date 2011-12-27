
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-7

Local cube:TMesh=CreateCube()

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_S)
		Local matrix:TMatrix=TMatrix.Scale(2,2,2)
		TransformEntity cube,matrix
	EndIf

	RenderWorld
	Flip
Wend