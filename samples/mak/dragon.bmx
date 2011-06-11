
Strict

Import MaxB3D.Drivers
Import MaxB3D.MD2Loader

Graphics 800,600

Local room_texture:TTexture=LoadTexture( "media/chorme-2.bmp" )
SetTextureScale room_texture,1.0/3,1.0/3

Local room:TMesh=CreateCube()
SetEntityTexture room,room_texture
SetEntityAlpha room,.4
SetEntityFX room,1
FitMesh room,-250,0,-250,500,500,500
FlipMesh room

'Local mirror:TMirror=CreateMirror()

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local camera:TCamera=CreateCamera()
Local cam_xr#=30,cam_yr#=0,cam_zr#=0,cam_z#=-100

Local dragon_texture:TTexture=LoadTexture( "media/dragon.bmp" )
Local dragon:TMesh=LoadMesh( "media/dragon.md2" )
SetEntityTexture dragon,dragon_texture
SetEntityPosition dragon,0,25,0
TurnEntity dragon,0,150,0

Local anim_idle:TAnimSeq=ExtractMeshAnimSeq(dragon,0,40)
Local anim_run:TAnimSeq=ExtractMeshAnimSeq(dragon,40,46)
Local anim_attack:TAnimSeq=ExtractMeshAnimSeq(dragon,46,54)
Local anim_paina:TAnimSeq=ExtractMeshAnimSeq(dragon,54,58)
Local anim_painb:TAnimSeq=ExtractMeshAnimSeq(dragon,58,62)
Local anim_painc:TAnimSeq=ExtractMeshAnimSeq(dragon,62,66)
Local anim_jump:TAnimSeq=ExtractMeshAnimSeq(dragon,66,72)
Local anim_flip:TAnimSeq=ExtractMeshAnimSeq(dragon,72,84)

SetMeshAnim dragon,anim_idle,ANIMATION_LOOP,.05

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()

	If KeyDown(KEY_RIGHT)
		cam_yr=cam_yr-2
	Else If KeyDown(KEY_LEFT)
		cam_yr=cam_yr+2
	EndIf
	
	If KeyDown(KEY_UP)
		cam_xr=cam_xr+2
		If cam_xr>90 cam_xr=90
	Else If KeyDown(KEY_DOWN)
		cam_xr=cam_xr-2
		If cam_xr<5 cam_xr=5
	EndIf
	
	If KeyDown(KEY_S)
		cam_zr=cam_zr+2
	Else If KeyDown(KEY_X)
		cam_zr=cam_zr-2
	EndIf
	
	If KeyDown(KEY_A)
		cam_z=cam_z+1;If cam_z>-10 cam_z=-10
	Else If KeyDown(KEY_Z)
		cam_z=cam_z-1;If cam_z<-180 cam_z=-180
	EndIf
	
	SetEntityPosition camera,0,0,0
	SetEntityRotation camera,cam_xr,cam_yr,cam_zr
	MoveEntity camera,0,0,cam_z

	UpdateWorld
	RenderWorld
	BeginMax2D
	DrawText "Use arrows keys to pan, A/Z to zoom",0,0
	EndMax2D
	
	Flip
Wend