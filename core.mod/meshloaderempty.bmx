
Strict

Import "meshloader.bmx"

Type TMeshLoaderEmpty Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Return String(url)="//empty"
	End Method
	
	Method Info$()
		Return "Empty"
	End Method
	Method ModuleName$()
		Return "core/meshloaderempty"
	End Method
End Type
New TMeshLoaderEmpty
