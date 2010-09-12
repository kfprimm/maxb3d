
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()
Local light:TLight=CreateLight()

SetEntityPosition camera,0,0,-5
SetEntityPosition light,-5,-5,0

Local entity:TMesh=CreateCube()
SetEntityRotation entity,45,45,45

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_LEFT) MoveEntity entity,0,0,-.1
	If KeyDown(KEY_RIGHT) MoveEntity entity,0,0,.1
	
	If KeyHit(KEY_SPACE)
		FreeEntity entity
		entity=Null
	EndIf
	
	RenderWorld
	Flip
Wend