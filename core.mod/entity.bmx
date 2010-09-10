
Strict

Import BRL.LinkedList
Import MaxB3D.MathEx
Import "brush.bmx"
Import "worldconfig.bmx"

Type TEntity
	Field _matrix:TMatrix=TMatrix.Identity()
	
	Field _name$
	Field _px#,_py#,_pz#
	Field _rx#,_ry#,_rz#
	Field _sx#,_sy#,_sz#
	
	Field _order
	
	Field _brush:TBrush=New TBrush
	
	Field _parent:TEntity,_childlist:TList=CreateList()
	Field _hidden
	
	Field _linklist:TList=CreateList()
	
	Method New()
		SetPosition 0,0,0
		SetScale 1,1,1
	End Method
	
	Method Free()
		For Local link:TLink=EachIn _linklist
			RemoveLink link
		Next
	End Method
	
	Method AddLink(link:TLink)
		_linklist.AddLast link
	End Method
	
	Method AddToWorld(parent:TEntity=Null,list[])
		SetParent parent,False
		AddLink WorldConfig.AddObject(Self,WORLDLIST_ENTITY)
		For Local l=EachIn list
			AddLink WorldConfig.AddObject(Self,l)
		Next
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
	
	Method Turn(pitch#,yaw#,roll#,glob=False)
		_rx:+pitch;_ry:+yaw;_rz:+roll
		RefreshMatrix()
	End Method
	
	Method GetRotation(pitch# Var,yaw# Var,roll# Var,glob=False)
		If glob
			_matrix.GetRotation pitch,yaw,roll
		Else
			pitch=_rx;yaw=_ry;roll=_rz
		EndIf
	End Method
	Method SetRotation(pitch#,yaw#,roll#,glob=False)
		If glob
		
		Else
			_rx=pitch;_ry=yaw;_rz=roll
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
	
	Method RefreshMatrix()
		If _parent<>Null
			_matrix=_parent._matrix
			UpdateMatrix False
		Else
			UpdateMatrix True
		EndIf		
		UpdateChildren()
	End Method
	
	Method UpdateMatrix(loadidentity)
		If loadidentity _matrix=TMatrix.Identity()
		_matrix=TMatrix.Translation(_px,_py,_pz).Multiply(_matrix)
		_matrix=TMatrix.YawPitchRoll(_ry,_rx,_rz).Multiply(_matrix)
		_matrix=TMatrix.Scale(_sx,_sy,_sz).Multiply(_matrix)
	End Method
	
	Method UpdateChildren()
		For Local child:TEntity=EachIn _childlist
			child._matrix=_matrix
			child.UpdateMatrix(False)
			child.UpdateChildren()
		Next
	End Method
	
End Type

Type TRenderEntity Extends TEntity
	
End Type