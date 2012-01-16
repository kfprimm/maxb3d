
Strict

Import MaxB3D.Drivers
Import MaxB3D.MonkeyHeadLoader

Graphics 800,600

Local light:TLight = CreateLight()

Local camera:TCamera = CreateCamera()

Local head:TMesh = CreateMonkeyHead()
SetEntityPosition head,0,0,10
UnweldMesh head

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_SPACE)
		For Local surface:TSurface = EachIn head
			Local vertices, triangles
			GetSurfaceCounts surface,vertices,triangles
			For Local i = 0 To triangles-1
				Local v[3]
				GetSurfaceTriangle surface,i,v[0],v[1],v[2]
				For Local j = 0 To 2
					Local x#,y#,z#
					Local nx#,ny#,nz#
					
					GetSurfaceCoords surface,v[j],x,y,z
					GetSurfaceNormal surface,v[j],nx,ny,nz
					
					SetSurfaceCoords surface,v[j],x-nx*.1,y-ny*.1,z-nz*.1
				Next
			Next
		Next
	EndIf
	
	TurnEntity head,0,.5,0
	
	RenderWorld
	DoMax2D
	Local verts, tris
	GetMeshCounts head,verts,tris
	DrawText "Triangles: "+tris,0,0
	DrawText "Vertices:  "+verts,0,15
	Flip
Wend
