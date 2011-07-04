
Strict

Import MaxB3D.Drivers
Import MaxB3D.Newton

Graphics 800,600
SetCollisionDriver NewtonCollisionDriver()
SeedRnd MilliSecs()

Local light:TLight=CreateLight()

Local floor_body:TBody=CreateBody()
SetEntityBox floor_body,-32,-.05,-32,64,0.1,64

Local floor_mesh:TMesh=CreateCube(floor_body)
SetEntityScale floor_mesh,32,.05,32

For Local z=0 To 9
	For Local x=0 To 9
		For Local y=0 To 9
			Local cube_body:TBody=CreateBody()
			SetEntityPosition cube_body,(x-5)*2.1,.3+(2*y),(z-5)*2.1
			SetEntityBox cube_body,-1,-1,-1,2,2,2
			SetBodyMass cube_body, 4
			
			Local cube_mesh:TMesh=CreateCube(cube_body)
			SetEntityColor cube_mesh,Rand(255),Rand(255),Rand(255)
		Next
	Next
Next

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,3,-4

PointEntity camera, floor_mesh

Local run_physics=True

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	FlyCam camera
	
	If KeyHit(KEY_P) run_physics=Not run_physics
	
	If run_physics UpdateWorld ,4
	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0
	DrawText "Triangles: "+info.Triangles,0,13
	
	Flip
Wend

Function FlyCam(camera:TCamera)
	Global _lastx,_lasty
	Local pitch#,yaw#,roll#
	Local halfx=GraphicsWidth()/2,halfy=GraphicsHeight()/2
	GetEntityRotation camera,pitch,yaw,roll
	
	MoveEntity camera,KeyDown(KEY_A)-KeyDown(KEY_D),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	SetEntityRotation camera,pitch-(halfy-MouseY()),yaw+(halfx-MouseX()),0
	MoveMouse halfx,halfy
End Function