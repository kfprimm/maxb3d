
Strict

Import "worldconfig.bmx"
Import "entity.bmx"
Import "surface.bmx"
Import "bone.bmx"
Import "animation.bmx"
Import "bone_animator.bmx"
Import "vertex_animator.bmx"

Type TMesh Extends TAnimEntity 
	Field _surfaces:TSurface[]

	Field _animator:TAnimator
	Field _bone:TBone[]
	
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
		mesh._surfaces=_surfaces[..]
		Return mesh
	End Method
	
	Method Clone:TMesh(parent:TEntity=Null)
		Local mesh:TMesh=New TMesh
		mesh.AddToWorld parent,[WORLDLIST_MESH,WORLDLIST_RENDER]
		mesh._surfaces=New TSurface[_surfaces.length]
		For Local i=0 To _surfaces.length-1
			mesh._surfaces[i]=_surfaces[i].Copy()
		Next
		Return mesh
	End Method
	
	Method AddSurface:TSurface(vertices=0,triangles=0)
		Local surface:TSurface=New TSurface
		surface.Resize vertices,triangles
		Return AppendSurface(surface)
	End Method
	
	Method AppendSurface:TSurface(surface:TSurface)
		_surfaces=_surfaces[.._surfaces.length+1]
		_surfaces[_surfaces.length-1]=surface
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
	
	Method GetSize(width# Var,height# Var,depth# Var)
		Local minx#=999999999,miny#=999999999,minz#=999999999
		Local maxx#=-999999999,maxy#=-999999999,maxz#=-999999999
		
		For Local surface:TSurface=EachIn _surfaces		
			surface.UpdateBounds
			minx=Min(minx,surface._minx);maxx=Max(maxx,surface._maxx)
			miny=Min(miny,surface._miny);maxy=Max(maxy,surface._maxy)
			minz=Min(minz,surface._minz);maxz=Max(maxz,surface._maxz)
		Next
		width=maxx-minx;height=maxy-miny;depth=maxz-minz
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
	
	Method UpdateNormals()
		For Local surface:TSurface=EachIn _surfaces
			surface.UpdateNormals()
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
			If loader.Run(mesh,stream,url) Return True
			loader=loader._next
		Wend
		If stream CloseStream stream
		Return False
	End Function
	
	Method Run(mesh:TMesh,stream:TStream,url:Object) Abstract
End Type

Type TMeshLoaderNull Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		If String(url)="*null*" Return True
		Return False
	End Method
End Type
New TMeshLoaderNull
