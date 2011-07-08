
Strict

Framework PUB.FreeProcess
Import BRL.FileSystem
Import BRL.StandardIO

Const INDEX_FILE$=".docs_and_samples_index"
Const BMXPATH$="/home/kfprimm/BlitzMax"

Assert BMXPATH,"Path to BlitzMax install must be set!"

Type TSourceFile
	Field path$,time
End Type

Local file_paths$[]
For Local m$=EachIn EnumerateModules()
	file_paths:+EnumerateFiles(m)
Next
file_paths:+EnumerateFiles("samples",False)
file_paths.Sort

Local current_files:TSourceFile[file_paths.length]
For Local i=0 To current_files.length-1
	current_files[i]=New TSourceFile
	current_files[i].path=file_paths[i]
	current_files[i].time=FileTime(file_paths[i])
Next

Local index_files:TSourceFile[]
Local stream:TStream=ReadStream(INDEX_FILE)
If stream<>Null
	Local count=Int(ReadLine(stream))
	index_files=New TSourceFile[count]
	For Local i=0 To count-1
		index_files[i]=New TSourceFile
		index_files[i].path=ReadLine(stream)
		index_files[i].time=Int(ReadLine(stream))
	Next
	CloseStream stream
EndIf

Local files:TSourceFile[],blank:TSourceFile=New TSourceFile
For Local file:TSourceFile=EachIn current_files
	Local indexed:TSourceFile=blank
	For Local i:TSourceFile=EachIn index_files
		If i.path=file.path indexed=i;Exit
	Next
	If indexed.time<>file.time files:+[file]
Next

If files.length>0
	Print "Building "+files.length+" files..."
	Local errors$[],built:TSourceFile[]
	For Local f:TSourceFile=EachIn files
		Local process:TProcess=CreateProcess(BMXPATH+"/bin/bmk makeapp -d -o "+StripAll(f)+".debug ~q"+f.path+"~q",0)
		Local error
		While process.Status()
			If process.err.ReadLine()
				error=True
				If process.Status() process.Terminate;Exit
			EndIf
		Wend
		If error
			errors:+[f.path]
		Else
			built:+[f]
		EndIf
	Next
	
	Local new_index$[]
	For Local i:TSourceFile=EachIn index_files
		Local add=True
		For Local f:TSourceFile=EachIn built
			If i.path=f.path add=False;Exit
		Next
		If add new_index:+[i.path]
	Next
	For Local f:TSourceFile=EachIn built
		new_index:+[f.path]
	Next
	
	If new_index.length>0
		Local stream:TStream=WriteStream(INDEX_FILE)
		WriteLine stream,String(new_index.length)
		For Local f$=EachIn new_index
			WriteLine stream,f
			WriteLine stream,FileTime(f)
		Next
		CloseStream stream
	EndIf
	
	Print 
	Print "Errored:"
	Print "~n".Join(errors)
Else
	Print "No files to build!"
EndIf

Function EnumerateModules$[]()
	Local mods$[]
	For Local f$=EachIn LoadDir(".")
		If FileType(f)=FILETYPE_DIR And ExtractExt(f)="mod" mods:+[f]
	Next
	Return mods
End Function

Function EnumerateFiles$[](dir$,is_mod=True)
	If is_mod
		Return EnumerateDir(dir+"/doc")
	Else
		Local files$[]
		For Local d$=EachIn LoadDir(dir)
			files:+EnumerateDir(dir+"/"+d)
		Next		
		Return files
	EndIf	
End Function

Function EnumerateDir$[](dir$)
	Local files$[]
	For Local f$=EachIn LoadDir(dir)
		If FileType(dir+"/"+f)=FILETYPE_FILE And ExtractExt(f)="bmx" files:+[dir+"/"+f]
	Next
	Return files
End Function