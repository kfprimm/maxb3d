
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,1,1,1

Local light:TLight=CreateLight()
SetEntityRotation light,90,0,0

Local grass_tex:TTexture=LoadTexture( "media/mossyground.bmp" )
SetTextureScale grass_tex,3,3

Local terrain:TTerrain=LoadTerrain( "media/height_map.bmp" )
SetTerrainDetail terrain,20,2500
SetEntityScale terrain,1,50,1
SetEntityTexture terrain,grass_tex

SetEntityTexture CreateCube(),grass_tex

While Not KeyDown( KEY_ESCAPE ) And Not AppTerminate()

	If KeyDown( KEY_RIGHT )	TurnEntity camera,0,-1,0
	If KeyDown( KEY_LEFT )	TurnEntity camera,0,1,0
	If KeyDown( KEY_DOWN )	MoveEntity camera,0,0,-1
	If KeyDown( KEY_UP )		MoveEntity camera,0,0,1
	
	If KeyDown(KEY_A) TranslateEntity camera,0,1,0
	If KeyDown(KEY_Z) TranslateEntity camera,0,-1,0
	
	SetWireFrame KeyDown(KEY_W)
	
	'Local x#,y#,z#
	'GetEntityPosition camera,x,y,z
	
	'Local terra_y#=GetTerrainHei(terrain,x#,y#,z#)+5
	
	'PositionEntity camera,x#,terra_y#,z#
	RenderWorld
	DoMax2D	
	DrawText "Use cursor keys to move about the terrain",0,0
	
	Flip
Wend
