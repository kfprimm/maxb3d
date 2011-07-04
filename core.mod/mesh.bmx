
Strict

Import "worldconfig.bmx"
Import "entity.bmx"
Import "surface.bmx"
Import "bone.bmx"
Import "bone_animator.bmx"
Import "vertex_animator.bmx"

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
		If _brush._a<>1 Or _brush._fx&FX_FORCEALPHA Return True
		For Local surface:TSurface=EachIn _surfaces
			If surface.HasAlpha() Return True
		Next
	End Method
	
	Method CopyData(entity:TEntity)
		Super.CopyData entity
		
		Local mesh:TMesh=TMesh(entity)
	End Method
	
	Method Copy:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		mesh.CopyData Self
		
		For Local surface:TSurface=EachIn _surfaces
			mesh.AppendSurface surface
		Next
		
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]		
		Return mesh
	End Method
	
	Method Clone:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		mesh.CopyData Self
		
		For Local surface:TSurface=EachIn _surfaces
			mesh.AppendSurface surface.Copy()
		Next
		
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
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
	
	Method UpdateBounds()
		For Local surface:TSurface=EachIn _surfaces		
			surface.UpdateBounds
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
		width=_width;height=_height;_depth=depth
	End Method
	
	Method Fit(x#,y#,z#,width#,height#,depth#,uniform=False)
		Local mw#,mh#,md#,wr#,hr#,dr#
		GetSize mw,mh,md
		wr=mw/width;hr=mh/height;dr=md/depth		
		If uniform	
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
		
		Local mx#=_maxx-_minx,my#=_maxy-_miny,mz#=_maxz-_minz		
		For Local surface:TSurface=EachIn _surfaces				
			For Local v=0 To surface._vertexcnt-1		
				Local vx#,vy#,vz#,nx#,ny#,nz#
				surface.GetCoord v,vx,vy,vz
				surface.GetNormal v,nx,ny,nz
				
				Local ux#,uy#,uz#
				
				If mx<0.0001 And mx>-0.0001 Then ux=0.0 Else ux=(vx-_minx)/mx
				If my<0.0001 And my>-0.0001 Then uy=0.0 Else uy=(vy-_miny)/my
				If mz<0.0001 And mz>-0.0001 Then uz=0.0 Else uz=(vz-_minz)/mz
				
				surface.SetCoord v,x+(ux*width),y+(uy*height),z+(uz*depth)
				surface.SetNormal v,nx*wr,ny*hr,nz*dr
			Next
		Next
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
	
	Method CountTriangles()
		Local count
		For Local surface:TSurface=EachIn _surfaces
			count:+surface._trianglecnt
		Next
		Return count
	End Method
	
	Method CountVertices()
		Local count
		For Local surface:TSurface=EachIn _surfaces
			count:+surface._vertexcnt
		Next
		Return count
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
	
	Method SetAnim(seq:TAnimSeq,mode=ANIMATION_LOOP,speed#=1.0)
		_animator._current=seq
		_animator._mode=mode
		_animator._speed=speed
		If seq _animator._frame=seq._start
	End Method
	
	Method AddAnimSeq:TAnimSeq(start_frame,end_frame)
	'	Local seq:TAnimSeq=New TAnimSeq
	'	seq._start=start_frame
	'	seq._end=end_frame
	'	_animseq=_animseq[.._animseq.length+1]
	'	_animseq[_animseq.length-1]=seq
	'	Return seq
	End Method
	
	Method ExtractAnimSeq:TAnimSeq(start_frame,end_frame)
		Local seq:TAnimSeq=New TAnimSeq
		seq._start=start_frame
		seq._end=end_frame
		Return seq
	End Method
	
	Method GetAnimSeq:TAnimSeq()
		Return _animator._current
	End Method
	Method SetAnimSeq(seq:TAnimSeq)
		_animator._current=seq
	End Method
	
	Method GetAnimMode()
		Return _animator._mode
	End Method
	Method SetAnimMode(mode)
		_animator._mode=mode
	End Method
	
	Method GetAnimSpeed#()
		Return _animator._speed
	End Method
	Method SetAnimSpeed(speed#)
		_animator._speed=speed
	End Method
	
	Method GetFrame#()
		Return _animator._frame
	End Method
	
	Method SetAnimKey(frame,key:Object)
		_animator.SetKey(frame,key)
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
	
	Method ObjectEnumerator:TSurfaceEnumerator()
		Return New TSurfaceEnumerator.Create(_surfaces)
	End Method
End Type

Type TSurfaceEnumerator
	Field _surfaces:TSurface[],_pos=-1
	
	Method Create:TSurfaceEnumerator(surfaces:TSurface[])
		_surfaces=surfaces[..]
		Return Self
	End Method
	
	Method NextObject:Object()
		_pos:+1
		Return _surfaces[_pos]
	End Method
	
	Method HasNext()
		Return _pos<_surfaces.length-1
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
	
	Function Load(mesh:TMesh,url:Object)
		Local loader:TMeshLoader=_start
		Local stream:TStream=TStream(url)
		If stream=Null stream=ReadStream(stream)
		While loader<>Null
			If stream SeekStream stream,0
?Not Debug
			Try
?
				If loader.Run(mesh,stream,url) Return True
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
	
	Method Run(mesh:TMesh,stream:TStream,url:Object) Abstract
	
	Method Name$() Abstract
	Method ModuleName$() Abstract
End Type

Type TMeshLoaderNull Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If String(url)="*null*" Return True
		Return False
	End Method
	
	Method Name$()
		Return "Null"
	End Method
	Method ModuleName$()
		Return "core"
	End Method
End Type
New TMeshLoaderNull
