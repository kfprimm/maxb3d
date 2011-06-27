
Strict

Rem
	bbdoc: Math library for MaxB3D
End Rem
Module MaxB3D.Math
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import sys87.Math3D
Import "collision.cpp"
Import "geom.cpp"
Import "misc.cpp"
Import "std.cpp"
Import "tree.cpp"


Extern
	Function C_UpdateNormals(no_tris:Int,no_verts:Int,tris:Int Ptr,vert_coords:Float Ptr,vert_norms:Float Ptr)

	Function C_NewMeshInfo:Byte Ptr()
	Function C_DeleteMeshInfo(mesh_info:Byte Ptr)
	Function C_AddSurface(mesh_info:Byte Ptr,no_tris:Int,no_verts:Int,tris:Int Ptr,verts:Float Ptr,surf:Int)
	
	Function C_CreateColTree:Byte Ptr(mesh_info:Byte Ptr)
	Function C_DeleteColTree(col_tree:Byte Ptr)
	
	Function C_CreateCollisionInfoObject:Byte Ptr(vec_a:Byte Ptr,vec_b:Byte Ptr,vec_radius:Byte Ptr)
	Function C_UpdateCollisionInfoObject(col_info:Byte Ptr,dst_radius:Float,ax:Float,ay:Float,az:Float,bx:Float,by:Float,bz:Float)
	Function C_DeleteCollisionInfoObject(col_info:Byte Ptr)
	
	Function C_CreateCollisionObject:Byte Ptr()
	Function C_DeleteCollisionObject(coll:Byte Ptr)
	
	Function C_Pick:Int(col_info:Byte Ptr,line:Byte Ptr,radius:Float,coll:Byte Ptr,dst_tform:Byte Ptr,mesh_col:Byte Ptr,pick_geom:Int)
	
	Function C_CollisionDetect:Int(col_info:Byte Ptr,coll:Byte Ptr,tform:Byte Ptr,col_tree:Byte Ptr,method_no:Int)
	Function C_CollisionResponse:Int(col_info:Byte Ptr,coll:Byte Ptr,response:Int)
	Function C_CollisionFinal:Int(col_info:Byte Ptr)
		
	Function C_CollisionPosX:Float()
	Function C_CollisionPosY:Float()
	Function C_CollisionPosZ:Float()
	Function C_CollisionX:Float()
	Function C_CollisionY:Float()
	Function C_CollisionZ:Float()
	Function C_CollisionNX:Float()
	Function C_CollisionNY:Float()
	Function C_CollisionNZ:Float()
	Function C_CollisionTime:Float()
	Function C_CollisionSurface:Int()
	Function C_CollisionTriangle:Int()
	
	Function C_CreateVecObject:Byte Ptr(x:Float,y:Float,z:Float)
	Function C_DeleteVecObject(v:Byte Ptr)
	Function C_UpdateVecObject(vec:Byte Ptr,x:Float,y:Float,z:Float)
	Function C_VecX:Float(vec:Byte Ptr)
	Function C_VecY:Float(vec:Byte Ptr)
	Function C_VecZ:Float(vec:Byte Ptr)
	
	Function C_CreateLineObject:Byte Ptr(ox:Float,oy:Float,oz:Float,dx:Float,dy:Float,dz:Float)
	Function C_DeleteLineObject(line:Byte Ptr)
	Function C_UpdateLineObject(line:Byte Ptr,ox:Float,oy:Float,oz:Float,dx:Float,dy:Float,dz:Float)

	Function C_CreateMatrixObject:Byte Ptr(vec_i:Byte Ptr,vec_j:Byte Ptr,vec_k:Byte Ptr)
	Function C_DeleteMatrixObject(mat:Byte Ptr)
	Function C_UpdateMatrixObject(mat:Byte Ptr,vec_i:Byte Ptr,vec_j:Byte Ptr,vec_k:Byte Ptr)
	
	Function C_CreateTFormObject:Byte Ptr(mat:Byte Ptr,vec_v:Byte Ptr)
	Function C_DeleteTFormObject(tform:Byte Ptr)
	Function C_UpdateTFormObject(tform:Byte Ptr,mat:Byte Ptr,vec_v:Byte Ptr)
					
End Extern

