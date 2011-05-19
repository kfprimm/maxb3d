
Strict

Import MaxB3D.Math
Import "brush.bmx"

Const SURFACE_POS = 1
Const SURFACE_NML = 2
Const SURFACE_CLR = 4
Const SURFACE_TEX = 8
Const SURFACE_TRI = 16
Const SURFACE_ALL = SURFACE_POS|SURFACE_NML|SURFACE_CLR|SURFACE_TEX

Type TSurface
	Field _brush:TBrush=New TBrush
	
	Field _vertexcnt,_trianglecnt
	Field _vertexpos#[]
	Field _vertexnml#[]
	Field _vertexclr#[]
	
	Field _vertextex#[][],_texcoordsize=-1
	
	Field _triangle[]
	
	Field _res:TSurfaceRes,_reset=-1
	
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
	
	Method AddVertex(x#,y#,z#,u#,v#)
		Resize(_vertexcnt+1,-1)
		SetCoord(_vertexcnt-1,x,y,z)
		SetTexCoord(_vertexcnt-1,u,v)
		Return _vertexcnt-1
	End Method
	
	Method GetCoord(index,x# Var,y# Var,z# Var)
		x=_vertexpos[index*3+0]
		y=_vertexpos[index*3+1]
		z=_vertexpos[index*3+2]
	End Method
	Method SetCoord(index,x#,y#,z#)
		_vertexpos[index*3+0]=x
		_vertexpos[index*3+1]=y
		_vertexpos[index*3+2]=z		
		_reset:|1
	End Method
	
	Method GetNormal(index,nx# Var,ny# Var,nz# Var)
		nx=_vertexnml[index*3+0]
		ny=_vertexnml[index*3+1]
		nz=_vertexnml[index*3+2]
	End Method
	Method SetNormal(index,nx#,ny#,nz#)
		_vertexnml[index*3+0]=nx
		_vertexnml[index*3+1]=ny
		_vertexnml[index*3+2]=nz
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
	
	Method GetTexCoord(index,u# Var,v# Var,set=0)
		ResizeTexSets set
		u=_vertextex[set][index*2+0]
		v=_vertextex[set][index*2+0]
	End Method
	Method SetTexCoord(index,u#,v#,set=0)
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
			Local w#=1.0
			matrix.TransformVector _vertexpos[i*3+0],_vertexpos[i*3+1],_vertexpos[i*3+2],w
			'matrix.TransformVector _vertexnml[i+0],_vertexnml[i+1],_vertexnml[i+2],w
		Next
	End Method
	
	Method UpdateNormals()
		C_UpdateNormals(_trianglecnt,_vertexcnt,_triangle,_vertexpos,_vertexnml)
		_reset:|2
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
	
	Method HasAlpha()
		Return _brush._a<>1 Or _brush._fx&FX_FORCEALPHA
	End Method	
End Type

Type TSurfaceRes
	Field _vertexcnt
	Field _trianglecnt
End Type
