
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()

Local cube1:TMesh=CreateCube(),cube2:TMesh=CreateCube()

Local sx#,sy#,sz#,ex#,ey#,ez#
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	
	MoveEntity camera,KeyDown(KEY_A)-KeyDown(KEY_D),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	
	If MouseHit(1)
		CameraUnproject camera,MouseX(),MouseY(),0,sx,sy,sz
		CameraUnproject camera,MouseX(),MouseY(),1,ex,ey,ez
		
		SetEntityPosition cube1,sx,sy,sz
		SetEntityPosition cube2,ex,ey,ez
	EndIf
		
	RenderWorld
	DoMax2D
	DrawText "Start: "+sx+","+sy+","+sz,0,0
	DrawText "End:   "+ex+","+ey+","+ez,0,13	
	Flip
Wend
