
Strict

Import MaxB3D.Drivers

Graphics 800,600 

Local camera:TCamera=CreateCamera() 

Local light:TLight=CreateLight() 
SetEntityRotation light,90,0,0 

Local cube:TMesh=CreateCube() 
SetEntityPosition cube,0,0,5 

Local red=255,green=255,blue=255 

While Not KeyDown( KEY_ESCAPE ) 
	If KeyDown( KEY_1 ) And red>0 Then red:-1 
	If KeyDown( KEY_2 ) And red<255 Then red:+1 
	If KeyDown( KEY_3 ) And green>0 Then green:-1 
	If KeyDown( KEY_4 ) And green<255 Then green:+1 
	If KeyDown( KEY_5 ) And blue>0 Then blue:-1 
	If KeyDown( KEY_6 ) And blue<255 Then blue:+1 
	
	SetEntityColor cube,red,green,blue
	TurnEntity cube,0.1,0.1,0.1 
	RenderWorld 
	
	DoMax2D
	DrawText "Press keys 1-6 to change SetEntityColor red#,green#,blue# values",0,0
	DrawText "Entity Red: "+red,0,20
	DrawText "Entity Green: "+green,0,40
	DrawText "Entity Blue: "+blue,0,60
	
	Flip
Wend 