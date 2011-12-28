
Strict

Import MaxB3D.Drivers

Const SEGS=128,WIDTH#=4.0,DEPTH#=.125

Graphics 800,600

Local mesh:TMesh=CreateMesh()
SetEntityFX mesh, FX_NOCULLING

Local surf:TSurface=AddMeshSurface( mesh )

For Local k=0 To segs
	Local x#=Float(k)*WIDTH/SEGS-WIDTH/2
	Local u#=Float(k)/SEGS
	AddSurfaceVertex surf,x,1,0,u,0
	AddSurfaceVertex surf,x,-1,0,u,1
Next

For Local k=0 To segs-1
	AddSurfaceTriangle surf,k*2,k*2+2,k*2+3
	AddSurfaceTriangle surf,k*2,k*2+3,k*2+1
Next

Local b:TBrush=CreateBrush( "media/b3dlogo.jpg" )
SetSurfaceBrush surf,b

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-5

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	Local ph#=MilliSecs()/4
	For Local k=0 To CountSurfaceVertices(surf)-1
		Local x#,y#,z#
		GetSurfaceCoords surf,k,x,y,z
		z=Sin(ph+x*300)*DEPTH
		SetSurfaceCoords surf,k,x,y,z
	Next
	UpdateMeshNormals mesh
	
	If KeyDown(KEY_OPENBRACKET) TurnEntity camera,0,1,0
	If KeyDown(KEY_CLOSEBRACKET) TurnEntity camera,0,-1,0
	If KeyDown(KEY_A) MoveEntity camera,0,0,.1
	If KeyDown(KEY_Z) MoveEntity camera,0,0,-.1
	
	If KeyDown(KEY_LEFT) TurnEntity mesh,0,1,0,True
	If KeyDown(KEY_RIGHT) TurnEntity mesh,0,-1,0,True
	If KeyDown(KEY_UP) TurnEntity mesh,1,0,0,True
	If KeyDown(KEY_DOWN) TurnEntity mesh,-1,0,0,True
	
	RenderWorld
	Flip
Wend
