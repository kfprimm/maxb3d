
Strict

Module MaxB3D.XLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import Prime.libx

Type TMeshLoaderX Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If stream = Null Return False
		
		Local file:TXFile=TXFile.Read(url)
		If file=Null Return False
		file.DumpInfo
					
		Return True
	End Method	
	
	Method Info$()
		Return "DirectX|.x"
	End Method
	Method ModuleName$()
		Return "xloader"
	End Method
End Type
New TMeshLoaderX

