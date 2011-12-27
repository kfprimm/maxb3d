
Strict

Import MaxB3D.Drivers

Graphics 800,600

Local pixmap:TPixmap=CreatePixmap(64,64,PF_RGBA8888)
For Local y=0 To PixmapHeight(pixmap)-1
	For Local x=0 To PixmapWidth(pixmap)-1
		Local color=$FFFFFF
		If (x>31 And y<32) Or (y>31 And x<32) color=$FF40C0FF
		WritePixel pixmap,x,y,color
	Next
Next
Local texture:TTexture=LoadTexture(pixmap)
SetTextureScale texture,.125,.125

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-6

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local segs = 16, rebuild = True, wireframe = False

Local brush:TBrush=CreateBrush()
SetBrushTexture brush, texture

Local pivot:TPivot=CreatePivot()
Local cube:TMesh,sphere:TMesh,cylinder:TMesh,cone:TMesh

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_W)
		wireframe = Not wireframe
		SetWireFrame wireframe
	EndIf
	
	If KeyHit(KEY_OPENBRACKET)
		If segs>3 segs=segs-1
		rebuild=True
	ElseIf KeyHit(KEY_CLOSEBRACKET)
		If segs<100 segs=segs+1
		rebuild=True
	EndIf
	
	If rebuild
		If cube FreeEntity cube
		If sphere FreeEntity sphere
		If cylinder FreeEntity cylinder
		If cone FreeEntity cone
		
		cube=CreateCube( pivot )
		SetEntityBrush cube,brush
		SetEntityPosition cube,-3,0,0
		
		cylinder=CreateCylinder( segs,True,pivot )
		SetEntityBrush cylinder,brush
		SetEntityPosition cylinder,1,0,0
		
		cone=CreateCone( segs,True,pivot )
		SetEntityBrush cone,brush
		SetEntityPosition cone,-1,0,0
		
		sphere=CreateSphere( segs,pivot )
		SetEntityBrush sphere,brush
		SetEntityPosition sphere,3,0,0
		
		rebuild=False
	EndIf
	
	If KeyDown(KEY_LEFT) TurnEntity pivot,0,-3,0
	If KeyDown(KEY_RIGHT) TurnEntity pivot,0,+3,0
	If KeyDown(KEY_UP) TurnEntity pivot,-3,0,0
	If KeyDown(KEY_DOWN) TurnEntity pivot,+3,0,0
	If KeyDown(KEY_A) TranslateEntity pivot,0,0,-.2
	If KeyDown(KEY_Z) TranslateEntity pivot,0,0,+.2


	RenderWorld
	DoMax2D
	DrawText "Segs="+segs+" - [] to adjust, 'W' for wireframe",0,0
	
	Flip
Wend