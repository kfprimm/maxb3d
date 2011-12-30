
Strict

Import "entity.bmx"

Type TCustomEntity Extends TEntity	
	Function Renderer:TCustomRenderer(driver$) Abstract
End Type

Type TCustomRenderer
	Method Render(entity:TEntity) Abstract
End Type
