
Strict

Import MaxB3D.Drivers
Import MaxB3D.Loaders

Graphics 640,480

Local camera:TCamera=CreateCamera()

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local drum:TMesh=LoadMesh("media/oil-drum/oildrum.3ds")

Local width#,height#,depth#
GetMeshSize drum,width,height,depth

SetEntityPosition drum,0,0,depth*2

While Not KeyDown( KEY_ESCAPE )
	RenderWorld
	Flip
Wend
