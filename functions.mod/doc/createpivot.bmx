
Strict

Framework MaxB3D.Drivers

Graphics 640,480,0

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-10

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local pivot:TPivot=CreatePivot()
If pivot=Null end
Local planet:TMesh=CreateSphere(16,pivot)
SetEntityPosition planet,5,0,0

While Not KeyDown(KEY_ESCAPE)
	TurnEntity pivot,0,1,0
	
	RenderWorld
	Flip
Wend

