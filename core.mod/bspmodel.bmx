
Strict

Import "entity.bmx"
Import Prime.BSP

Type TBSPModel Extends TEntity
	Field _tree:TBSPTree
	
	Method Lists[]()
		Return Super.Lists() + [WORLDLIST_BSPMODEL, WORLDLIST_RENDER]
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		Local model:TBSPModel = TBSPModel(entity)
		SetTree model.GetTree()
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TBSPModel(parent:TEntity=Null)
		Return TBSPModel(Super.Copy_(parent))
	End Method
	
	Method GetRenderTree:TBSPTree(eye:TRay)
		Return _tree
	End Method
	
	Method GetTree:TBSPTree()
		Return _tree
	End Method
	Method SetTree(tree:TBSPTree)
		_tree=tree
	End Method
End Type
