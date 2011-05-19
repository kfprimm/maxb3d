
Strict

Module MaxB3D.XLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Type TMeshLoaderX Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local file:TXFile=TXFile.Load(url)
		If file=Null Return False
		
		' TODO: Use the XFile data to construct the mesh!
		Return True
	End Method	
End Type
New TMeshLoaderX

Type TXFile
	Field _data:TXData[]
	Function Load:TXFile(url:Object)
		Local stream:TStream=TStream(url)
		If stream=Null stream=ReadStream(url)
		If stream=Null Return Null
		
		If ReadString(stream,4)="xof " 
			CloseStream stream
			Return Null
		EndIf
		
		Local major=Int(ReadString(stream,2)),minor=Int(ReadString(stream,2))
		Local format$=ReadString(stream,4)
		Local float_size=Int(ReadString(stream,4))
		
		If format<>"txt "
			CloseStream stream
			Return Null
		EndIf
		
		Local data_str$[]=TXData.Parse(ReadString(stream,StreamSize(stream)-16))
		
		Local file:TXFile=New TXFile
		For Local data$=EachIn data_str
			file.AddData(data)
		Next
		Return file
	End Function
	
	Method AddData:TXData(str$)
		Local pos
		While str[pos]<>" "[0]
			pos:+1
		Wend
		Local data:TXMaterial
		Select str[0..pos].Trim()
		Case "Header"
		Case "Material"
			Local material:TXMaterial=New TXMaterial
			
			data=material
		End Select
		Return data
	End Method
	
	Method ObjectEnumerator:Object()
		Return TXDataEnumerator.Create(Self)
	End Method
End Type

Type TXDataEnumerator
	Field _file:TXFile,_pos
	
	Function Create:TXDataEnumerator(file:TXFile)
		Local enum:TXDataEnumerator=New TXDataEnumerator
		enum._file=file
		Return enum
	End Function
	
	Method HasNext()
		Return _pos<_file._data.length
	End Method
	Method NextObject:Object()
		_pos:+1
		Return _file._data[_pos-1]
	End Method
End Type

Type TXMaterial Extends TXData
	Function GetID$()
		Return "Material"
	End Function
	Function GetUUID$()
		Return "3D82AB4D-62DA-11CF-AB39-0020AF71E433"
	End Function
End Type

Type TXData
	Field name$
	Field member:Object[]
	
	Function GetID$() Abstract
	Function GetUUID$() Abstract
	
	Function Parse$[](str$)
		Local result$[]
		Local pos=0
		Repeat
			Local oldpos=pos
			While str[pos]<>"{"[0]
				pos:+1
			Wend
			pos=ParseInternal(str,pos)
			
			result=result[..result.length+1]
			result[result.length-1]=str[oldpos..pos]
		Until pos>=str.length-1
		Return result
	End Function
	
	Function ParseInternal(str$,pos)
		Local open_count=1,in_string
		pos:+1
		While open_count>0
			If str[pos]="~q" in_string=Not in_string
			If Not in_string open_count:+(str[pos]="{"[0])-(str[pos]="}"[0])					
			pos:+1
		Wend
		Return pos
	End Function

	Function FromString:TXData(str$)
	End Function
End Type
