
Strict

Import MaxB3D.Drivers

Graphics 800,600
HideMouse()
SeedRnd MilliSecs()

Local sphere:TMesh = CreateSphere()
'SetEntityPickMode sphere, PICKMODE_SPHERE

For Local k = 0 To 99
	Local model:TEntity = CopyEntity(sphere)
	SetEntityColor model, Rand(255), Rand(255), Rand(255)
	SetEntityShine model, Rnd()
	
	Local rad# = Rnd(1, 2)
	SetEntityRadius model, rad
	SetEntityScale model, rad, rad, rad
	TurnEntity model, Rand(360), Rand(360), 0
	MoveEntity model, 0, 0, Rand(20)+20
Next

FreeEntity sphere

Local light:TLight = CreateLight()
TurnEntity light, 45, 45, 0

Local camera:TCamera = CreateCamera()
SetCameraRange camera, 0.1, 1000

Local zoom# = 1, entity:TEntity

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_A) zoom :* 1.1
	If KeyDown(KEY_Z) zoom :/ 1.1
	SetCameraZoom camera, zoom
	
	Local x = MouseX(), y = MouseY()	
	
	If y<32 TurnEntity camera,-2,0,0
	If y>GraphicsHeight()-32 TurnEntity camera,2,0,0
	
	If x<32 TurnEntity camera,0,2,0
	If x>GraphicsWidth()-32 TurnEntity camera,0,-2,0
	
	Local picks:TPick[] = WorldPick(camera, [x, y])
		
	Rem
	e=CameraPick( camera,x,y )

	If e<>entity

		If entity Then EntityAlpha entity,1

		entity=e

	EndIf
	End Rem

	If entity SetEntityAlpha entity,Sin( MilliSecs() )*.5+.5
	
	RenderWorld	
	DoMax2D
	DrawRect x,y-3,1,7
	DrawRect x-3,y,7,1
	
	Flip
Wend
