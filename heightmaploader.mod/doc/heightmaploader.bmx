
Strict

Import MaxB3D.Drivers
Import MaxB3D.HeightmapLoader

Graphics 800,600
SeedRnd MilliSecs()

Local light:TLight=CreateLight()

Local pivot:TPivot=CreatePivot()

Local camera:TCamera=CreateCamera(pivot)
MoveEntity camera,0,2,-2

PointEntity camera,pivot

Local pixmap:TPixmap=CreatePixmap(64,64,PF_I8)
For Local y=0 To PixmapHeight(pixmap)-1
	For Local x=0 To PixmapWidth(pixmap)-1
		PixmapPixelPtr(pixmap,x,y)[0]=Rand(0,10)
	Next
Next
SetWireframe True

Local hmap:TMesh=LoadMesh(pixmap)
SetEntityFX hmap,FX_FULLBRIGHT

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity pivot,0,1,0
	RenderWorld
	Flip
Wend