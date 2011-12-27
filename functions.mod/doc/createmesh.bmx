
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,45,0,0

Local ramp:TMesh=CreateMesh()

Local surface:TSurface=AddMeshSurface(ramp)
AddSurfaceVertex surface,0,0,0
AddSurfaceVertex surface,0,0,1
AddSurfaceVertex surface,4,0,1
AddSurfaceVertex surface,4,0,0
AddSurfaceVertex surface,0,2,0
AddSurfaceVertex surface,0,2,1

AddSurfaceTriangle surface,0,3,2
AddSurfaceTriangle surface,0,2,1
AddSurfaceTriangle surface,0,4,3
AddSurfaceTriangle surface,1,2,5
AddSurfaceTriangle surface,0,1,5
AddSurfaceTriangle surface,0,5,4
AddSurfaceTriangle surface,2,4,5
AddSurfaceTriangle surface,2,3,4

SetEntityPosition ramp,0,-4,10

SetWireframe True

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity ramp,0,1,0
	RenderWorld
	Flip
Wend