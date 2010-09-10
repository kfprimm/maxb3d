
Strict

Import BRL.LinkedList
Import BRL.FileSystem
Import BRL.Retro
'#################################################################################################
' 3DS Loader Include by M.Rauch 29.07.2005
' MR_3DS.bmx
' Tested with Cinema4D CE6 3DS V3.0 Export  
' Animation KeyFrame Interpolation are not finished !
'#################################################################################################

'----------------------------------------------------------------------

Global _3DSMaterialList:TList=CreateList()
Global _3DSMeshList:TList=CreateList()
Global _3DSAnimationList:TList=CreateList()

Global _3DSMaterialLast:T3DSMaterial
Global _3DSMeshLast:T3DSMesh
Global _3DSAnimationLast:T3DSAnimation

'----------------------------------------------------------------------

Private

Global DebugLog3DSOn=0

'----- Entry point (Primary Chunk at the start of the file ----------------

Const           PRIMARY           =$4D4D

'----- Main Chunks --------------------------------------------------------

Const           EDIT3DS           =$3D3D  ' Start of our actual objects
Const           KEYF3DS           =$B000  ' Start of the keyframe information

'----- General Chunks -----------------------------------------------------

Const           VERSION           =$0002 'ok
Const           MESH_VERSION      =$3D3E
Const           KFVERSION         =$0005
Const           COLOR_F           =$0010
Const           COLOR_24          =$0011
Const           LIN_COLOR_24      =$0012
Const           LIN_COLOR_F       =$0013
Const           INT_PERCENTAGE    =$0030
Const           FLOAT_PERC        =$0031
Const           MASTER_SCALE      =$0100
Const           IMAGE_FILE        =$1100
Const           AMBIENT_LIGHT     =$2100

'----- Object Chunks -----------------------------------------------------

Const           NAMED_OBJECT      =$4000 'ok
Const           OBJ_MESH          =$4100 'ok
Const           MESH_VERTICES     =$4110 'ok
Const           VERTEX_FLAGS      =$4111
Const           MESH_FACES        =$4120 'ok
Const           MESH_MATER        =$4130 'ok
Const           MESH_TEX_VERT     =$4140 'ok
Const           MESH_XFMATRIX     =$4160 'ok Local coordinate system
Const           MESH_COLOR_IND    =$4165
Const           MESH_TEX_INFO     =$4170
Const           HEIRARCHY         =$4F00 '? skip

'----- Material Chunks ---------------------------------------------------

Const           MATERIAL          =$AFFF 'ok
Const           MAT_NAME          =$A000 'ok
Const           MAT_AMBIENT       =$A010 'ok
Const           MAT_DIFFUSE       =$A020 'ok
Const           MAT_SPECULAR      =$A030 'ok
Const           MAT_SHININESS     =$A040 '...
Const           MAT_FALLOFF       =$A052 'ok
Const           MAT_EMISSIVE      =$A080 'ok
Const           MAT_SHADER        =$A100
Const           MAT_TEXMAP        =$A200 'ok
Const           MAT_TEXFLNM       =$A300 'ok

Const           OBJ_LIGHT         =$4600
Const           OBJ_CAMERA        =$4700

'----- KeyFrames Chunks --------------------------------------------------

Const           ANIM_HEADER       =$B00A 'skip
Const           ANIM_OBJ          =$B002 'ok
Const     		ANIM_S_E_TIME     =$B008 'ok
Const           ANIM_NAME         =$B010 'ok
Const 			ANIM_PIVOT        =$B013 'ok
Const           ANIM_POS          =$B020 'ok
Const           ANIM_ROT          =$B021 'ok 
Const           ANIM_SCALE        =$B022 'ok
Const           ANIM_HIERARCHYPOS =$B030 'ok

'----------------------------------------------------------------------

Public

'----------------------------------------------------------------------

Type T3DSColour
 Field r:Float
 Field g:Float
 Field b:Float

 Method Set(red:Float,green:Float,blue:Float)
  r=red
  g=green
  b=blue
 End Method
End Type

'----------------------------------------------------------------------

Type T3DSMaterial
 Field Name$ 
 Field AmbientColour:T3DSColour
 Field DiffuseColour:T3DSColour 
 Field SpecularColour:T3DSColour
 Field EmissiveColour:T3DSColour

 Field TextureFile$ 
 Function Create:T3DSMaterial()
  Local M:T3DSMaterial=New T3DSMaterial
  M.Name$="NoName"
  M.AmbientColour=New T3DSColour
  M.DiffuseColour=New T3DSColour
  M.SpecularColour=New T3DSColour
  M.EmissiveColour=New T3DSColour
  M.TextureFile$=""
  Return M
 End Function
End Type

'----------------------------------------------------------------------

Type T3DSVert 'Vertex
 Field x:Float
 Field y:Float
 Field z:Float
End Type

Type T3DSFace '3 Vertices of a triangle make a face
 Field a:Int,b:Int,c:Int 
 Field Material:T3DSMaterial
End Type

Type T3DSTex 'Texture UV coords
 Field u:Float
 Field v:Float
End Type

'----------------------------------------------------------------------

Type T3DSMesh
  Field MeshName$
  Field NumVerts:Int
  Field VertArray:T3DSVert[]  
  Field NumFaces:Int
  Field FaceArray:T3DSFace[]
  Field NumTex:Int
  Field TexArray:T3DSTex[]

  Field OriginX:Float
  Field OriginY:Float
  Field OriginZ:Float

  Field AchseXX:Float
  Field AchseXY:Float
  Field AchseXZ:Float

  Field AchseYX:Float
  Field AchseYY:Float
  Field AchseYZ:Float

  Field AchseZX:Float
  Field AchseZY:Float
  Field AchseZZ:Float

  Function Create:T3DSMesh()
   Local M:T3DSMesh=New T3DSMesh
   M.MeshName$="NoName"
   M.NumVerts=0
   M.NumTex=0
   M.NumFaces=0
   Return M
  End Function

  Method AddVertex(V:T3DSVert)
   VertArray=VertArray[..NumVerts+1]
   VertArray[NumVerts]=V
   NumVerts=NumVerts+1
  End Method 

  Method AddTex(T:T3DSTex)
   TexArray=TexArray[..NumTex+1]
   TexArray[NumTex]=T
   NumTex=NumTex+1
  End Method 

  Method AddFace(F:T3DSFace)
   FaceArray=FaceArray[..NumFaces+1]
   FaceArray[NumFaces]=F
   NumFaces=NumFaces+1
  End Method 

  Method GetVertex:T3DSVert(Index:Int)
   Return VertArray[Index]
  End Method 

  Method GetTex:T3DSTex(Index:Int)
   Return TexArray[Index]
  End Method 

  Method GetFace:T3DSFace(Index:Int)
   Return FaceArray[Index]
  End Method 

  Method SetFaceMaterial(Index:Int,Mat:T3DSMaterial)
   FaceArray[Index].Material=Mat
  End Method 

  Method SetOri(X:Float,Y:Float,Z:Float)
   OriginX=X
   OriginY=Y
   OriginZ=Z
  End Method 

End Type

'----------------------------------------------------------------------

Type T3DSAnimPosition
 Field iFrame:Int
 Field x:Float
 Field y:Float
 Field z:Float
End Type

Type T3DSAnimScale
 Field iFrame:Int
 Field x:Float
 Field y:Float
 Field z:Float
End Type

Type T3DSAnimRotation
 Field iFrame:Int
 Field rotation_rads:Float
 Field Axis_x:Float 'Axis Vector for Rotation
 Field Axis_y:Float
 Field Axis_z:Float
End Type

'----------------------------------------------------------------------

Type T3DSAnimation
 
 Field HierarchyParent:Int
 Field HierarchyPos:Int

 Field ObjName:String

 Field iPosKeys:Int
 Field PositionArray:T3DSAnimPosition[]

 Field iRotKeys:Int
 Field RotArray:T3DSAnimRotation[]

 Field iScaleKeys:Int
 Field ScaleArray:T3DSAnimScale[]
	
 Function Create:T3DSAnimation()
  Local A:T3DSAnimation=New T3DSAnimation
  A.HierarchyParent=-1 'no parent
  A.iPosKeys = 0
  A.iRotKeys = 0
  A.iScaleKeys = 0
  Return A
 End Function

 Method SetPosKeys(PosKeys:Int)
  PositionArray=PositionArray[..PosKeys+1]
  iPosKeys=PosKeys
  Local i
  For i=0 To iPosKeys-1
   PositionArray[i]=New T3DSAnimPosition
  Next
 End Method

 Method SetRotKeys(RotKeys:Int)
  RotArray=RotArray[..RotKeys+1]
  iRotKeys=RotKeys
  Local i
  For i=0 To iRotKeys-1
   RotArray[i]=New T3DSAnimRotation
  Next
 End Method

 Method SetScaleKeys(ScaleKeys:Int)
  ScaleArray=ScaleArray[..ScaleKeys+1]
  iScaleKeys=ScaleKeys
  Local i
  For i=0 To iScaleKeys-1
   ScaleArray[i]=New T3DSAnimScale
  Next
 End Method

End Type

'----------------------------------------------------------------------

Private

Type T3DSChunk 
 Field ID:Int
 Field length:Int
 Field bytesRead:Int
 Field FileHandle:TStream

 Function Create:T3DSChunk()
  Local C:T3DSChunk=New T3DSChunk
  C.ID=0
  C.length=0
  C.bytesRead=0
  C.FileHandle=Null
  Return c
 End Function

 Function ReadChunk(pChunk:T3DSChunk Var)

   'read Chunk ID and lenght

   pChunk.ID=ReadShort(pChunk.FileHandle)
   pChunk.bytesRead=2

   pChunk.length=ReadInt(pChunk.FileHandle)
   pChunk.bytesRead=pChunk.bytesRead+4

  'DebugLog3DS "ReadChunk"
  'DebugLog3DS "ID="+Hex(pChunk.ID)
  'DebugLog3DS "length="+pChunk.length
  'DebugLog3DS "bytesRead="+pChunk.bytesRead

 End Function

 Function SkipChunk(pChunk:T3DSChunk Var)

  'bei falschen Chunks kann man hier eine böse String länge bekommen !

  DebugLog3DS ">>> SkipChunk ID="+Hex(pChunk.ID)

  Local dummy$
  If pChunk.length - pChunk.bytesRead > 0 Then
   dummy$=ReadString(pChunk.FileHandle,pChunk.length - pChunk.bytesRead)
  EndIf

  pChunk.bytesRead=pChunk.length

 End Function

 Method GetString:String()
   'read a char until char=0

   Local dummy$
   Local b:Int
   Repeat
    If Self.bytesRead=Self.length Then Exit
    b=ReadByte(Self.FileHandle)
    Self.bytesRead=Self.bytesRead+1
    If b=0 Then Exit
    dummy$=dummy$ + Chr(b)
   Forever
   Return dummy$
 End Method

 Function ParseChunk(Chunk:T3DSChunk Var)
  'Main Loop/Rekursive

  'DebugLog "ParseChunk ID="+Hex(Chunk.ID)
  'DebugLog "length="+Chunk.length
  'DebugLog "bytesRead="+Chunk.bytesRead

  Local tempChunk:T3DSChunk=T3DSChunk.Create()  
  tempChunk.FileHandle=Chunk.FileHandle

  While Chunk.bytesRead < Chunk.length
   T3DSChunk.ReadChunk(tempChunk)
   Select tempChunk.ID
 
   'HEADER OUR ENTRY POINT
   Case EDIT3DS '0x3D3D
    DebugLog3DS "EDIT3DS"
    T3DSChunk.ParseChunk(tempChunk)

   Case VERSION
    DebugLog3DS "VERSION"
    Local Version:Int
    Version=GetVersion(tempChunk)
    DebugLog3DS Version

   Case MATERIAL '0xAFFF
    DebugLog3DS "MATERIAL"

    Local Mat:T3DSMaterial=T3DSMaterial.Create()
    _3DSMaterialList.addlast Mat
    _3DSMaterialLast=Mat

    T3DSChunk.ParseChunk(tempChunk)

   Case MAT_NAME '0xA000 - sz For hte material name "e.g. default 2"
    DebugLog3DS "MAT_NAME"
    GetMaterialName(tempChunk)

   Case MAT_AMBIENT
    GetAmbientColour(tempChunk)

   Case MAT_DIFFUSE ' Diffuse Colour  0xA020
    GetDiffuseColour(tempChunk)

   Case MAT_SPECULAR
    GetSpecularColour(tempChunk)

   'Case MAT_SHININESS '? in %
    'GetShininessColour(tempChunk)

   'Case MAT_FALLOFF
    'GetFallOffColour(tempChunk)

   Case MAT_EMISSIVE
    GetEmissiveColour(tempChunk)

   Case MAT_TEXMAP '0xA200 - If there's a texture wrapped to it where here
    DebugLog3DS "MAT_TEXMAP"
    T3DSChunk.ParseChunk(tempChunk)

   Case MAT_TEXFLNM '0xA300 -  get filename of the material
    DebugLog3DS "MAT_TEXFLNM"
    GetTexFileName(tempChunk)

   'Object - MESH'S
   Case NAMED_OBJECT '0x4000
    DebugLog3DS "NAMED_OBJECT"

    Local M:T3DSMesh=T3DSMesh.Create()
    _3DSMeshList.addlast M
    _3DSMeshLast=M

    GetMeshObjectName(tempChunk)

   Case OBJ_MESH '0x4100
    DebugLog3DS "OBJ_MESH"
    T3DSChunk.ParseChunk(tempChunk)

   Case MESH_VERTICES '0x4110
    DebugLog3DS "MESH_VERTICES"
    ReadMeshVertices(tempChunk)

   Case MESH_TEX_VERT '0x4140
    DebugLog3DS "MESH_TEX_VERT"
    ReadMeshTexCoords(tempChunk)

   Case MESH_FACES '0x4120
    DebugLog3DS "MESH_FACES"
    ReadMeshFaces(tempChunk)

   Case MESH_MATER '0x4130
    DebugLog3DS "MESH_MATER"
    ReadMeshMaterials(tempChunk)

   Case MESH_XFMATRIX
    DebugLog3DS "MESH_XFMATRIX"
    ReadMeshLocalCoords(tempChunk)

   Case HEIRARCHY
    DebugLog3DS "HEIRARCHY"
    T3DSChunk.SkipChunk(tempChunk) '<skip

   Case KEYF3DS
    DebugLog3DS "KEYF3DS"
    T3DSChunk.ParseChunk(tempChunk)

   Case ANIM_HEADER
    DebugLog3DS "ANIM_HEADER"
    T3DSChunk.SkipChunk(tempChunk) '<skip

   Case ANIM_S_E_TIME '0xB008
    DebugLog3DS "ANIM_S_E_TIME"
    StartEndFrames(tempChunk)

   Case ANIM_OBJ '0xB002
    DebugLog3DS "ANIM_OBJ"
    Local A:T3DSAnimation=T3DSAnimation.Create()
    _3DSAnimationList.addlast A
    _3DSAnimationLast=A
    
	T3DSChunk.ParseChunk(tempChunk)
   Case ANIM_NAME
    DebugLog3DS "ANIM_NAME"
 	ReadNameOfObjectToAnimate(tempChunk)
   Case ANIM_HIERARCHYPOS
    DebugLog3DS "ANIM_HIERARCHYPOS"
 	ReadHierarchyPos(tempChunk)

   Case ANIM_PIVOT '0xB013
    DebugLog3DS "ANIM_PIVOT"
 	ReadPivotPoint(tempChunk)
   Case ANIM_POS '0xB020
    DebugLog3DS "ANIM_POS"
	ReadAnimPos(tempChunk)
   Case ANIM_SCALE '0xB022
    DebugLog3DS "ANIM_SCALE"
	ReadAnimScale(tempChunk)
   Case ANIM_ROT '0xB021
    DebugLog3DS "ANIM_ROT"
	ReadAnimRot(tempChunk)

   Default
    T3DSChunk.SkipChunk(tempChunk)

   End Select
   Chunk.bytesRead=Chunk.bytesRead + tempChunk.length
  Wend

  tempChunk=Null

 End Function

End Type

'----------------------------------------------------------------------

Function ReadMeshVertices(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadMeshVertices"

      Local iNumberVertices:Int = 0
      Local i:Int
      Local V:T3DSVert      

      iNumberVertices=ReadShort(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+2

      DebugLog3DS "iNumberVertices=" + iNumberVertices

      'Allocate Memory And dump our vertices To the screen.

      '3*4 Bytes
      For i=1 To iNumberVertices
       V:T3DSVert=New T3DSVert
       V.x=ReadFloat(Chunk.FileHandle)
       V.y=ReadFloat(Chunk.FileHandle)
       V.z=ReadFloat(Chunk.FileHandle)
       'DebugLog3DS v.x+" "+v.y+" "+v.z
       _3DSMeshLast.AddVertex V
       Chunk.bytesRead=Chunk.bytesRead+(3*4)      
      Next
 
      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function ReadMeshTexCoords(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadMeshTexCoords"

      Local iNumberVertices:Int = 0
      Local i:Int
      Local V:T3DSTex      

      iNumberVertices=ReadShort(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+2

      'DebugLog3DS "iNumberVertices=" + iNumberVertices

      'Allocate Memory And dump our texture For each vertice To the screen.

      '2*4 Bytes
      For i=1 To iNumberVertices
       V:T3DSTex=New T3DSTex
       V.u=ReadFloat(Chunk.FileHandle)
       V.v=ReadFloat(Chunk.FileHandle)
       'DebugLog3DS v.u+" "+v.v
       _3DSMeshLast.AddTex V
       Chunk.bytesRead=Chunk.bytesRead+(2*4)      
      Next

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function ReadMeshLocalCoords(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadMeshLocalCoords"

 '48 Bytes 

 'Local axis info.
 'The three first blocks of three floats are the definition
 '(in the absolute axis) of the Local axis X Y Z of the object.
 'And the last block of three floats is the Local center of the object.

 'Mit anderen Worten wird das Mesh so gespeichert wie es im Raum steht
  
 Local x:Float,y:Float,z:Float

 _3DSMeshLast.AchseXX=ReadFloat(Chunk.FileHandle) 'Achse X
 _3DSMeshLast.AchseXY=ReadFloat(Chunk.FileHandle)
 _3DSMeshLast.AchseXZ=ReadFloat(Chunk.FileHandle)

 _3DSMeshLast.AchseYX=ReadFloat(Chunk.FileHandle) 'Achse Y
 _3DSMeshLast.AchseYY=ReadFloat(Chunk.FileHandle)
 _3DSMeshLast.AchseYZ=ReadFloat(Chunk.FileHandle)

 _3DSMeshLast.AchseZX=ReadFloat(Chunk.FileHandle) 'Achse Z
 _3DSMeshLast.AchseZY=ReadFloat(Chunk.FileHandle)
 _3DSMeshLast.AchseZZ=ReadFloat(Chunk.FileHandle)

 DebugLog3DS _3DSMeshLast.AchseXX+" "+_3DSMeshLast.AchseXY+" "+_3DSMeshLast.AchseXZ
 DebugLog3DS _3DSMeshLast.AchseYX+" "+_3DSMeshLast.AchseYY+" "+_3DSMeshLast.AchseYZ
 DebugLog3DS _3DSMeshLast.AchseZX+" "+_3DSMeshLast.AchseZY+" "+_3DSMeshLast.AchseZZ

 x=ReadFloat(Chunk.FileHandle) 'Pos.
 y=ReadFloat(Chunk.FileHandle)
 z=ReadFloat(Chunk.FileHandle)

 DebugLog3DS x+" "+y+" "+z
 
 _3DSMeshLast.SetOri(x,y,z)
 Chunk.bytesRead=Chunk.bytesRead+48      

End Function

'----------------------------------------------------------------------

Function GetVersion:Int(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetVersion"

 'diese sollte man noch prüfen wenn man eine Datei einließt

 Local Version:Int=ReadInt(Chunk.FileHandle)
 Chunk.bytesRead=Chunk.bytesRead+4      
 Return Version

End Function

'----------------------------------------------------------------------

Function GetMeshObjectName:String(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetMeshObjectName"

 'The strange thing is, the Next few parts of this chunk represent 

 'the name of the object.  Then we start chunking again.

 Local M:T3DSMesh=_3DSMeshLast
 M.MeshName$=Chunk.GetString()
 DebugLog3DS M.MeshName$

 T3DSChunk.ParseChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetMaterialName:String(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetMaterialName"

 Local Mat:T3DSMaterial=_3DSMaterialLast
 Mat.Name$=Chunk.GetString()

 DebugLog3DS Mat.Name$

End Function

'----------------------------------------------------------------------

Function GetTexFileName:String(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetTexFileName"

 Local Mat:T3DSMaterial=_3DSMaterialLast
 Mat.TextureFile$=Chunk.GetString()

 DebugLog3DS Mat.TextureFile$

End Function

'----------------------------------------------------------------------

Function ReadMeshFaces(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadMeshFaces"

      Local iNumberFaces :Int = 0
      Local i:Int
      Local F:T3DSFace      
      Local visibityflag:Int=0

      iNumberFaces =ReadShort(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+2

      DebugLog3DS "iNumberFaces =" + iNumberFaces 

      'Each face is 3 points A TRIANGLE!..WOW

            'visibityflag
            '* bit 0 : CA visible
            '* bit 1 : BC visible
            '* bit 2 : AB visible
            '* bit 3 : U wrapping
            '* bit 4 : V wrapping


      '4*2 Bytes
      For i=1 To iNumberFaces 
       F:T3DSFace=New T3DSFace
       F.a=ReadShort(Chunk.FileHandle)
       F.b=ReadShort(Chunk.FileHandle)
       F.c=ReadShort(Chunk.FileHandle)
       visibityflag=ReadShort(Chunk.FileHandle)
       'DebugLog3DS F.a+","+F.b+","+F.c+":"+visibityflag
       _3DSMeshLast.AddFace F
       Chunk.bytesRead=Chunk.bytesRead+(4*2)      
      Next

      'Our face material information is a sub-chunk.
      T3DSChunk.ParseChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetAmbientColour(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetAmbientColour"
 
 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next

      Local r:Float,g:Float,b:Float

      r=ReadFloat(Chunk.FileHandle) 
      g=ReadFloat(Chunk.FileHandle) 
      b=ReadFloat(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+(3*4)

      Local Mat:T3DSMaterial=_3DSMaterialLast
      Mat.AmbientColour.Set(r,g,b)

      'DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetDiffuseColour(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetDiffuseColour"

 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next
 
      Local r:Float,g:Float,b:Float

      r=ReadFloat(Chunk.FileHandle)
      g=ReadFloat(Chunk.FileHandle)
      b=ReadFloat(Chunk.FileHandle)
      Chunk.bytesRead=Chunk.bytesRead+(3*4)

      Local Mat:T3DSMaterial=_3DSMaterialLast
      Mat.DiffuseColour.Set(r,g,b)

      DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetSpecularColour(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetSpecularColour"

 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next

      Local r:Float,g:Float,b:Float

      r=ReadFloat(Chunk.FileHandle)
      g=ReadFloat(Chunk.FileHandle)
      b=ReadFloat(Chunk.FileHandle)
      Chunk.bytesRead=Chunk.bytesRead+(3*4)

      Local Mat:T3DSMaterial=_3DSMaterialLast
      Mat.SpecularColour.Set(r,g,b)

      'DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetShininessColour(Chunk:T3DSChunk Var) '??? ... don't use

 DebugLog3DS ">GetShininessColour"

 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next

 'only 1 Float ?!

      'Local r:Float,g:Float,b:Float

      'r=ReadFloat(Chunk.FileHandle) 
      'g=ReadFloat(Chunk.FileHandle) 
      'b=ReadFloat(Chunk.FileHandle) 
      'Chunk.bytesRead=Chunk.bytesRead+(3*4)

      'DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetFallOffColour(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetFallOffColour"

 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next

      Local r:Float,g:Float,b:Float

      r=ReadFloat(Chunk.FileHandle) 
      g=ReadFloat(Chunk.FileHandle) 
      b=ReadFloat(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+(3*4)

      'DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function GetEmissiveColour(Chunk:T3DSChunk Var)

 DebugLog3DS ">GetEmissiveColour"

 Local i:Int
 For i=1 To 6 'ChunkHeader
  ReadByte(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+1
 Next

      Local r:Float,g:Float,b:Float

      r=ReadFloat(Chunk.FileHandle) 
      g=ReadFloat(Chunk.FileHandle) 
      b=ReadFloat(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+(3*4)

      Local Mat:T3DSMaterial=_3DSMaterialLast
      Mat.EmissiveColour.Set(r,g,b)

      'DebugLog3DS "RGB "+r+" "+g+" "+b

      T3DSChunk.SkipChunk(Chunk)

End Function

'----------------------------------------------------------------------

Function ReadMeshMaterials(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadMeshMaterials"

      'Material Name Where Referencing

      Local Name$=Chunk.GetString()
      DebugLog3DS Name$

      Local i:Int=0
      Local iNumFaces :Int = 0
      Local FaceAssignedThisMaterial:Int=0

      iNumFaces =ReadShort(Chunk.FileHandle) 
      Chunk.bytesRead=Chunk.bytesRead+2

      'DebugLog "iNumFaces =" + iNumFaces 

      'Normal ein Array
      For i=0 To iNumFaces-1
       FaceAssignedThisMaterial=ReadShort(Chunk.FileHandle)
       'DebugLog3DS "FaceAssignedThisMaterial="+FaceAssignedThisMaterial
       Chunk.bytesRead=Chunk.bytesRead+2
       'Determine Which Material It Is In Our List
       Local Mat:T3DSMaterial
       For Mat=EachIn _3DSMaterialList
        If Mat.Name$=Name$ Then
         _3DSMeshLast.SetFaceMaterial(FaceAssignedThisMaterial,Mat)
         Exit
        EndIf
       Next 'Nach Name suchen

      Next 'Alle Faces

End Function

'----------------------------------------------------------------------

Function ReadNameOfObjectToAnimate:String(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadNameOfObjectToAnimate"

  Local A:T3DSAnimation=_3DSAnimationLast
  A.ObjName$=Chunk.GetString()

  DebugLog3DS A.ObjName$

  'word     Flag1
  '          * Bit 11 : Hidden
  ReadShort(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+2      

  'word     Flag2
  '          * Bit 0 : Show path
  '          * Bit 1 : Animate smoothing
  '          * Bit 4 : Object motion blur
  '          * Bit 6 : Morph materials
  ReadShort(Chunk.FileHandle)
  Chunk.bytesRead=Chunk.bytesRead+2      

  'word     Hierarchy father, link To the parent Object (-1 For none)
  A.HierarchyParent=ReadShort(Chunk.FileHandle)
  DebugLog3DS "Hierarchy Parent="+A.HierarchyParent
  Chunk.bytesRead=Chunk.bytesRead+2      

  T3DSChunk.SkipChunk(Chunk)
 
End Function

'----------------------------------------------------------------------

Function ReadPivotPoint:String(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadPivotPoint"

 Local A:T3DSAnimation=_3DSAnimationLast

 Local x:Float
 Local y:Float
 Local z:Float

 x=ReadFloat(Chunk.FileHandle) 
 y=ReadFloat(Chunk.FileHandle) 
 z=ReadFloat(Chunk.FileHandle) 
 Chunk.bytesRead=Chunk.bytesRead+(3*4)

 'ohne Anim immer 0,0,0
 DebugLog3DS "Pivot "+x+","+y+","+z
 
 '... mal gucken was ich damit mache ...

End Function

'----------------------------------------------------------------------

Function ReadAnimPos(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadAnimPos"

 Local A:T3DSAnimation=_3DSAnimationLast

    Local i:Int
	For i=1 To 5 'skip
	 ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+2
    Next

	Local iKeys:Short
	iKeys=ReadShort(Chunk.FileHandle)
	ReadShort(Chunk.FileHandle) 'skip
    Chunk.bytesRead=Chunk.bytesRead+(2*2)

    DebugLog3DS iKeys

	A.SetPosKeys iKeys

    Local jj:Int
	For jj=0 To iKeys-1
	
     A.PositionArray[jj].iFrame=ReadShort(Chunk.FileHandle)
     ReadShort(Chunk.FileHandle) 'skip
     ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+(3*2)

     A.PositionArray[jj].x=ReadFloat(Chunk.FileHandle)
     A.PositionArray[jj].y=ReadFloat(Chunk.FileHandle)
     A.PositionArray[jj].z=ReadFloat(Chunk.FileHandle)
     Chunk.bytesRead=Chunk.bytesRead+(3*4)

     DebugLog3DS jj+" Key Pos "+A.PositionArray[jj].x+","+A.PositionArray[jj].y+","+A.PositionArray[jj].z

	Next

	'Now we now how many keys we are reading in..e.g. 1, 7 And 49.  And we know that
	'there is a totoal of 100 keys.  So its upto us To do the rest.
	'Lets use the simple And best linear interpolation
	'p(t) = p0 + t(p1-p0)

End Function

'----------------------------------------------------------------------

Function ReadAnimScale(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadAnimScale"

 Local A:T3DSAnimation=_3DSAnimationLast

    Local i:Int
	For i=1 To 5 'skip
	 ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+2
    Next

	Local iKeys:Short
	iKeys=ReadShort(Chunk.FileHandle)
	ReadShort(Chunk.FileHandle) 'skip
    Chunk.bytesRead=Chunk.bytesRead+(2*2)

    DebugLog3DS iKeys

	A.SetScaleKeys iKeys

    Local jj:Int
	For jj=0 To iKeys-1
	
     A.ScaleArray[jj].iFrame=ReadShort(Chunk.FileHandle)
     ReadShort(Chunk.FileHandle) 'skip
     ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+(3*2)

     A.ScaleArray[jj].x=ReadFloat(Chunk.FileHandle)
     A.ScaleArray[jj].y=ReadFloat(Chunk.FileHandle)
     A.ScaleArray[jj].z=ReadFloat(Chunk.FileHandle)
     Chunk.bytesRead=Chunk.bytesRead+(3*4)

     DebugLog3DS jj+" Key Scale "+A.ScaleArray[jj].x+","+A.ScaleArray[jj].y+","+A.ScaleArray[jj].z

	Next

	'Now we now how many keys we are reading in..e.g. 1, 7 And 49.  And we know that
	'there is a totoal of 100 keys.  So its upto us To do the rest.
	'Lets use the simple And best linear interpolation
	'p(t) = p0 + t(p1-p0)

End Function

'----------------------------------------------------------------------

Function ReadAnimRot(Chunk:T3DSChunk Var)

 DebugLog3DS ">ReadAnimRot"

 Local A:T3DSAnimation=_3DSAnimationLast

    Local i:Int
	For i=1 To 5 'skip
	 ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+2
    Next

	Local iKeys:Short
	iKeys=ReadShort(Chunk.FileHandle)
	ReadShort(Chunk.FileHandle) 'skip
    Chunk.bytesRead=Chunk.bytesRead+(2*2)

    DebugLog3DS iKeys

	A.SetRotKeys iKeys

    Local rotation_rads:Float
    Local axis_x:Float
    Local axis_y:Float
    Local axis_z:Float

    Local jj:Int 
    For jj=0 To iKeys-1

     A.RotArray[jj].iFrame=ReadShort(Chunk.FileHandle)
     ReadShort(Chunk.FileHandle) 'skip
     ReadShort(Chunk.FileHandle) 'skip
     Chunk.bytesRead=Chunk.bytesRead+(3*2)

		rotation_rads=ReadFloat(Chunk.FileHandle)
		axis_x=ReadFloat(Chunk.FileHandle)
		axis_y=ReadFloat(Chunk.FileHandle)
		axis_z=ReadFloat(Chunk.FileHandle)
        Chunk.bytesRead=Chunk.bytesRead+(4*4)

		A.RotArray[jj].rotation_rads = rotation_rads
		A.RotArray[jj].axis_x = axis_x
		A.RotArray[jj].axis_y = axis_y 
		A.RotArray[jj].axis_z = axis_z

        DebugLog3DS "rotation rads="+rotation_rads
        DebugLog3DS "axis x="+axis_x+" y="+axis_y+" z="+axis_z

		'Make our axis of chose always positive e.g. 1*2 =1 -1*-1 =1 etc.
        'ob auch ABS() geht weiß ich nicht ...
		'A.RotArray[jj].axis_x=A.RotArray[jj].axis_x*A.RotArray[jj].axis_x
		'A.RotArray[jj].axis_y=A.RotArray[jj].axis_y*A.RotArray[jj].axis_y
		'A.RotArray[jj].axis_z=A.RotArray[jj].axis_z*A.RotArray[jj].axis_z

        'Test
		'A.RotArray[jj].axis_x=Abs(A.RotArray[jj].axis_x)
		'A.RotArray[jj].axis_y=Abs(A.RotArray[jj].axis_y)
		'A.RotArray[jj].axis_z=Abs(A.RotArray[jj].axis_z)
		
		If jj = 0 Then
		 'A.RotArray[jj].rotation_rads =A.RotArray[jj].rotation_rads - 1.57#
        EndIf
		'Make our angles relative to the absolute begining, Not To each prev frame.
        Local d:Float
        Local old:Float
        If jj > 0 Then
         d = axis_x + axis_y + axis_z
         old = A.RotArray[jj-1].rotation_rads
         'A.RotArray[jj].rotation_rads = old + d*A.RotArray[jj].rotation_rads
        EndIf
        'DebugLog3DS "jetzt rotation rads="+A.RotArray[jj].rotation_rads
        'DebugLog3DS "nacher axis x="+A.RotArray[jj].axis_x+" y="+A.RotArray[jj].axis_y+" z="+A.RotArray[jj].axis_z
    Next

	'Now we now how many keys we are reading in..e.g. 1, 7 And 49.  And we know that
	'there is a totoal of 100 keys.  So its upto us To do the rest.
	'Lets use the simple And best linear interpolation
	'p(t) = p0 + t(p1-p0)

End Function

'----------------------------------------------------------------------

Function ReadHierarchyPos(Chunk:T3DSChunk Var)

 Local A:T3DSAnimation=_3DSAnimationLast

 'This word contains a unique value For the Object And is used For the hierarchy tree links.

 A.HierarchyPos=ReadShort(Chunk.FileHandle)
 Chunk.bytesRead=Chunk.bytesRead+2

 DebugLog3DS("HierarchyPos="+A.HierarchyPos)

End Function

'----------------------------------------------------------------------

Function StartEndFrames(Chunk:T3DSChunk Var) 'not used

	Local StartFrame:Int
	Local EndFrame:Int

	StartFrame=ReadInt(Chunk.FileHandle)
	EndFrame=ReadInt(Chunk.FileHandle)
    Chunk.bytesRead=Chunk.bytesRead+(2*4)

    DebugLog3DS "Start Frame="+StartFrame+" End Frame="+EndFrame

	'Assume For simplisity, that it starts at 0!
	'm_iKeyFrames = EndFrame

End Function

'----------------------------------------------------------------------

Function DebugLog3DS(Txt$)

  If DebugLog3DSOn Then DebugLog Txt$

End Function

'----------------------------------------------------------------------

Public

'----------------------------------------------------------------------

Function DebugLog3DSOnOff(OnOff:Int)
 DebugLog3DSOn=OnOff
End Function

'----------------------------------------------------------------------

Function Load3DSIntoMemory:Int(Filename$)

 DebugLog3DS("Load3DSIntoMemory "+Filename$)

 '---------------------
 ClearList _3DSMaterialList
 ClearList _3DSMeshList
 ClearList _3DSAnimationList
 '---------------------

 Local Chunk:T3DSChunk=T3DSChunk.Create()
 Local FileHandle:TStream

 FileHandle=OpenFile(Filename$)  

  Chunk.FileHandle=FileHandle
  DebugLog3DS "Read Chunks ..."
  T3DSChunk.ReadChunk(Chunk) '4D4D
  T3DSChunk.ParseChunk(Chunk)

 CloseStream FileHandle

 Chunk=Null

 Return True

End Function

'----------------------------------------------------------------------

Function Free3DSMemory()

 Local Mat:T3DSMaterial
 Local Mesh:T3DSMesh
 Local Anim:T3DSAnimation

 For Mat=EachIn _3DSMaterialList 
  Mat=Null 
 Next

 For Mesh=EachIn _3DSMeshList
  Mesh=Null 
 Next

 For Anim=EachIn _3DSAnimationList
  Anim=Null 
 Next

 ClearList _3DSMaterialList
 ClearList _3DSMeshList
 ClearList _3DSAnimationList

 _3DSMaterialLast=Null
 _3DSMeshLast=Null
 _3DSAnimationLast=Null

 'FlushMem

End Function

'----------------------------------------------------------------------

'FILE END
