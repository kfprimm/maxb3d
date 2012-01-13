
Strict

Import BRL.Map
Import "entity.bmx"

Type TCustomEntity Extends TEntity
	Global _renderermap:TMap = New TMap
	Field _renderer:Object
	
	Method Lists[]()
		Return Super.Lists() + [WORLDLIST_CUSTOM, WORLDLIST_RENDER]
	End Method
	
	Method Copy:TCustomEntity(parent:TEntity=Null)
		Return TCustomEntity(Super.Copy_(parent))
	End Method
	
	Function Register(name$, driver$, renderer:Object)
		_renderermap.Insert name+"___"+driver, renderer
	End Function
	
	Method Renderer:Object(driver$)
		If _renderer = Null
			Local renderer:Object = _renderermap.ValueForKey(Name()+"___"+driver)
			If renderer _renderer = New renderer
		EndIf
		Return _renderer
	End Method 
	
	Function Name$() Abstract
End Type

