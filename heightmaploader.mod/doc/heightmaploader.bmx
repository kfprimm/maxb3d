
Strict

Import MaxB3D.Drivers
Import MaxB3D.HeightmapLoader

Graphics 800,600
SeedRnd MilliSecs()

Local light:TLight = CreateLight()

Local pivot:TPivot = CreatePivot()

Local camera:TCamera = CreateCamera(pivot)
MoveEntity camera,0,2,-2

PointEntity camera,pivot

Local pixmap:TPixmap = CreatePixmap(64,64,PF_I8)
For Local y=0 To PixmapHeight(pixmap)-1
	For Local x=0 To PixmapWidth(pixmap)-1
		PixmapPixelPtr(pixmap,x,y)[0]=Rand(0,10)
	Next
Next

Local brush:TBrush = CreateBrush()
SetBrushFX brush, FX_FULLBRIGHT|FX_WIREFRAME

Local hmap0:TMesh=LoadMesh(pixmap)
SetEntityBrush hmap0, brush
SetEntityColor hmap0, 255,0,0

Local hmap1:TMesh=LoadMesh(pixmap)
SetEntityBrush hmap1, brush
SetEntityColor hmap1, 0,255,0
SetEntityPosition hmap1, 0,.5,0

Local hmap2:TMesh=LoadMesh(pixmap)
SetEntityBrush hmap2, brush
SetEntityColor hmap2, 0,0,255
SetEntityPosition hmap2, 0,1,0

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	TurnEntity pivot,0,1,0
	RenderWorld
	Flip
Wend