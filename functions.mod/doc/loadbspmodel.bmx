
Strict

Import MaxB3D.Drivers

Local cube0:TList=BSPCube()
Local cube1:TList=BSPCube(TMatrix.Transformation(0.625,0,0,,,,-1.5,-0.875,-1.5))
Local cube2:TList=BSPCube(TMatrix.Transformation(.5,0,0,0,-15,0,.75,1.25,.125))

Local tree:TBSPTree=New TBSPTree

tree.Insert cube0,BSP_OUT,BSP_OUT
tree.Insert cube1,BSP_IN,BSP_SPANNING
tree.Reduce
tree.Insert cube2,BSP_OUT,BSP_OUT

Graphics 800,600

Local light:TLight=CreateLight()

Local camera:TCamera=CreateCamera()
SetEntityPosition camera,0,2,-5

Local bsp:TBSPModel=LoadBSPModel(tree)

PointEntity camera,bsp

Repeat
	SetWireFrame KeyDown(KEY_W)
	TurnEntity bsp,1,1,0
	Local info:TRenderInfo=RenderWorld()
	DoMax2D
	DrawText "FPS: "+info.FPS,0,0
	DrawText "Triangles: "+info.Triangles,0,10
	Flip
Until KeyDown(KEY_ESCAPE) Or AppTerminate()

Function BSPCube:TList(matrix:TMatrix=Null)
	If matrix=Null matrix=TMatrix.Identity()
	Local point:TVector[8]
	point[0] = matrix.TransformVector(Vec3( 1.0, 1.0, 1.0))
	point[1] = matrix.TransformVector(Vec3(-1.0, 1.0, 1.0))
	point[2] = matrix.TransformVector(Vec3(-1.0,-1.0, 1.0))
	point[3] = matrix.TransformVector(Vec3( 1.0,-1.0, 1.0))
	point[4] = matrix.TransformVector(Vec3( 1.0, 1.0,-1.0))
	point[5] = matrix.TransformVector(Vec3(-1.0, 1.0,-1.0))
	point[6] = matrix.TransformVector(Vec3(-1.0,-1.0,-1.0))
	point[7] = matrix.TransformVector(Vec3( 1.0,-1.0,-1.0))
	
	Local list:TList=New TList
	list.AddLast New TBSPPolygon.Create([ point[0],point[1],point[2],point[3] ])
	list.AddLast New TBSPPolygon.Create([ point[7],point[6],point[5],point[4] ])
	list.AddLast New TBSPPolygon.Create([ point[0],point[3],point[7],point[4] ])
	list.AddLast New TBSPPolygon.Create([ point[0],point[4],point[5],point[1] ])
	list.AddLast New TBSPPolygon.Create([ point[5],point[6],point[2],point[1] ])
	list.AddLast New TBSPPolygon.Create([ point[3],point[2],point[6],point[7] ])	
	Return list
End Function
