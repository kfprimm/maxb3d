
Strict

Import MaxB3D.Drivers
Import MaxB3D.B3DLoader

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityColor camera,0,0,255
SetEntityPosition camera,-3.5,6,-3.5
PointEntity camera,[0.0,3.0,0.0]

Local zombie:TMesh=LoadMesh("media/zombie.b3d")
SetEntityScale zombie,.3,.3,.3

Local walk1:TAnimSeq=ExtractMeshAnimSeq(zombie,2,20)
Local walk2:TAnimSeq=ExtractMeshAnimSeq(zombie,22,36)
Local attacked1:TAnimSeq=ExtractMeshAnimSeq(zombie,38,47)
Local attacked2:TAnimSeq=ExtractMeshAnimSeq(zombie,48,57)
Local blown:TAnimSeq=ExtractMeshAnimSeq(zombie,59,75)
Local dying:TAnimSeq=ExtractMeshAnimSeq(zombie,78,88)
Local die:TAnimSeq=ExtractMeshAnimSeq(zombie,91,103)
Local kick:TAnimSeq=ExtractMeshAnimSeq(zombie,106,115)
Local punch:TAnimSeq=ExtractMeshAnimSeq(zombie,117,128)
Local headbutt:TAnimSeq=ExtractMeshAnimSeq(zombie,129,136)
Local idle1:TAnimSeq=ExtractMeshAnimSeq(zombie,137,169)
Local idle2:TAnimSeq=ExtractMeshAnimSeq(zombie,170,200)

SetMeshAnim zombie,walk1

' temp
Function MakeBones(bone:TBone)
	Local sphere:TMesh=CreateSphere(2,bone)
	For Local bone2:TBone=EachIn bone._childlist
		MakeBones bone2
	Next
End Function

For Local bone:TBone=EachIn zombie._childlist
	MakeBones bone
Next

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	SetWireFrame KeyDown(KEY_W)
	
	If KeyDown(KEY_D) UpdateWorld
	Local info:TRenderInfo=RenderWorld()
	BeginMax2D
	DrawText "Triangles: "+info.Triangles,0,0
	DrawText "Frame: "+zombie.GetFrame(),0,14
	EndMax2D
	Flip
Wend

