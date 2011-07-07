
Strict

Framework MaxB3D.Drivers

Graphics 640,480,0

Local camera:TCamera=CreateCamera()

Local sphere:TMesh=CreateSphere( 32 )
SetEntityPosition sphere,-2,0,5

Local cone:TMesh=CreateCone( 32 )
SetEntityPosition cone,2,0,5

Local red=127,green=127,blue=127

While Not KeyDown( KEY_ESCAPE )
	
	If KeyDown( KEY_1 ) And red>0     red=red-1
	If KeyDown( KEY_2 ) And red<255   red=red+1
	If KeyDown( KEY_3 ) And green>0   green=green-1
	If KeyDown( KEY_4 ) And green<255 green=green+1
	If KeyDown( KEY_5 ) And blue>0    blue=blue-1
	If KeyDown( KEY_6)  And blue<255  blue=blue+1
	
	SetAmbientLight red,green,blue
	
	RenderWorld
	
	DoMax2D
	DrawText "Press keys 1-6 to change SetAmbientLight red#,green#,blue# values",0,0
	DrawText "Ambient Red: "+red,0,20
	DrawText "Ambient Green: "+green,0,40
	DrawText "Ambient Blue: "+blue,0,60
	
	Flip
Wend
