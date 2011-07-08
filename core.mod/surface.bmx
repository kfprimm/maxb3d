
Strict

Import MaxB3D.Math
Import "brush.bmx"

Const SURFACE_POS = 1
Const SURFACE_NML = 2
Const SURFACE_CLR = 4
Const SURFACE_TEX = 8
Const SURFACE_TRI = 16
Const SURFACE_ALL = SURFACE_POS|SURFACE_NML|SURFACE_CLR|SURFACE_TEX|SURFACE_TRI

Type TSurface
	Field _brush:TBrush=New TBrush
	
	Field _vertexcnt,_trianglecnt
	Field _vertexpos#[],_vertexnml#[],_vertexclr#[]	
	Field _vertextex#[][],_texcoordsize=-1
	
	Field _triangle[]
	
	Field _res:TSurfaceRes,_reset=-1
	
	Field _resetbounds=True,_minx#,_miny#,_minz#,_maxx#,_maxy#,_maxz#
	Field _boundsupdatedmsg:TMaxB3DMsg=New TMaxB3DMsg
	
	Method Copy:TSurface(data=SURFACE_ALL)
		Local surface:TSurface=New TSurface
		surface._brush.Load(_brush)
		surface._vertexcnt=_vertexcnt		
		If data&SURFACE_POS surface._vertexpos=_vertexpos[..]
		If data&SURFACE_NML surface._vertexnml=_vertexnml[..]
		If data&SURFACE_CLR surface._vertexclr=_vertexclr[..]
		If data&SURFACE_TEX surface._vertextex=_vertextex[..];surface._texcoordsize=_texcoordsize
		If data&SURFACE_TRI surface._trianglecnt=_trianglecnt;surface._triangle=_triangle[..]
		Return surface
	End Method
	
	Method Resize(vertexcount,trianglecount)
		If vertexcount>-1
			_vertexpos=_vertexpos[..vertexcount*3]
			_vertexnml=_vertexnml[..vertexcount*3]
			_vertexclr=_vertexclr[..vertexcount*4]
			For Local i=_vertexcnt*4 To vertexcount*4-1
				_vertexclr[i]=1.0
			Next
			For Local i=0 To _texcoordsize-1
				_vertextex[i]=_vertextex[i][..vertexcount*2]
			Next
			_vertexcnt=vertexcount
		EndIf
		
		If trianglecount>-1
			_triangle=_triangle[..trianglecount*3]
			_trianglecnt=trianglecount
		EndIf
	End Method
	
	Method GetSize(vertices Var,triangles Var)
		vertices=_vertexcnt
		triangles=_trianglecnt
	End Method

	Method AddVertex(x#,y#,z#,u#=0.0,v#=0.0)
		Resize(_vertexcnt+1,-1)
		SetCoords(_vertexcnt-1,x,y,z)
		SetTexCoords(_vertexcnt-1,u,v)
		Return _vertexcnt-1
	End Method
	
	Method GetCoords(index,x# Var,y# Var,z# Var)
		x=_vertexpos[index*3+0]
		y=_vertexpos[index*3+1]
		z=_vertexpos[index*3+2]
	End Method
	Method SetCoords(index,x#,y#,z#)
		_vertexpos[index*3+0]=x
		_vertexpos[index*3+1]=y
		_vertexpos[index*3+2]=z		
		_reset:|1;_resetbounds=True
	End Method
	
	Method GetNormal(index,nx# Var,ny# Var,nz# Var)
		nx=_vertexnml[index*3+0]*-1
		ny=_vertexnml[index*3+1]*-1
		nz=_vertexnml[index*3+2]*-1
	End Method
	Method SetNormal(index,nx#,ny#,nz#)
		_vertexnml[index*3+0]=nx*-1
		_vertexnml[index*3+1]=ny*-1
		_vertexnml[index*3+2]=nz*-1
		_reset:|2
	End Method
	
	Method GetColor(index,red Var,green Var,blue Var,alpha# Var)
		red=_vertexclr[index*4+0]*255.0
		green=_vertexclr[index*4+1]*255.0
		blue=_vertexclr[index*4+2]*255.0
		alpha=_vertexclr[index*4+3]
	End Method
	Method SetColor(index,red,green,blue,alpha#)
		_vertexclr[index*4+0]=red/255.0
		_vertexclr[index*4+1]=green/255.0
		_vertexclr[index*4+2]=blue/255.0
		_vertexclr[index*4+3]=alpha
		_reset:|4
	End Method
	
	Method GetTexCoords(index,u# Var,v# Var,set=0)
		ResizeTexSets set
		u=_vertextex[set][index*2+0]
		v=_vertextex[set][index*2+1]
	End Method
	Method SetTexCoords(index,u#,v#,set=0)
		ResizeTexSets set
		_vertextex[set][index*2+0]=u
		_vertextex[set][index*2+1]=v
		_reset:|Int(2^(4+set))
	End Method
	
	Method ResizeTexSets(set)
		If set+1>_texcoordsize
			Local size=_vertextex.length
			_vertextex=_vertextex[..set+1]			
			For Local i=size To set
				_vertextex[i]=New Float[_vertexcnt*2]
			Next	
			_texcoordsize=set+1		
		EndIf
	End Method
	
	Method AddTriangle(v0,v1,v2)
		Resize(-1,_trianglecnt+1)
		SetTriangle _trianglecnt-1,v0,v1,v2
		Return _trianglecnt-1
	End Method
	
	Method GetTriangle(index,v0 Var,v1 Var,v2 Var)
		v0=_triangle[index*3+0]
		v1=_triangle[index*3+1]
		v2=_triangle[index*3+2]
	End Method
	Method SetTriangle(index,v0,v1,v2)
		_triangle[index*3+0]=v0
		_triangle[index*3+1]=v1
		_triangle[index*3+2]=v2
		_reset:|8
	End Method
	
	Method Flip()
		For Local t=0 To _trianglecnt-1
			Local v2=_triangle[t*3+2]
			_triangle[t*3+2]=_triangle[t*3+0]
			_triangle[t*3+0]=v2			
		Next
		For Local v=0 To _vertexcnt-1
			_vertexnml[(v*3)+0]:*-1
			_vertexnml[(v*3)+1]:*-1
			_vertexnml[(v*3)+2]:*-1
		Next
		_reset:|2|8
	End Method
	
	Method Transform(matrix:TMatrix)
		For Local i=0 To _vertexcnt-1
			matrix.TransformVec3 _vertexpos[i*3+0],_vertexpos[i*3+1],_vertexpos[i*3+2]
			'matrix.TransformVector _vertexnml[i+0],_vertexnml[i+1],_vertexnml[i+2],w
		Next
	End Method
	
	Method UpdateBounds(force=False)
		If Not _resetbounds And force=false Return
		_minx=999999999;_miny=999999999;_minz=999999999
		_maxx=-999999999;_maxy=-999999999;_maxz=-999999999
		For Local v=0 To _vertexcnt-1
			Local x#,y#,z#
			GetCoords v,x,y,z				
			_minx=Min(x,_minx);_maxx=Max(x,_maxx)
			_miny=Min(y,_miny);_maxy=Max(y,_maxy)
			_minz=Min(z,_minz);_maxz=Max(z,_maxz)
		Next
		_boundsupdatedmsg.Run
		_resetbounds=False
	End Method
	
	Method UpdateNormals(smoothing=True)
		If smoothing
			C_UpdateNormals(_trianglecnt,_vertexcnt,_triangle,_vertexpos,_vertexnml)
		Else
			Local face_normal:TVector[_trianglecnt],vertex_triangles[][_vertexcnt]
						
			For Local i=0 To _trianglecnt-1
				Local v0,v1,v2
				GetTriangle i,v0,v1,v2
				
				vertex_triangles[v0]:+[i]
				vertex_triangles[v1]:+[i]
				vertex_triangles[v2]:+[i]
				
				Local a:TVector=New TVector,b:TVector=New TVector,c:TVector=New TVector
				GetCoords v0,a.x,a.y,a.z
				GetCoords v1,b.x,b.y,b.z
				GetCoords v2,c.x,c.y,c.z
				
				face_normal[i]=New TVector.FromTriangle(a,b,c)	
			Next
	
			Local normal:TVector=New TVector
			For Local i=0 To _vertexcnt-1
				normal.Create3(0,0,0)
				For Local t=0 To vertex_triangles[i].length-1
					normal=normal.Add(face_normal[vertex_triangles[i][t]])		
				Next
				normal.Normalize()				
				SetNormal i,-normal.x,-normal.y,-normal.z
			Next		
		EndIf
		_reset:|2
	End Method
	
	Method SetTriangleNormal(index,nx#,ny#,nz#)
		Local v0,v1,v2
		GetTriangle index,v0,v1,v2
		SetNormal v0,nx,ny,nz
		SetNormal v1,nx,ny,nz
		SetNormal v2,nx,ny,nz
	End Method
	
	Method GetBrush:TBrush()
		Return _brush.Copy()
	End Method	
	Method SetBrush(brush:TBrush)
		_brush.Load(brush)
	End Method
	
	Method CountVertices()
		Return _vertexcnt
	End Method
	Method CountTriangles()
		Return _trianglecnt
	End Method
	
	Method IsEmpty()
		Return _vertexcnt=0 And _trianglecnt=0
	End Method
		
	Method HasAlpha()
		Return _brush._a<>1 Or _brush._fx&FX_FORCEALPHA
	End Method	
End Type

Type TSurfaceRes Extends TDriverResource
	Field _vertexcnt
	Field _trianglecnt
	
	Method Copy:TSurfaceRes() Abstract
End Type

Type TMaxB3DMsg
	Field _succ:TMaxB3DMsg
	Field _context:Object
	Field _func(context:Object)
	
	Method Add(func(context:Object),context:Object)
		Local msg:TMaxB3DMsg=Self
		While msg._succ
			msg=msg._succ
		Wend
		msg._succ=New TMaxB3DMsg
		msg._context=context
		msg._func=func
	End Method
	
	Method Run()
		Local msg:TMaxB3DMsg=Self
		While msg
			If msg._func msg._func(msg._context)
			msg=msg._succ
		Wend
	End Method
End Type