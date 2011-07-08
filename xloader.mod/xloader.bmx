
Strict

Module MaxB3D.XLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import sys87.libx

Type TMeshLoaderX Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local file:TXFile=TXFile.Read(url)
		If file=Null Return False
		file.DumpInfo
					
		Return True
	End Method	
	
	Method Name$()
		Return "DirectX"
	End Method
	Method ModuleName$()
		Return "xloader"
	End Method
End Type
New TMeshLoaderX

