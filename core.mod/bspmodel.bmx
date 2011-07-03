
Strict

Import "entity.bmx"
Import sys87.BSP

Type TBSPModel Extends TEntity
	Field _tree:TBSPTree
	
	Method Copy:TBSPModel(parent:TEntity=Null)
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