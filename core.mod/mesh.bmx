
Strict

Import "worldconfig.bmx"
Import "entity.bmx"
Import "surface.bmx"
Import "bone.bmx"

Import MaxB3D.Logging

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "core/mesh",message
End Function

Public

Type TMesh Extends TAnimEntity 
	Field _surfaces:TSurface[]

	Field _bone:TBone[]
	
	Field _tree:Byte Ptr
	Field _resettree
	
	Field _width,_height,_depth,_updatebounds
	Field _minx#,_miny#,_minz#,_maxx#,_maxy#,_maxz#
	
	Method HasAlpha()
		If Super.HasAlpha() Return True
		For Local surface:TSurface=EachIn _surfaces
			If surface.HasAlpha() Return True
		Next
	End Method
	
	Method Lists[]()
		Return Super.Lists()+[WORLDLIST_MESH, WORLDLIST_RENDER]
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		Local mesh:TMesh=TMesh(entity)
		For Local surface:TSurface=EachIn mesh._surfaces
			AppendSurface surface
		Next		
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TMesh(parent:TEntity=Null)
		Return TMesh(Super.Copy_(parent))
	End Method
	
	Method Clone:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=Copy(parent)
		For Local i=0 To _surfaces.length-1
			mesh._surfaces[i] = _surfaces[i].Copy()
		Next
		Return mesh
	End Method
	
	Method Add(mesh:TMesh)
		For Local surface:TSurface=EachIn mesh._surfaces
			Local new_surface:TSurface=surface.Copy()
			new_surface.SetBrush new_surface._brush.Merge(mesh._brush)
			AppendSurface new_surface
		Next
	End Method
	
	Method AddSurface:TSurface(brush:TBrush=Null,vertices=0,triangles=0)
		Local surface:TSurface=New TSurface
		surface.SetBrush brush
		surface.Resize vertices,triangles
		Return AppendSurface(surface)
	End Method
	
	Method AppendSurface:TSurface(surface:TSurface)
		_surfaces=_surfaces[.._surfaces.length+1]
		_surfaces[_surfaces.length-1]=surface
		surface._boundsupdatedmsg.Add BoundsUpdated,Self
		Return surface
	End Method
	
	Method SwapSurface(surface:TSurface,new_surface:TSurface)
		For Local i=0 To _surfaces.length-1
			If _surfaces[i]=surface _surfaces[i]=new_surface
		Next
	End Method
	
	Method GetSurface:TSurface(index)
		Return _surfaces[index]
	End Method
	
	Method CountSurfaces()
		Return _surfaces.length
	End Method
	
	Method UpdateBounds(force=False)
		For Local surface:TSurface=EachIn _surfaces		
			surface.UpdateBounds force
		Next
		If Not _updatebounds Return
		
		_minx=INFINITY;_miny=INFINITY;_minz=INFINITY
		_maxx=-INFINITY;_maxy=-INFINITY;_maxz=-INFINITY
		
		For Local surface:TSurface=EachIn _surfaces		
			_minx=Min(_minx,surface._minx);_maxx=Max(_maxx,surface._maxx)
			_miny=Min(_miny,surface._miny);_maxy=Max(_maxy,surface._maxy)
			_minz=Min(_minz,surface._minz);_maxz=Max(_maxz,surface._maxz)
		Next
		
		_width=_maxx-_minx;_height=_maxy-_miny;_depth=_maxz-_minz
		If _cullradius>=0
			Local radius#=Max(_width,Max(_height,_depth))/2.0
			Local radius_sqr#=radius*radius
			_cullradius=Sqr(radius_sqr+radius_sqr+radius_sqr)
		EndIf
		_updatebounds=False
	End Method
	
	Function BoundsUpdated(entity:Object)
		TMesh(entity)._updatebounds=True
	End Function
	
	Method GetSize(width# Var,height# Var,depth# Var)
		UpdateBounds
		width=_width;height=_height;depth=_depth
	End Method
	
	Method Fit(x#,y#,z#,width#,height#,depth#,uniform=False)
		UpdateBounds
		
		Local wr#,hr#,dr#
		wr=_width/width;hr=_height/height;dr=_depth/depth
		If uniform			
			If wr>=hr And wr>=dr
				y=y+((height-(_height/wr))/2.0)
				z=z+((depth-(_depth/wr))/2.0)
				
				height=_height/wr
				depth=_depth/wr
			ElseIf hr>dr
				x=x+((width-(_width/hr))/2.0)
				z=z+((depth-(_depth/hr))/2.0)
				
				width=_width/hr
				depth=_depth/hr
			Else
				x=x+((width-(_width/dr))/2.0)
				y=y+((height-(_height/dr))/2.0)
				
				width=_width/dr
				height=_height/dr
			EndIf
		EndIf
		wr=_width/width;hr=_height/height;dr=_depth/depth
		
		For Local surface:TSurface=EachIn _surfaces
			For Local v=0 To surface._vertexcnt-1
				Local vx#,vy#,vz#,nx#,ny#,nz#
				surface.GetCoords v,vx,vy,vz
				surface.GetNormal v,nx,ny,nz
				
				Local ux#,uy#,uz#
				
				If _width<0.0001 And _width>-0.0001 Then ux=0.0 Else ux=(vx-_minx)/_width
				If _height<0.0001 And _height>-0.0001 Then uy=0.0 Else uy=(vy-_miny)/_height
				If _depth<0.0001 And _depth>-0.0001 Then uz=0.0 Else uz=(vz-_minz)/_depth
				
				surface.SetCoords v,x+(ux*width),y+(uy*height),z+(uz*depth)
				surface.SetNormal v,nx*wr,ny*hr,nz*dr
			Next
		Next
		UpdateBounds True
	End Method

	Method Center()
		Local w#,h#,d#
		GetSize w,h,d
		Fit -w/2.0,-h/2.0,-d/2.0,w,h,d
	End Method
	
	Method Flip()
		For Local surface:TSurface=EachIn _surfaces
			surface.Flip()
		Next
	End Method

	Method Unweld()
		For Local surface:TSurface=EachIn _surfaces
			surface.Unweld()
		Next
	End Method
	
	Method GetCounts(vertices Var, triangles Var)
		vertices = 0
		triangles = 0
		For Local surface:TSurface=EachIn _surfaces
			triangles:+surface._trianglecnt
			vertices:+surface._vertexcnt
		Next
	End Method
	
	Method UpdateNormals(smoothing=True)
		For Local surface:TSurface=EachIn _surfaces
			surface.UpdateNormals(smoothing)
		Next
	End Method
	
	Method Scale(x#,y#,z#)
		Return Morph(TMatrix.Scale(x,y,z))
	End Method
	
	Method Rotate(pitch#,yaw#,roll#)
		Return Morph(TMatrix.YawPitchRoll(yaw,pitch,roll))
	End Method
	
	Method Position(x#,y#,z#)
		Return Morph(TMatrix.Translation(x#,y#,z#))
	End Method
	
	Method Morph(matrix:TMatrix)
		For Local surface:TSurface=EachIn _surfaces
			surface.Transform matrix
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
	
	Method GetCullParams(x# Var,y# Var,z# Var,radius# Var)		
		UpdateBounds
		
		x=_minx;y=_miny;z=_minz
		x=x+(_maxx-_minx)/2.0
		y=y+(_maxy-_miny)/2.0
		z=z+(_maxz-_minz)/2.0
		
		_matrix.TransformVec3 x,y,z
		
		Local sx#,sy#,sz#
		GetScale sx,sy,sz,True
		
		radius=GetCullRadius()
		
		Local rx#=radius*sx,ry#=radius*sy,rz#=radius*sz
		radius=Max(Max(rx,ry),rz)
	End Method
	
	Method ObjectEnumerator:TObjectArrayEnumerator()
		Return New TObjectArrayEnumerator.Create(_surfaces)
	End Method
End Type

