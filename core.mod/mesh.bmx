
Strict

Import "worldconfig.bmx"
Import "entity.bmx"
Import "surface.bmx"

Type TMesh Extends TRenderEntity 
	Field _surfaces:TList=CreateList()
	Field _resetbounds,_minx#,_miny#,_minz#,_maxx#,_maxy#,_maxz#
	
	Field _tree:Byte Ptr
	Field _resettree
	
	Method HasAlpha()
		If _brush._a<>1 Or _brush._fx&FX_FORCEALPHA Return True
		For Local surface:TSurface=EachIn _surfaces
			If surface.HasAlpha() Return True
		Next
	End Method
	
	Method Copy:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
		For Local surface:TSurface=EachIn _surfaces
			mesh._surfaces.AddLast surface
		Next
		Return mesh
	End Method
	
	Method Clone:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
		For Local surface:TSurface=EachIn _surfaces
			mesh._surfaces.AddLast surface.Copy()
		Next
		Return mesh
	End Method
	
	Method AddSurface:TSurface(vertices=0,triangles=0)
		Local surface:TSurface=New TSurface
		surface.Resize vertices,triangles
		_surfaces.AddLast surface
		Return surface
	End Method
	
	Method GetSurface:TSurface(index)
		Return TSurface(_surfaces.ValueAtIndex(index))
	End Method
	
	Method GetSize(width# Var,height# Var,depth# Var)
		GetBounds()
		width=_maxx-_minx;height=_maxy-_miny;depth=_maxz-_minz
	End Method
	
	Method GetBounds()	
		If _resetbounds		
			_resetbounds=False
	
			_minx#=-999999999;_miny#=-999999999;_minz#=-999999999
			_maxx#=999999999;_maxy#=999999999;_maxz#=999999999
			
			For Local surface:TSurface=EachIn _surfaces		
				For Local v=0 To surface.CountVertices()-1
					Local x#,y#,z#
					surface.GetCoord v,x,y,z				
					_minx=Min(x,_minx);_maxx=Max(x,_maxx)
					_miny=Min(x,_miny);_maxy=Max(y,_maxy)
					_minz=Min(x,_minz);_maxz=Max(z,_maxz)
				Next			
			Next
		EndIf
	End Method
	
	Method Fit(x#,y#,z#,width#,height#,depth#,uniform=False)
		Local mw#,mh#,md#,wr#,hr#,dr#
		GetSize mw,mw,mw	
		If uniform=True									
			wr=mw/width;hr=mh/height;dr=md/depth
		
			If wr>=hr And wr>=dr	
				y=y+((height-(mh/wr))/2.0)
				z=z+((depth-(md/wr))/2.0)
				
				height=mh/wr
				depth=md/wr			
			ElseIf hr>dr			
				x=x+((width-(mw/hr))/2.0)
				z=z+((depth-(md/hr))/2.0)
			
				width=mw/hr
				depth=md/hr						
			Else			
				x=x+((width-(mw/dr))/2.0)
				y=y+((height-(mh/dr))/2.0)
			
				width=mw/dr
				height=mh/dr								
			EndIf
		EndIf
		
		wr=mw/width;hr=mh/height;dr=md/depth
			
		Local minx#=9999999999,miny#=9999999999,minz#=9999999999
		Local maxx#=-9999999999,maxy#=-9999999999,maxz#=-9999999999
	
		For Local surface:TSurface=EachIn _surfaces				
			For Local v=0 To surface.CountVertices()-1		
				Local vx#,vy#,vz#
				surface.GetCoord v,vx,vy,vz				
				minx=Min(vx,minx);miny=Min(vy,miny);minz=Min(vz,minz)
				maxx=Max(vx,maxx);maxy=Max(vy,maxy);maxz=Max(vz,maxz)
			Next							
		Next
		
		For Local surface:TSurface=EachIn _surfaces				
			For Local v=0 To surface.CountVertices()-1
				Local vx#,vy#,vz#
				surface.GetCoord v,vx,vy,vz
								
				Local mx#=maxx-minx,my#=maxy-miny,mz#=maxz-minz
				
				Local ux#,uy#,uz#
				
				If mx<0.0001 And mx>-0.0001 Then ux=0.0 Else ux=(vx-minx)/mx ' 0-1
				If my<0.0001 And my>-0.0001 Then uy=0.0 Else uy=(vy-miny)/my ' 0-1
				If mz<0.0001 And mz>-0.0001 Then uz=0.0 Else uz=(vz-minz)/mz ' 0-1
										
				vx=x+(ux*width);vy=y+(uy*height);vz=z+(uz*depth)				
				surface.SetCoord(v,vx,vy,vz)
				
				Local nx#,ny#,nz#
				surface.GetNormal v,nx,ny,nz				
				nx:*wr;ny:*hr;nz:*dr				
				surface.SetNormal(v,nx#,ny#,nz#)
			Next			
			surface._reset:|1|2
		Next		
	End Method
	
	Method Flip()
		For Local surface:TSurface=EachIn _surfaces
			surface.Flip()
		Next
	End Method
	
	Method UpdateNormals()
		For Local surface:TSurface=EachIn _surfaces
			surface.UpdateNormals()
		Next
	End Method
	
	Method Scale(x#,y#,z#)
		Return Transform(TMatrix.Scale(x,y,z))
	End Method
	
	Method Transform(matrix:TMatrix)
		For Local surface:TSurface=EachIn _surfaces
			For Local i=0 To surface._vertexcnt-1
				Local w#=1.0
				matrix.TransformVector surface._vertexpos[i*3+0],surface._vertexpos[i*3+1],surface._vertexpos[i*3+2],w
				'matrix.TransformVector surface._vertexnml[i+0],surface._vertexnml[i+1],surface._vertexnml[i+2],w
			Next
		Next
	End Method
	
	Method ForEachSurfaceDo(func(surface:TSurface,data:Object),data:Object=Null)
		For Local surface:TSurface=EachIn _surfaces
			func surface,data
		Next
	End Method
	
	Method TreeCheck:Byte Ptr()
		If _resettree=True
			If _tree<>Null C_DeleteColTree(_tree);_tree=Null
			_resettree=False				
		EndIf

		If _tree=Null
			Local vertextotal,info:Byte Ptr=C_NewMeshInfo(),count
			
			For Local surface:TSurface=EachIn _surfaces
				count:+1				
				Local triangles[]=surface._triangle[..]
				Local vertices:Float[]=surface._vertexpos[..]
										
				If surface._trianglecnt<>0 And surface._vertexcnt<>0
					For Local i=0 To surface._trianglecnt-1
						triangles[i*3+0]:+vertextotal
						triangles[i*3+1]:+vertextotal
						triangles[i*3+2]:+vertextotal
					Next
				
					For Local i=0 To surface._trianglecnt-1
						Local old=triangles[i*3+0]
						triangles[i*3+0]=triangles[i*3+2]
						triangles[i*3+2]=old
					Next
					
					For Local i=0 To surface._vertexcnt-1
						vertices[i*3+2]=-vertices[i*3+2]
					Next
		
					C_AddSurface(info,surface._trianglecnt,surface._vertexcnt,triangles,vertices,count)										
					vertextotal:+surface._vertexcnt				
				EndIf	
			Next

			_tree=C_CreateColTree(info)
			C_DeleteMeshInfo(info)
		EndIf
		Return _tree
	End Method
End Type

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
	
	Function Load(url:Object,mesh:TMesh)
		Local loader:TMeshLoader=_start
		While loader<>Null
			If loader.Run(url,mesh) Return True
			loader=loader._next
		Wend
		Return False
	End Function
	
	Method Run(url:Object,mesh:TMesh) Abstract
End Type

Type TMeshLoaderNull Extends TMeshLoader
	Method Run(url:Object,mesh:TMesh)
		If String(url)="*null*" Return True
		Return False
	End Method
End Type
New TMeshLoaderNull
