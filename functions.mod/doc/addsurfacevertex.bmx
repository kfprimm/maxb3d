
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local mesh:TMesh=CreateMesh()
Local surface:TSurface=AddMeshSurface(mesh)

AddSurfaceVertex surface,-5,-5,0,  0,0
AddSurfaceVertex surface, 5,-5,0,  1,0
AddSurfaceVertex surface, 0, 5,0,0.5,1

AddSurfaceTriangle surface,0,2,1

Local pixmap:TPixmap=CreatePixmap(256,256,PF_RGB888)
For Local y=0 To PixmapHeight(pixmap)-1
	For Local x=0 To PixmapWidth(pixmap)-1
		PixmapPixelPtr(pixmap,x,y)[0]=Rand(0,255)
	Next
Next

Local texture:TTexture=LoadTexture(pixmap)
SetEntityTexture mesh,texture

Local camera:TCamera=CreateCamera()
MoveEntity camera,0,0,-7

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	RenderWorld
	Flip
Wend
