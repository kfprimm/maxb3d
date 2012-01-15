
Strict

Import MaxB3D.Drivers

Const T_DUDE=1,T_WALLS=2

Type TDude
	Field mesh:TMesh
	Field speed#
End Type

Const DUDE_COUNT = 50

Graphics 800,600

SetCollisions T_DUDE,T_DUDE,COLLISION_METHOD_POLYGON,COLLISION_RESPONSE_SLIDE
SetCollisions T_DUDE,T_WALLS,COLLISION_METHOD_POLYGON,COLLISION_RESPONSE_SLIDE

Local walls:TMesh=CreateCube()
SetEntityColor walls,0,32,192
SetEntityType walls,T_WALLS
FitMesh walls,-40,0,-40,80,80,80
FlipMesh walls

Local col:TMesh=CreateCube()
FitMesh col,-1,0,-1,2,40,2
SetEntityColor col,255,0,0
SetEntityAlpha col,.75
SetEntityType col,T_WALLS
For Local k=30 To 359+30 Step 60
	Local t:TEntity=CopyEntity( col )
	SetEntityRotation t,0,k,0
	MoveEntity t,0,0,34
Next
FreeEntity col

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,50,-46
TurnEntity camera,45,0,0

Local light:TLight=CreateLight()
TurnEntity light,45,45,0

Local player:TMesh=CreateCube()
SetEntityColor player,0,255,0
SetEntityPosition player,0,3,0
SetEntityRadius player,2
SetEntityType player,T_DUDE

Local nose:TMesh=CreateCube( player )
SetEntityColor nose,0,255,0
SetEntityScale nose,.5,.5,.5
SetEntityPosition nose,0,0,1.5

Rem
sphere=CreateSphere()
EntityShininess sphere,.5
EntityType sphere,T_DUDE

an#=0
an_step#=360.0/n_dudes

For k=1 To n_dudes
	d.Dude=New Dude
	d\entity=CopyEntity( sphere )
	EntityColor d\entity,Rnd(255),Rnd(255),Rnd(255)
	TurnEntity d\entity,0,an,0
	MoveEntity d\entity,0,2,37
	ResetEntity d\entity
	d\speed=Rnd( .4,.49 )
	an=an+an_step
Next

FreeEntity sphere

ok=True	

End Rem

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	If KeyDown(KEY_LEFT) TurnEntity player,0,5,0
	If KeyDown(KEY_RIGHT) TurnEntity player,0,-5,0
	If KeyDown(KEY_UP) MoveEntity player,0,0,.5
	If KeyDown(KEY_DOWN) MoveEntity player,0,0,-.5
	If KeyDown(KEY_A) TranslateEntity player,0,.2,0
	If KeyDown(KEY_Z) TranslateEntity player,0,-.2,0
	
	Rem
	For d.Dude=Each Dude
		If EntityDistance( player,d\entity )>2
			PointEntity d\entity,player
			If KeyDown(15) TurnEntity d\entity,0,180,0
		EndIf
		MoveEntity d\entity,0,0,d\speed
	Next
	End Rem
	UpdateWorld
	RenderWorld
	
	Rem
	Goto skip
	If ok
		'
		'sanity check!
		'make sure nothings gone through anything else...
		'
		For d=Each Dude
			If EntityY( d\entity )<.9
				ok=False
				bad$="Bad Dude Y: "+EntityY( d\entity )
			EndIf
			For d2.Dude=Each Dude
				If d=d2 Then Exit
				If EntityDistance( d\entity,d2\entity )<.9
					ok=False
					bad$="Dude overlap!"
				EndIf
			Next
		Next
	EndIf
	
	If ok
		Text 0,0,"Dudes OK"
	Else
		CameraClsColor camera,255,0,0
		Text 0,0,bad$
	EndIf
	.skip
	End Rem
	
	Flip
Wend
