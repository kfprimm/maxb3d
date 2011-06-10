
Strict

Rem
	bbdoc: Blitz3D model file utilities
End Rem
Module MaxB3D.B3DUtils
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.Stream
Import BRL.EndianStream

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "b3dutils",message
End Function

Public

Type TTEXSChunk Extends TChunk
	Field file$
	Field flags=TEXTURE_COLOR|TEXTURE_MIPMAP,blend=BLEND_MULTIPLY
	Field x_pos#,y_pos#
	Field x_scale#=1.0,y_scale#=1.0
	Field rotation#=0.0
	
	Method Read(stream:TStream,length Var)			
		file=ReadCString(stream)
		flags=ReadInt(stream);blend=ReadInt(stream)
		x_pos=ReadFloat(stream);y_pos=ReadFloat(stream)
		x_scale=ReadFloat(stream);y_scale=ReadFloat(stream)
		rotation=ReadFloat(stream)
		length:-GetLength()
	End Method
	
	Method Write(stream:TStream)
		WriteCString stream,file
		WriteInts stream,[flags,blend],2
		WriteFloats stream,[x_pos,y_pos],2
		WriteFloats stream,[x_scale,y_scale],2
		WriteFloat stream,rotation
		Return GetLength()
	End Method
	
	Method GetLength()
		Return (file.length+1)+(2*4)+(2*4)+(2*4)+4
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"TEXS"
		WriteDump stream,level,"File: "+file
	End Method
End Type

Type TBRUSChunk Extends TChunk
	Field name$
	Field red#=1.0,green#=1.0,blue#=1.0,alpha#=1.0
	Field shininess#
	Field blend=BLEND_ALPHA,fx
	Field texture_id[],n_texs
	
	Method Read(stream:TStream,length Var) 
		name=ReadCString(stream)
		red=ReadFloat(stream);green=ReadFloat(stream);blue=ReadFloat(stream);alpha=ReadFloat(stream)
		shininess=ReadFloat(stream)
		blend=ReadInt(stream);fx=ReadInt(stream)
		texture_id=texture_id[..n_texs]
		For Local i=0 To n_texs-1
			texture_id[i]=ReadInt(stream)
		Next		
		length:-GetLength()
	End Method
	
	Method Write(stream:TStream)
		WriteCString stream,name
		WriteFloats stream,[red,green,blue,alpha],4
		WriteFloat stream,shininess
		WriteInts stream,[blend,fx],3
		WriteInts stream,texture_id,texture_id.length
		For Local i=texture_id.length To n_texs-1
			WriteInt stream,-1
		Next
		Return GetLength()
	End Method
	
	Method GetLength()
		Return (name.length+1)+(4*4)+4+(2*4)+(n_texs*4)
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"BRUS"
		WriteDump stream,level,"Name: "+name
	End Method
End Type

Type TVRTSChunk Extends TChunk
	Field xyz#[]
	Field nxyz#[],rgba#[]
	Field tex_coords#[,][]
	
	Method Read(stream:TStream,length Var) 
		Local flags=ReadInt(stream)
		Local tex_coord_sets=ReadInt(stream)
		Local tex_coord_set_size=ReadInt(stream)
		length:-12
		Local vertexsize=(3*4)+((flags&1)>0)*(3*4)+((flags&2)>0)*(4*4)+(tex_coord_sets*tex_coord_set_size*4)
		Local vertexcnt=length/vertexsize
		
		xyz=xyz[..vertexcnt*3]
		If flags&1 nxyz=nxyz[..vertexcnt*3]
		If flags&2 rgba=rgba[..vertexcnt*4]
		tex_coords=tex_coords[..vertexcnt]
		
		For Local i=0 To vertexcnt-1
			xyz[i*3+0]=ReadFloat(stream);xyz[i*3+1]=ReadFloat(stream);xyz[i*3+2]=ReadFloat(stream)
			If flags&1 nxyz[i*3+0]=ReadFloat(stream);nxyz[i*3+1]=ReadFloat(stream);nxyz[i*3+2]=ReadFloat(stream)
			If flags&2 rgba[i*3+0]=ReadFloat(stream);rgba[i*3+1]=ReadFloat(stream);rgba[i*3+2]=ReadFloat(stream);rgba[i*3+3]=ReadFloat(stream)
			tex_coords[i]=New Float[tex_coord_sets,tex_coord_set_size]
			For Local j=0 To tex_coord_sets-1
				For Local k=0 To tex_coord_set_size-1
					tex_coords[i][j,k]=ReadFloat(stream)
				Next
			Next
		Next	
		length:-vertexsize*vertexcnt
	End Method
	
	Method Count()
		Return xyz.length/3
	End Method
	
	Method Flags()
		Return (nxyz<>Null)|(rgba<>Null)*2
	End Method
	
	Method SetCount()
		Return tex_coords[0].Dimensions()[0]
	End Method
	
	Method SetSize()
		Return tex_coords[0].Dimensions()[1]
	End Method
	
	Method Write(stream:TStream)
		WriteInt stream,Flags()
		WriteInt stream,SetCount()
		WriteInt stream,SetSize()
		For Local i=0 To xyz.length/3-1
			WriteFloats stream,Varptr xyz[i*3],3
			If nxyz WriteFloats stream,Varptr nxyz[i*3],3
			If rgba WriteFloats stream,Varptr rgba[i*4],4
			For Local j=0 To SetCount()-1
				WriteFloats stream,Varptr tex_coords[i][j,0],SetSize()
			Next
		Next
		Return GetLength()
	End Method
	
	Method GetLength()
		Return (3*4)+(3*4)+(((nxyz<>Null)+(rgba<>Null))*4)+(SetCount()*SetSize()*4)
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"VRTS"
	End Method
End Type

Type TTRISChunk Extends TChunk
	Field brush_id
	Field vertex_id[]
	
	Method Read(stream:TStream,length Var) 
		brush_id=ReadInt(stream)
		length:-4
		vertex_id=New Int[length/4]
		For Local i=0 To vertex_id.length-1
			vertex_id[i]=ReadInt(stream)
		Next
		length:-GetLength()
	End Method
	
	Method Write(stream:TStream)
		WriteInt stream,brush_id
		WriteInts stream,vertex_id,vertex_id.length
		Return GetLength()
	End Method
	
	Method GetLength()
		Return (vertex_id.length+1)*4
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"TRIS"
	End Method
End Type

Type TMESHChunk Extends TChunk
	Field brush_id
	Field vrts:TVRTSChunk=New TVRTSChunk
	Field tris:TTRISChunk[]
	
	Method Read(stream:TStream,length Var)
		brush_id=ReadInt(stream)
		length:-4
		While length>0
			Local chunklength,tag$=ReadTag(stream,chunklength)
			length:-chunklength+8
			Select tag
			Case "VRTS"
				vrts.Read stream,chunklength
			Case "TRIS"
				tris=tris[..tris.length+1]
				tris[tris.length-1]=New TTRISChunk			
				tris[tris.length-1].Read stream,chunklength
			Default
				SeekStream stream,StreamPos(stream)+chunklength
			End Select
		Wend
	End Method
	
	Method Write(stream:TStream)
		Local length
		WriteInt stream,brush_id
		vrts.Write stream
		For Local tri:TTRISChunk=EachIn tris
			tri.Write stream
		Next
		Return length
	End Method
	
	Method GetLength()
		Return
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"MESH"
		WriteDump stream,level,"Brush ID: "+brush_id
		DumpChunk vrts,stream,level+1
		DumpChunks tris,stream,level+1
	End Method
End Type

Type TBONEChunk Extends TChunk
	Field vertex_id[]
	Field weight#[]
	
	Method Read(stream:TStream,length Var)	
		vertex_id=New Int[length/8]
		weight=New Float[length/8]
		For Local i=0 To length/8-1
			vertex_id[i]=ReadInt(stream)
			weight[i]=ReadFloat(stream)
		Next
		length=0
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"BONE"
	End Method
End Type

Type TKEYSChunk Extends TChunk
	Field frame[]
	Field position#[]
	Field scale#[]
	Field rotation#[]
	
	Method Read(stream:TStream,length Var)
		Local flags=ReadInt(stream)
		Local size=((flags&1<>0)*3+(flags&2<>0)*3+(flags&4<>0)*4)*4+4
		Local count=(length-4)/size
		frame=New Int[count]
		If flags&1 position=New Float[count*3]
		If flags&2 scale=New Float[count*3]
		If flags&4 rotation=New Float[count*4]
		For Local i=0 To count-1
			frame[i]=ReadInt(stream)
			If flags&1 ReadFloats stream,position,3
			If flags&2 ReadFloats stream,scale,3
			If flags&4 ReadFloats stream,rotation,4
			length:-size
		Next
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"KEYS"
	End Method
End Type

Type TANIMChunk Extends TChunk
	Field flags
	Field frames
	Field fps#
	
	Method Read(stream:TStream,length Var)
		flags=ReadInt(stream)
		frames=ReadInt(stream)
		fps=ReadFloat(stream)
		length=0
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"ANIM"
		WriteDump stream,level,"Flags: "+flags
		WriteDump stream,level,"Frames: "+frames
		WriteDump stream,level,"FPS: "+fps
	End Method
End Type

Type TNODEChunk Extends TChunk
	Field name$
	Field position#[3]
	Field scale#[3]
	Field rotation#[4]
	Field kind:TChunk
	Field keys:TKEYSChunk[],node:TNODEChunk[]
	Field anim:TANIMChunk
	
	Method Read(stream:TStream,length Var)
		name=ReadCString(stream)
		position[0]=ReadFloat(stream);position[1]=ReadFloat(stream);position[2]=ReadFloat(stream)
		scale[0]=ReadFloat(stream);scale[1]=ReadFloat(stream);scale[2]=ReadFloat(stream)
		rotation[0]=ReadFloat(stream);rotation[1]=ReadFloat(stream);rotation[2]=ReadFloat(stream);rotation[3]=ReadFloat(stream)
		length:-(name.length+1)+(3*4)+(3*4)+(4*4)
		
		While length>0
			Local chunklength,tag$=ReadTag(stream,chunklength)
			length:-chunklength+8
			Select tag
			Case "MESH"				
				kind=New TMESHChunk
				kind.Read(stream,chunklength)
			Case "BONE"
				kind=New TBONEChunk
				kind.Read(stream,chunklength)
			Case "KEYS"
				Local chunk:TKEYSChunk=New TKEYSChunk
				chunk.Read(stream,chunklength)
				keys=keys[..keys.length+1]
				keys[keys.length-1]=chunk
			Case "NODE"
				Local chunk:TNODEChunk=New TNODEChunk
				chunk.Read(stream,chunklength)
				node=node[..node.length+1]
				node[node.length-1]=chunk
			Case "ANIM"
				anim=New TANIMChunk
				anim.Read(stream,chunklength)
			Default
				DebugLog "Invalid tag: "+tag
				SkipChunk stream,chunklength
			End Select
		Wend
	End Method
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"NODE"
		WriteDump stream,level,"Name: "+name
		DumpChunk kind,stream,level+1
		DumpChunks keys,stream,level+1
		DumpChunks node,stream,level+1
		DumpChunk anim,stream,level+1
	End Method
End Type

Type TBB3DChunk Extends TChunk
	Field version=1
	Field texs:TTEXSChunk[]
	Field brus:TBRUSChunk[]
	Field node:TNODEChunk
	
	Function Load:TBB3DChunk(url:Object)
		Local stream:TStream=LittleEndianStream(ReadStream(url))
		If stream=Null Return Null
		
		Local chunk:TBB3DChunk,length,tag$=ReadTag(stream,length)
		If tag="BB3D"
			chunk=New TBB3DChunk
			chunk.Read stream,length
		EndIf
		CloseStream stream
		Return chunk
	End Function
	
	Method Dump(stream:TStream,level=0)
		WriteDump stream,level,"BB3D"
		WriteDump stream,level,"Version: "+version
		DumpChunks texs,stream,1
		DumpChunks brus,stream,1
		DumpChunk node,stream,1
		stream.Flush
	End Method
	
	Method Save(url:Object)
		Local stream:TStream=WriteStream(url)
		BeginTag(stream,"BB3D")
		EndTag(stream,Write(stream))
	End Method
	
	Method Read(stream:TStream,length Var)
		version=ReadInt(stream)
		length:-4
		While length>0
			Local chunklength,tag$=ReadTag(stream,chunklength)
			length:-chunklength+8
			Select tag
			Case "TEXS"
				While chunklength>0
					texs=texs[..texs.length+1]
					texs[texs.length-1]=New TTEXSChunk
					texs[texs.length-1].Read stream,chunklength
				Wend
			Case "BRUS"
				Local n_texs=ReadInt(stream)
				chunklength:-4	
				While chunklength>0
					brus=brus[..brus.length+1]
					brus[brus.length-1]=New TBRUSChunk
					brus[brus.length-1].n_texs=n_texs
					brus[brus.length-1].Read stream,chunklength
				Wend
			Case "NODE"
				node=New TNODEChunk
				node.Read stream,chunklength
			Default				
				SkipChunk stream,chunklength
			End Select
		Wend
	End Method
	
	Method Write(stream:TStream)
		WriteInt stream,version
		Local totallength=4
		If texs And brus
			BeginTag(stream,"TEXS")
			Local length
			For Local i=0 To texs.length-1
				length:+texs[i].Write(stream)
			Next
			EndTag(stream,length)
			totallength:+length+8
		EndIf
		If brus
			BeginTag(stream,"BRUS")
			Local n_texs
			For Local i=0 To brus.length-1
				n_texs=Max(n_texs,brus[i].texture_id.length)
			Next
			Local length
			WriteInt stream,n_texs
			For Local i=0 To brus.length-1
				brus[i].n_texs=n_texs
				length:+brus[i].Write(stream)
			Next
			EndTag(stream,length)
			totallength:+length+8
		EndIf
		Return totallength
	End Method
End Type

Type TChunk
	Global tagstack[]
	Method Read(stream:TStream,length Var) Abstract	
	Method Dump(stream:TStream,level=0) Abstract
	
	Function WriteDump(stream:TStream,level,info$)
		WriteLine stream,info[-level..]
	End Function
	
	Function DumpChunk(chunk:TChunk,stream:TStream,level)
		If chunk=Null Return
		chunk.Dump stream,level
	End Function
	
	Function DumpChunks(chunks:TChunk[],stream:TStream,level)
		If chunks.length=0 Return
		For Local chunk:TChunk=EachIn chunks
			chunk.Dump stream,level
		Next
	End Function
	
	Function ReadTag$(stream:TStream,length Var)
		Local tag$=ReadString(stream,4)
		length=ReadInt(stream)
		Return tag
	End Function
	
	Function BeginTag(stream:TStream,tag$)
		WriteString stream,tag
		WriteInt stream,-1
		tagstack=[StreamPos(stream)-4]+tagstack
	End Function
	
	Function EndTag(stream:TStream,length)
		Local oldpos=StreamPos(stream)
		SeekStream stream,tagstack[0]
		tagstack=tagstack[1..tagstack.length]		
		WriteInt stream,length
		SeekStream stream,oldpos
	End Function
	
	Function SkipChunk(stream:TStream,length)
		SeekStream stream,StreamPos(stream)+length
	End Function
	
	Function ReadCString$(stream:TStream)
		Local str$,c=ReadByte(stream)
		While c<>0
			str:+Chr(c)
			c=ReadByte(stream)
		Wend
		Return str
	End Function
	
	Function ReadFloats(stream:TStream,array:Float Ptr,length)
		For Local i=0 To length-1
			array[i]=ReadFloat(stream)
		Next
	End Function
		
	Function WriteFloats(stream:TStream,array:Float Ptr,length)
		For Local f#=0 To length-1
			WriteFloat stream,f
		Next
	End Function
	
	Function WriteInts(stream:TStream,array:Int Ptr,length)
		For Local i=0 To length-1
			WriteInt stream,i
		Next
	End Function
	
	Function WriteCString(stream:TStream,str$)
		For Local i=0 To str.length-1
			WriteByte stream,str[i]
		Next
		WriteByte stream,0
	End Function
End Type
