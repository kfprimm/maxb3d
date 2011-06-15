
Strict

Rem
	bbdoc: Wavefront .OBJ loader for MaxB3D
End Rem
Module MaxB3D.OBJLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Derived from klepto2's loader in the BlitzBasic code archives."

Type TMeshLoaderOBJ Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local matlibs:TMap = CreateMap()
		Local VertexP:TObjVertex[60000]
		Local VertexN:TObjNormal[60000]
		Local VertexT:TObjTexCoord[60000]
		Local Faces:TFaceData[60000]
		Local gname:String = ""
		Local snumber:Int = -1
		Local curmtl:String = ""
		Local Readface:Byte = True
		Local dir:String = ExtractDir(url) + "/"
		If dir = "/" Then dir = ""
		'Print dir
	
		Local VC:Int = 0
		Local VN:Int = 0
		Local VT:Int = 0
		Local FC:Int = 0
		Local SC:Int = 0
		DebugLog "File " + url + " found !!!"
		Local Mesh:TMesh = CreateMesh() 
		Local Surface:TSurface '= CreateSurface(Mesh) 
		While Not Eof(Stream) 
			Local Line:String = ReadLine(Stream).Trim()
			If Line <> "" Then
				
				If Line[0] = Asc("#") Then
					DebugLog(".Obj Comment : " + Line) 
				Else
					'DebugLog("Line : " + Line[0..2] + "-!")
					If Line[0..2].tolower() = "v " Then
						VertexP[VC] = New TObjVertex
						VertexP[VC].GetValues(Line[2..]) 
						VC:+1
					EndIf
					
					If Line[0..3].toLower() = "vn " Then
						VertexN[VN] = New TObjNormal
						VertexN[VN].GetValues(Line[3..]) 
						VN:+1
					EndIf
					
					If Line[0..3].toLower() = "vt " Then
					    VertexT[VT] = New TObjTexCoord
						VertexT[VT].GetValues(Line[3..]) 
						VT:+1
					EndIf	
					
					If Line[0..2].toLower() = "g " Then GName = Line[3..].tolower() 
					If Line[0..2].toLower() = "s " Then
							 snumber = Int(Line[3..]) 
							 Surface = CreateSurface(Mesh)
							' EntityFX Mesh,16
							SC:+1 
					EndIf
					'If Line[0..7].toLower() = "usemtl " Then curmtl = Line[7..].tolower() 
					If Line[0..7].toLower() = "mtllib " Then
						Local L:TObjMtl[] = ParseMTLLib(dir+Line[7..]) 
						For Local Obj:TObjMtl = EachIn L
							MapInsert(Matlibs , Obj.Name , Obj) 
						Next
					EndIf
					If Line[0..7] = "usemtl " Then
						Local Obj:TObjMtl = TObjMtl(MapValueForKey(MatLibs , Line[7..].Trim() ) )
						Print Line[7..]
						If Obj <> Null Then
							If Not surface Then Surface = CreateSurface(Mesh)
							PaintSurface(Surface , Obj.Brush) 
							Print "Surface Painted with " + Obj.name
						EndIf
					EndIf
					If Line[0..2].tolower() = "f " Then
						'Print its
						If Surface = Null Then Surface = CreateSurface(Mesh)
						If Surface Then
							
							Local V:TFaceData[] = ParseFaces(Line[2..])
																		
								For Local i2:Int = 2 To V.Length - 1
									Local V0:Int = AddVertex(Surface , VertexP[V[0].T[0]].X , VertexP[V[0].T[0]].Y ,- VertexP[V[0].T[0]].Z)',VertexT[V[0].T[1]].U,VertexT[V[0].T[1]].V) 
									Local V1:Int = AddVertex(Surface , VertexP[V[i2-1].T[0]].X , VertexP[V[i2-1].T[0]].Y ,- VertexP[V[i2-1].T[0]].Z)',VertexT[V[1].T[1]].U,VertexT[V[1].T[1]].V) 
									Local V2:Int = AddVertex(Surface , VertexP[V[i2].T[0]].X , VertexP[V[i2].T[0]].Y ,- VertexP[V[i2].T[0]].Z)',VertexT[V[2].T[1]].U,VertexT[V[2].T[1]].V) 
									
									If VertexN[0] <> Null
									VertexNormal Surface , V0 , VertexN[V[0].T[2]].NX , VertexN[V[0].T[2]].NY , VertexN[V[0].T[2]].NZ
									VertexNormal Surface , V1 , VertexN[V[i2-1].T[2]].NX , VertexN[V[i2-1].T[2]].NY , VertexN[V[i2-1].T[2]].NZ
									VertexNormal Surface , V2 , VertexN[V[i2].T[2]].NX , VertexN[V[i2].T[2]].NY , VertexN[V[i2].T[2]].NZ
									EndIf
									
									If VertexT[0] <> Null
									VertexTexCoords Surface , V0 , VertexT[V[0].T[1]].U ,1- VertexT[V[0].T[1]].V
									VertexTexCoords Surface , V1 , VertexT[V[i2-1].T[1]].U ,1- VertexT[V[i2-1].T[1]].V
									VertexTexCoords Surface , V2 , VertexT[V[i2].T[1]].U , 1 - VertexT[V[i2].T[1]].V
			 						EndIf
								
									AddTriangle Surface , V0 , V2 , V1
								Next							
							FC:+1
						EndIf
					EndIf	
							
				EndIf
			EndIf
		Wend
		DebugLog "VertexCount : " + VC
		DebugLog "NormalsCount : " + VN
		DebugLog "TexCoordsCount : " + VT
		DebugLog "Faces : " + FC
		DebugLog "Surfs : " + SC
		DebugLog "surfs real : " + CountSurfaces(Mesh) 
		
		For Local V:TObjMtl = EachIn MatLibs.Values()
			Print V.Name
		Next
		
		CloseStream(Stream)
		'FlipMesh Mesh
		UpdateNormals(Mesh)

	End Method
End Type
New TMeshLoaderOBJ

Type TFaceData
	Field T:Int[3]
	Field its:Int
	
	Method GetValues:String(Data:String)
		'Print Data
		Local F:Int[3]
		For Local I:Int = 0 To 2
			'Print "Before : " + Data
			Local FL:Int = Data.Find("/")
			If I < 2 Then
				T[I] = Int(Data[..FL])-1
				Data = Data[FL+1..]
			Else
				T[i] = Int(Data[..Data.Find(" ")])-1
			EndIf
			'Print "After : " + Data
		Next
		'Print Data		
		Return Data[Data.Find(" ")..]	
	End Method
End Type

Function ParseFaces:TFaceData[](Data:String) 
	Local Data1:String[] = Data.Split(" ")
	
	Local S:Int = 0
	If Data1[0] = "" Then S = 1
	Local FData:TFaceData[Data1.Length-S]
	
	For Local I:Int = S To Data1.Length - 1
		FData[I-S] = New TFaceData
		Local D2:String[] = Data1[I].Split("/") 
		'DebugLog "~q"+D2[1]+"~q" 
		FData[I-S].T[0] = Int(D2[0])-1 
		FData[I-S].T[1] = Int(D2[1])-1 
		FData[I-S].T[2] = Int(D2[2])-1 
	Next
	Return FData
End Function
	
Type TObjNormal
	Field NX# , NY# , NZ#
	
	Method GetValues(Data:String) 		
		Local F:Float[3]
		For Local I:Int = 0 To 2
			'Print "Before : " + Data
			Local FL:Int = Data.Find(" ")
			If I < 2 Then
				f[I] = Float(Data[..FL])
			Else
				f[i] = Float(Data) 
			EndIf
			Data = Data[FL+1..]
			'Print "After : " + Data
		Next
		NX = F[0]
		NY = F[1]
		NZ = F[2]
		'DebugLog ("X:"+X+" Y:"+Y + " Z:"+Z)
		
	End Method
End Type

Type TObjTexCoord
	Field U# , v#
	
	Method GetValues(Data:String)
		'DebugLog "OrigUV : " + Data
		Local F:Float[2]
		For Local I:Int = 0 To 1
			'Print "Before : " + Data
			Local FL:Int = Data.Find(" ")
			If I < 1 Then
				f[I] = Float(Data[..FL])
			Else
				f[i] = Float(Data) 
			EndIf
			Data = Data[FL+1..]
			'Print "After : " + Data
		Next
		u = F[0]
		v = F[1]
		'DebugLog ("X:"+U+" Y:"+V)
	End Method	
End Type	

Type TObjVertex
	Field X# , Y# , Z#
	'Field NX# , NY# , NZ#
	'Field u# , v#
	
	Method GetValues(Data:String) 
			Local F:Float[3]
			For Local I:Int = 0 To 2
				'Print "Before : " + Data
				Local FL:Int = Data.Find(" ")
				If I < 2 Then
					f[I] = Float(Data[..FL])
				Else
					f[i] = Float(Data) 
				EndIf
				Data = Data[FL+1..]
				'Print "After : " + Data
			Next
			X = F[0]
			Y = F[1]
			Z = F[2]
			'DebugLog ("X:"+X+" Y:"+Y + " Z:"+Z)		
	End Method	
End Type

Type TObjMTL
	Field name:String
	Field Brush:TBrush
	Field Texture:TTexture
End Type

Function ParseMTLLib:TObjMTL[](Path:String)
	Local matStream:TStream = ReadStream(Path) 
	Local dir:String = ExtractDir(Path) + "/"
	If dir = "/" Then dir = ""
	If Not matStream Then Return Null
	Local MatLib:TObjMtl[0]
	Local CMI:Int = -1
	While Not Eof(matStream)
		Local Line:String = ReadLine(MatStream) 
		If Line[0..7] = "newmtl " Then
			MatLib = MatLib[..Matlib.Length + 1]
			CMI = MatLib.Length-1
			MatLib[CMI] = New TObjMtl
			MatLib[CMI].Name = Line[7..].Trim() 
			MatLib[CMI].Brush = CreateBrush() 
			BrushFX MatLib[CMI].Brush,4+16
			DebugLog("Matname : " + Matlib[CMI].Name)
		EndIf
		'Colours
		If Line[0..3] = "Kd " Then
			Local Data:String = Line[3..].Trim()+" "
			Local F:Float[3]
			For Local I:Int = 0 To 2
				'Print "Before : " + Data
				Local FL:Int = Data.Find(" ")
				If I < 2 Then
					f[I] = Float(Data[..FL])
				Else
					f[i] = Float(Data) 
				EndIf
				Data = Data[FL+1..]
				'Print "After : " + Data
			Next
			BrushColor(MatLib[CMI].Brush , F[0] * 255 , F[1] * 255 , F[2] * 255) 
			DebugLog("MatColor : " +  (F[0] * 255) +","+(F[1] * 255)+","+(F[2] * 255))
		EndIf
		
		If Line[0..2] = "d " Then
			'BrushAlpha(MatLib[CMI].Brush , Float(Line[2..]))
			DebugLog("MatAlpha : " + Float(Line[2..]) ) 
		EndIf
		
		If Line[0..3] = "Tr " Then
			'BrushAlpha(MatLib[CMI].Brush , Float(Line[2..])) 
			DebugLog("MatAlpha : " + Float(Line[2..]) ) 
		EndIf 
		
		If Line[0..7] = "map_Kd " Then
			MatLib[CMI].Texture = LoadTexture(dir+Line[7..].Trim(),4) 
			If MatLib[CMI].Texture <> Null BrushTexture(MatLib[CMI].Brush , MatLib[CMI].Texture) 
			DebugLog("MatTexture : " + Line[7..].Trim() ) 
		EndIf
	Wend
	
	Return MatLib
End Function