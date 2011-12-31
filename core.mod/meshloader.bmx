
Strict

Import MaxB3D.Logging
Import "mesh.bmx"

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/meshloader",message
End Function

Public

Type TMeshLoader
	Global _start:TMeshLoader
	Field _next:TMeshLoader
	
	Method New()
		Local loader:TMeshLoader=_start
		If loader=Null _start=Self Return
		While loader._next<>Null
			loader=loader._next			
		Wend
		loader._next=Self 
	End Method
	
	Function Load(config:TWorldConfig,mesh:TMesh,url:Object)
		Local loader:TMeshLoader=_start
		Local stream:TStream=TStream(url)
		If stream=Null stream=ReadStream(stream)
		While loader<>Null
			If stream SeekStream stream,0
?Not Debug
			Try
?
				If loader.Run(config,mesh,stream,url) Return True
?Not Debug
			Catch a$
				ModuleLog "Exception throw from "+loader.ModuleName()+"."
			EndTry		
?	
			loader=loader._next
		Wend
		If stream CloseStream stream
		Return False
	End Function
	
	Method Run(config:TWorldConfig,mesh:TMesh,stream:TStream,url:Object) Abstract
	
	Method Info$() Abstract
	Method ModuleName$() Abstract
	
	Function List$[]()
		Local loaders$[], loader:TMeshLoader=_start
		While loader<>Null
			loaders:+ [loader.Info()]
			loader=loader._next
		Wend
		Return loaders
	End Function
	
	Function ReadCString$(stream:TStream)
		Local str$,c=ReadByte(stream)
		While c<>0
			str:+Chr(c)
			c=ReadByte(stream)
		Wend
		Return str.Trim()
	End Function
	
	Function WriteCString(stream:TStream,str$)
		For Local i=0 To str.length-1
			WriteByte stream,str[i]
		Next
		WriteByte stream,0
	End Function
End Type
