
Strict

Import BRL.LinkedList
Import MaxB3D.Math
Import "brush.bmx"
Import "collision.bmx"
Import "worldconfig.bmx"

Const PICKMODE_OFF		= 1
Const PICKMODE_SPHERE	= 2
Const PICKMODE_POLYGON	= 3
Const PICKMODE_BOX		= 4

Type TEntity
	Field _config:TWorldConfig
	Field _matrix:TMatrix=TMatrix.Identity(), _lockmatrix
	
	Field _name$
	Field _px#,_py#,_pz#
	Field _rx#,_ry#,_rz#
	Field _sx#,_sy#,_sz#
		
	Field _brush:TBrush=New TBrush
	
	Field _parent:TEntity,_childlist:TList=CreateList()
	Field _hidden,_order
	
	Field _collision:TCollision[]
	Field _oldx#,_oldy#,_oldz#
	Field _radiusx#,_radiusy#
	Field _boxx#,_boxy#,_boxz#,_boxwidth#,_boxheight#,_boxdepth#
	Field _type,_typelink:TLink
	Field _pickmode, _obscurer
	
	Field _cullradius#
	
	Field _alphaorder#
	
	Field _linklist:TList=CreateList()
	
	Method New()
		SetScale 1,1,1
	End Method
	
	Method Free()
		For Local child:TEntity=EachIn _childlist
			child.Free()
		Next
		For Local link:TLink=EachIn _linklist
			RemoveLink link
		Next
	End Method
	
	Method AddLink(link:TLink)
		_linklist.AddLast link
	End Method
	
	Method Lists[]()
		Return [WORLDLIST_ENTITY]
	End Method
	
	Method AddToWorld:TEntity(config:TWorldConfig, parent:TEntity=Null)
		_config = config
		SetParent parent,False
		For Local l=EachIn Lists()
			AddLink _config.AddObject(Self,l)
		Next
		Return Self
	End Method
	
	Method CopyData:TEntity(entity:TEntity)
		SetBrush entity.GetBrush()
		SetName entity.GetName()
		Return Self
	End Method
	
	Method Copy_:TEntity(parent:TEntity=Null)
		Return New Self.CopyData(Self).AddToWorld(_config,parent)
	End Method
	
	Method Copy:TEntity(parent:TEntity=Null) Abstract
	
	Method AddParent(parent:TEntity)
		_parent=parent
		If parent
			_matrix.Overwrite parent._matrix
			parent._childlist.AddLast Self
		EndIf
	End Method
	
	Method GetParent:TEntity()
		Return _parent
	End Method
	Method SetParent(parent:TEntity,glob=True)
		Local gpx#,gpy#,gpz#		
		Local grx#,gry#,grz#		
		Local gsx#,gsy#,gsz#
		
		GetPosition gpx,gpy,gpz,True
		GetRotation grx,gry,grz,True
		GetScale gsx,gsy,gsz,True
		
		If _parent
			For Local entity:TEntity=EachIn _parent._childlist
				If entity=Self ListRemove(_parent._childlist,Self)
			Next
			_parent=Null
		EndIf

		_px=gpx;_py=gpy;_pz=gpz
		_rx=grx;_ry=gry;_rz=grz
		_sx=gsx;_sy=gsy;_sz=gsz
		
		If parent=Null UpdateMatrix(True);Return		
		
		AddParent(parent)
		If glob				
			SetPosition(gpx,gpy,gpz,True)
			SetRotation(grx,gry,grz,True)
			SetScale(gsx,gsy,gsz,True)
		Else			
			UpdateMatrix(False)				
		EndIf			
	End Method
	
	Method CountChildren(recursive=False)
		Local count
		If recursive
			For Local child:TEntity=EachIn _childlist
				count:+child.CountChildren(True)
			Next
		EndIf
		Return _childlist.Count()+count
	End Method
	
	Method FindChild:TEntity(name$,recursive=False)
		For Local child:TEntity=EachIn _childlist
			If child.GetName()=name Return child
		Next
		If recursive
			For Local child:TEntity=EachIn _childlist
				Local entity:TEntity = child.FindChild(name, True)
				If entity Return entity
			Next
		EndIf
	End Method
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
	
	Method GetBrush:TBrush()
		Return _brush.Copy()
	End Method
	Method SetBrush(brush:TBrush)
		_brush.Load brush
	End Method
	
	Method GetColor(red Var,green Var,blue Var)
		Return _brush.GetColor(red,green,blue)
	End Method
	Method SetColor(red,green,blue)
		Return _brush.SetColor(red,green,blue)
	End Method
	
	Method GetAlpha#()
		Return _brush.GetAlpha()
	End Method
	Method SetAlpha(alpha#)
		_brush.SetAlpha(alpha)
	End Method
	
	Method GetShine#()
		Return _brush.GetShine()
	End Method
	Method SetShine(shine#)
		_brush.SetShine(shine)
	End Method
	
	Method GetTexture:TTexture(index)
		Return _brush.GetTexture(index)
	End Method
	Method SetTexture(texture:TTexture,index=0,frame=0)
		Return _brush.SetTexture(texture,index,frame)
	End Method
	
	Method GetFX()
		Return _brush.GetFX()
	End Method
	Method SetFX(fx)
		Return _brush.SetFX(fx)
	End Method
	
	Method GetBlend()
		Return _brush.GetBlend()
	End Method
	Method SetBlend(blend)
		Return _brush.SetBlend(blend)
	End Method
	
	Method GetShader:TShader()
		Return _brush.GetShader()
	End Method
	Method SetShader(shader:TShader)
		Return _brush.SetShader(shader)
	End Method
	
	Method GetScale(x# Var,y# Var,z# Var,glob=False)
		If glob
			x=_matrix._m[0,0]
			y=_matrix._m[1,1]
			z=_matrix._m[2,2]
		Else
			x=_sx;y=_sy;z=_sz
		EndIf
	End Method
	Method SetScale(x#,y#,z#,glob=False)
		_sx=x;_sy=y;_sz=z
		If glob=True And _parent<>Null
			Local entity:TEntity=Self
			Repeat
				_sx:/entity._parent._sx
				_sy:/entity._parent._sy
				_sz:/entity._parent._sz
				entity=entity._parent
			Until entity._parent=Null
		EndIf
		RefreshMatrix()	
	End Method
	
	Method Transform(matrix:TMatrix,glob=False)
		SetMatrix matrix.Multiply(_matrix),glob
	End Method
	
	Method Turn(pitch#,yaw#,roll#,glob=False)
		_rx:-pitch;_ry:+yaw;_rz:+roll
		RefreshMatrix()
	End Method
	
	Method Point(target:Object,roll#=0.0)
		Local x#,y#,z#,tx#,ty#,tz#
		GetPosition x,y,z,True
		GetTargetPosition target,tx,ty,tz 

		Local xdiff#=x-tx,ydiff#=y-ty,zdiff#=z-tz

		Local dist22#=Sqr((xdiff*xdiff)+(zdiff*zdiff))
		Local pitch#=ATan2(ydiff,dist22)
		Local yaw#=-ATan2(xdiff,-zdiff)

		SetRotation pitch,yaw,roll,True
	End Method
	
	Method GetDistance#(target:Object)
		Local x#,y#,z#,tx#,ty#,tz#
		GetPosition x,y,z,True
		GetTargetPosition target,tx,ty,tz		
		Return Sqr((x-tx)*(x-tx)+(y-ty)*(y-ty)+(z-tz)*(z-tz))
	End Method
	
	Function GetTargetPosition(target:Object,x# Var,y# Var,z# Var)
		Assert target,"Null target given."
		If TEntity(target) TEntity(target).GetPosition x,y,z,True
		If Float[](target)
			Local coords#[]=Float[](target)
			If coords.length>0 x=coords[0]
			If coords.length>1 y=coords[1]
			If coords.length>2 z=coords[2]
		EndIf
		Assert "Invalid target given."
	End Function	
	
	Method GetRotation(pitch# Var,yaw# Var,roll# Var,glob=False)
		If glob
			_matrix.GetRotation pitch,yaw,roll
			pitch:*-1
		Else
			pitch=-_rx;yaw=_ry;roll=_rz
		EndIf
	End Method
	Method SetRotation(pitch#,yaw#,roll#,glob=False)
		_rx=-pitch;_ry=yaw;_rz=roll
		If glob And _parent<>Null
			Local rx#,ry#,rz#
			_parent.GetRotation rx,ry,rz
			_rx:-rx;_ry:+ry;_rz:+rz			
		EndIf
		RefreshMatrix()
	End Method
		
	Method GetPosition(x# Var,y# Var,z# Var,glob=False)
		x=_px;y=_py;z=_pz
		If glob _matrix.GetPosition x,y,z
	End Method
	Method SetPosition(x#,y#,z#,glob=False)
		_px=x;_py=y;_pz=z
		
		If glob And _parent<>Null
			Local px#,py#,pz#
			_parent.GetPosition px,py,pz,True
			_px:-px;_py:-py;_pz:-pz
		EndIf
		
		RefreshMatrix()
	End Method
	
	Method Move(x#,y#,z#)
		Local matrix:TMatrix=TMatrix.Identity()
		matrix=TMatrix.YawPitchRoll(_ry,_rx,_rz).Multiply(matrix)
		matrix=TMatrix.Translation(x,y,z).Multiply(matrix)
	
		matrix.GetPosition(x,y,z)		
		_px:+x;_py:+y;_pz:+z

		RefreshMatrix()
	End Method
	
	Method Translate(x#,y#,z#,glob=True)
		If glob And _parent			
			Local ax#,ay#,az#
			GetRotation ax,ay,az,True
						
			Local matrix:TMatrix=TMatrix.Roll(-az)
			matrix=matrix.Multiply(TMatrix.Pitch(-ax))
			matrix=matrix.Multiply(TMatrix.Yaw(-ay))
			matrix=matrix.Multiply(TMatrix.Translation(x,y,z))
			
			matrix.GetPosition x,y,z
		EndIf
		
		_px:+x;_py:+y;_pz:+z

		RefreshMatrix()
	End Method
	
	Method GetVisible()
		Local entity:TEntity=Self
		While entity<>Null
			If entity._hidden=True Return False
			entity=entity._parent
		Wend
		Return True
	End Method
	Method SetVisible(visible)
		_hidden=Not visible
	End Method
	
	Method GetOrder()
		Return _order
	End Method
	Method SetOrder(order)
		_order=order
	End Method
	
	Method GetCollisions:TCollision[]()
		Return _collision
	End Method
	
	Method GetRadius(x# Var,y# Var)
		x=_radiusx;y=_radiusy
	End Method
	Method SetRadius(x#,y#=-1)
		_radiusx=x;_radiusy=x
		If y>-1 _radiusy=y
	End Method
	
	Method GetBox(x# Var,y# Var,z# Var,width# Var,height# Var,depth# Var)
		x=_boxx;y=_boxy;z=_boxz
		width=_boxwidth;height=_boxheight;depth=_boxdepth
	End Method
	Method SetBox(x#,y#,z#,width#,height#,depth#)
		_boxx=x;_boxy=y;_boxz=z
		_boxwidth=width;_boxheight=height;_boxdepth=depth
	End Method
	
	Method Reset()
		_collision=Null
		GetPosition _oldx,_oldy,_oldz,True
	End Method
	
	Method GetType()
		Return _type
	End Method
	Method SetType(typ,recursive=False)
		If _typelink
			_linklist.Remove(_typelink)
			_typelink.Remove()
			_typelink=Null
		EndIf
		
		If typ>0
			If _config.CollisionType[typ]=Null _config.CollisionType[typ]=CreateList()
			_typelink=_config.CollisionType[typ].AddLast(Self)
			AddLink _typelink
		EndIf		
		
		_type=typ
		GetPosition _oldx,_oldy,_oldz,True
		
		If recursive
			For Local child:TEntity=EachIn _childlist
				child.SetType typ,True
			Next
		EndIf
	End Method
	
	Method GetCullRadius#()
		Return Abs(_cullradius)
	End Method
	Method SetCullRadius(radius#)
		_cullradius=-radius
	End Method

	Method GetCullParams(x# Var,y# Var,z# Var,radius# Var)
		GetPosition x,y,z,True
		radius=GetCullRadius()
	End Method
	
	Method GetPickMode(mode Var, obscurer Var)
		mode = _pickmode
		obscurer = _obscurer
	End Method	
	Method SetPickMode(mode, obscurer=True)
		_pickmode = mode
		_obscurer = obscurer
	End Method
	
	Method HasAlpha()
		Return _brush.HasAlpha()
	End Method
	
	Method GetMatrix:TMatrix(alternate=False,copy=True)
		If copy Return _matrix.Copy()
		Return _matrix
	End Method
	Method SetMatrix(matrix:TMatrix,glob=True)
		Local x#,y#,z#,pitch#,yaw#,roll#,sx#,sy#,sz#
		matrix.GetPosition x,y,z
		matrix.GetRotation pitch,yaw,roll
		matrix.GetScale sx,sy,sz
		
		LockMatrix
		SetPosition x,y,z,glob
		SetRotation pitch,yaw,roll,glob
		SetScale sx,sy,sz,glob
		UnlockMatrix
	End Method
	
	Method LockMatrix()
		_lockmatrix=True
	End Method
	Method UnlockMatrix()
		_lockmatrix=False
		RefreshMatrix()
	End Method
	
	Method RefreshMatrix()
		If _lockmatrix Return
		If _parent<>Null
			_matrix.Overwrite _parent._matrix
			UpdateMatrix False
		Else
			UpdateMatrix True
		EndIf		
		
		For Local child:TEntity=EachIn _childlist
			child.RefreshMatrix()
		Next
	End Method
	
	Method UpdateMatrix(loadidentity)
		If loadidentity _matrix=TMatrix.Identity()
		_matrix=TMatrix.Translation(_px,_py,_pz).Multiply(_matrix)
		_matrix=TMatrix.YawPitchRoll(_ry,_rx,_rz).Multiply(_matrix)
		_matrix=TMatrix.Scale(_sx,_sy,_sz).Multiply(_matrix)
	End Method
	
	Method ObjectEnumerator:Object()
		Return TChildrenEnumerator.Create(_childlist)
	End Method
End Type

Type TChildrenEnumerator
	Field _children:TEntity[],_index=-1
	
	Function Create:TChildrenEnumerator(list:TList)
		Local enum:TChildrenEnumerator=New TChildrenEnumerator
		enum._children=TEntity[](list.ToArray())
		Return enum
	End Function
	
	Method HasNext()
		Return _index>=_children.length-1
	End Method
	
	Method NextObject:Object()
		_index:+1
		Return _children[_index]
	End Method
End Type
