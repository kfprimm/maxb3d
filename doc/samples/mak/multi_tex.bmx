
Strict

Import MaxB3D.Drivers

Graphics 800,600
SetAmbientLight 0,0,0

Local logo:TTexture=LoadTexture("media/blitzlogo.bmp")

Local pixmap:TPixmap=CreatePixmap(64,64,PF_RGBA8888)
For Local y=0 To 63
	For Local x=0 To 63
		Local data:Int Ptr=Int Ptr(PixmapPixelPtr(pixmap,x,y))
		If x<32 And y<32 data[0]=$FFFFFFFF
		If x>31 And y<32 data[0]=$FF808080
		If x<32 And y>31 data[0]=$FF808080
		If x>31 And y>31 data[0]=$FFFFFFFF
	Next
Next

Local grid:TTexture=LoadTexture(pixmap)
SetTextureScale grid,.5,.5

Local env:TTexture=LoadTexture("media/spheremap.bmp",TEXTURE_COLOR|TEXTURE_ALPHA|TEXTURE_SPHEREMAP)

Local cube:TMesh=CreateCube()
SetEntityTexture cube,logo,0,0
SetEntityTexture cube,grid,1,0
SetEntityTexture cube,env,2,0
UpdateMeshNormals cube

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,0,-4

Local light1:TLight=CreateLight()
TurnEntity light1,45,45,0
SetEntityColor light1,255,0,0

Local light2:TLight=CreateLight()
TurnEntity light2,-45,45,0
SetEntityColor light2,0,255,0

Local light3:TLight=CreateLight()
TurnEntity light3,45,-45,0
SetEntityColor light3,0,0,255

Local blend1=BLEND_MULTIPLY,blend2=BLEND_MULTIPLY,blend3=BLEND_ALPHA
SetTextureBlend logo,blend1
SetTextureBlend grid,blend2
SetTextureBlend env,blend3

Local offset#

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()
	If KeyHit(KEY_F1)
		blend1=blend1+1
		If blend1=4 blend1=0
		SetTextureBlend logo,blend1
	EndIf
	If KeyHit(KEY_F2)
		blend2=blend2+1
		If blend2=4 blend2=0
		SetTextureBlend grid,blend2
	EndIf
	If KeyHit(KEY_F3)
		blend3=blend3+1
		If blend3=4 blend3=0
		SetTextureBlend env,blend3
	EndIf
	If KeyDown(KEY_A)
		TranslateEntity camera,0,0,.1
	EndIf
	If KeyDown(KEY_Z)
		TranslateEntity camera,0,0,-.1
	EndIf

	offset=offset-.01
	SetTexturePosition logo,offset,0
	
	TurnEntity cube,.1,.2,.3
	
	RenderWorld
	DoMax2D
	DrawText "(F1) TextureBlend 1="+mode(blend1),0,0
	DrawText "(F2) TextureBlend 2="+mode(blend2),0,13
	DrawText "(F3) TextureBlend 3="+mode(blend3),0,26

	Flip
Wend

Function mode$( mode )
	Select mode
	Case BLEND_NONE
		Return "BLEND_NONE"
	Case BLEND_ALPHA
		Return "BLEND_ALPHA"
	Case BLEND_MULTIPLY
		Return "BLEND_MULTIPLY"
	Case BLEND_ADD
		Return "BLEND_ADD"
	End Select
	Return "Unknown"
End Function
