
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local smooth=True

Local grid_tex:TTexture=CreateTexture( 32,32,8 )
SetTextureScale grid_tex,10,10
SetBuffer TextureBuffer( grid_tex )
SetColor 0,0,64;DrawRect 0,0,32,32
SetColor 0,0,255;DrawRect 0,0,32,32
SetBuffer BackBuffer()


Local grid_plane:TFlat=CreateFlat()
SetEntityTexture grid_plane,grid_tex
SetEntityBlend grid_plane,1
SetEntityAlpha grid_plane,.6
SetEntityFX grid_plane,FX_FULLBRIGHT

'Local mirror:TMirror=CreateMirror()
Rem
Local pivot=CreatePivot()

p=CreatePivot( p )
cube=CreateCube( p )
ScaleEntity cube,1,1,5
SetAnimKey cube,0
RotateEntity cube,0,120,0
SetAnimKey cube,60
RotateEntity cube,0,240,0
SetAnimKey cube,120
RotateEntity cube,0,0,0
SetAnimKey cube,180
AddAnimSeq p,180

For x=-100 To 100 Step 25
For z=-100 To 100 Step 25
e=CopyEntity( p,pivot )
PositionEntity e,x,5,z
Animate e
Next
Next
FreeEntity cube
End Rem

Local trail_mesh:TMesh=CreateMesh()
Local trail_brush:TBrush=CreateBrush()
SetBrushColor trail_brush,255,0,0
SetBrushBlend trail_brush,3
SetBrushFX trail_brush,FX_FULLBRIGHT
Local trail_surf:TSurface=AddMeshSurface( trail_mesh,trail_brush )
AddSurfaceVertex trail_surf,0,2,0,0,0
AddSurfaceVertex trail_surf,0,0,0,0,1
AddSurfaceVertex trail_surf,0,2,0,0,0
AddSurfaceVertex trail_surf,0,0,0,0,1
AddSurfaceTriangle trail_surf,0,2,3
AddSurfaceTriangle trail_surf,0,3,1
AddSurfaceTriangle trail_surf,0,3,2
AddSurfaceTriangle trail_surf,0,1,3
Local trail_vert=2

Local bike:TMesh=CreateSphere()
ScaleMesh bike,.75,1,2
SetEntityPosition bike,0,1,0
SetEntityShine bike,1
SetEntityColor bike,192,0,255

Local camera:TCamera=CreateCamera()
TurnEntity camera,45,0,0
Local cam_d#=30

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local add_flag=False,add_cnt

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	
	If KeyDown(KEY_A) cam_d=cam_d-1
	If KeyDown(KEY_Z) cam_d=cam_d+1
	
	Local turn=0
	If smooth
		If KeyDown(KEY_LEFT) turn=5
		If KeyDown(KEY_RIGHT) turn=-5
		If turn
			add_cnt=add_cnt+1
			If add_cnt=3
				add_cnt=0
				add_flag=True
			Else
				add_flag=False
			EndIf
		Else If add_cnt
			add_cnt=0
			add_flag=True
		Else
			add_flag=False
		EndIf
	Else
		If KeyHit(KEY_LEFT) turn=90
		If KeyHit(KEY_RIGHT) turn=-90
		If turn Then add_flag=True Else add_flag=False
	EndIf
	
	If turn
		TurnEntity bike,0,turn,0
	EndIf
	
	MoveEntity bike,0,0,1
	
	Local x#,y#,z#
	GetEntityPosition bike,x,y,z
	If add_flag
		AddSurfaceVertex trail_surf,x,2,z,0,0
		AddSurfaceVertex trail_surf,x,0,z,0,1
		AddSurfaceTriangle trail_surf,trail_vert,trail_vert+2,trail_vert+3
		AddSurfaceTriangle trail_surf,trail_vert,trail_vert+3,trail_vert+1
		AddSurfaceTriangle trail_surf,trail_vert,trail_vert+3,trail_vert+2
		AddSurfaceTriangle trail_surf,trail_vert,trail_vert+1,trail_vert+3
		trail_vert=trail_vert+2
	Else
		SetSurfaceCoords trail_surf,trail_vert,x,2,z
		SetSurfaceCoords trail_surf,trail_vert+1,x,0,z
	EndIf
	
	UpdateWorld
	
	SetEntityPosition camera,x-5,0,z
	MoveEntity camera,0,0,-cam_d

'	PositionEntity camera,0,20,0
'	PointEntity camera,bike
	
	RenderWorld
	Flip
Wend

