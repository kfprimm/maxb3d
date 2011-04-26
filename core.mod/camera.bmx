
Strict

Import "entity.bmx"
Import "worldconfig.bmx"

Const CAMMODE_NONE	= 0
Const CAMMODE_PERSP	= 1
Const CAMMODE_ORTHO	= 2

Const CLSMODE_COLOR	= 1
Const CLSMODE_DEPTH	= 2

Const FOGMODE_NONE		= 0
Const FOGMODE_LINEAR	= 1

Type TCamera Extends TEntity
	Field _projmode
	Field _fogmode,_fogr#,_fogg#,_fogb#,_fognear#,_fogfar#
	Field _viewx,_viewy,_viewwidth,_viewheight
	Field _clsmode,_near#,_far#
	Field _zoom#
	
	Field _lastglobal:TMatrix=New TMatrix
	Field _lastmodelview:TMatrix=New TMatrix
	Field _lastprojection:TMatrix=New TMatrix
	Field _lastviewport[4]
	Field _lastfrustum#[6,4]
	
	Method New()
		SetMode CAMMODE_PERSP
		SetFogMode FOGMODE_NONE
		SetFogRange 1,1000
		SetViewport 0,0,WorldConfig.Width,WorldConfig.Height
		SetClsMode CLSMODE_COLOR|CLSMODE_DEPTH
		SetColor 0,0,0
		SetRange 1,1000
		SetZoom 1.0
	End Method
	
	Method Copy:TCamera(parent:TEntity=Null)
		Local camera:TCamera=New TCamera
		camera.SetMode _projmode
		camera.SetFogMode _fogmode
		camera.SetFogColor _fogr*255.0,_fogg*255.0,_fogb*255.0
		camera.SetFogRange _fognear,_fogfar
		camera.SetViewport _viewx,_viewy,_viewwidth,_viewheight
		camera.SetClsMode _clsmode
		camera.SetRange _near,_far
		camera.SetZoom _zoom
		Return camera
	End Method
	
	Method GetMode()
		Return _projmode
	End Method
	Method SetMode(mode)
		_projmode=mode
	End Method	
	
	Method GetFogMode()
		Return _fogmode
	End Method
	Method SetFogMode(mode)
		_fogmode=mode
	End Method
	
	Method GetFogColor(red Var,green Var,blue Var)
		red=_fogr*255.0;green=_fogg*255.0;blue=_fogb*255.0
	End Method
	Method SetFogColor(red,green,blue)
		_fogr=red/255.0;_fogg=green/255.0;_fogb=blue/255.0
	End Method
	
	Method GetFogRange(near# Var,far# Var)
		near=_fognear;far=_fogfar
	End Method
	Method SetFogRange(near#,far#)
		_fognear=near;_fogfar=far
	End Method
	
	Method GetViewport(x Var,y Var,width Var,height Var)
		x=_viewx;y=_viewy;width=_viewwidth;height=_viewheight
	End Method
	Method SetViewport(x,y,width,height)
		_viewx=x;_viewy=y;_viewwidth=width;_viewheight=height
	End Method
	
	Method GetClsMode()
		Return _clsmode
	End Method
	Method SetClsMode(mode)
		_clsmode=mode
	End Method
	
	Method GetRange(near# Var,far# Var)
		near=_near;far=_far
	End Method
	Method SetRange(near#,far#)
		_near=near;_far=far
	End Method	
	
	Method GetZoom#()
		Return _zoom
	End Method
	Method SetZoom(zoom#)
		_zoom=zoom
	End Method
	
	Method Project(location:Object,x# Var,y# Var,z# Var)
		If TEntity(location)
			TEntity(location).GetPosition x,y,z
		ElseIf Float[](location)
			Local loc#[]=Float[](location)
			x=loc[0];y=loc[1];z=loc[2]
		EndIf
		
		Local w#=1.0
	    _lastmodelview.TransformVector x,y,z,w
	    _lastprojection.TransformVector x,y,z,w
	    If w=0 Return False
	    x:/w;y:/w;z:/w
	    
	    x=x*0.5+0.5;y=-y*0.5+0.5;z=z*0.5+0.5;
	
	    x=x*_lastviewport[2]+_lastviewport[0]
	    y=y*_lastviewport[3]+_lastviewport[1]
		Return True
	End Method
	
	Method ExtractFrustum()
		Local clip#[16],t#		
		
		Local modl:Float Ptr = _lastmodelview._m
		Local proj:Float Ptr = _lastprojection._m
		
		' Combine the two matrices (multiply projection by modelview)
		clip[ 0] = modl[ 0] * proj[ 0] + modl[ 1] * proj[ 4] + modl[ 2] * proj[ 8] + modl[ 3] * proj[12]
		clip[ 1] = modl[ 0] * proj[ 1] + modl[ 1] * proj[ 5] + modl[ 2] * proj[ 9] + modl[ 3] * proj[13]
		clip[ 2] = modl[ 0] * proj[ 2] + modl[ 1] * proj[ 6] + modl[ 2] * proj[10] + modl[ 3] * proj[14]
		clip[ 3] = modl[ 0] * proj[ 3] + modl[ 1] * proj[ 7] + modl[ 2] * proj[11] + modl[ 3] * proj[15]
		
		clip[ 4] = modl[ 4] * proj[ 0] + modl[ 5] * proj[ 4] + modl[ 6] * proj[ 8] + modl[ 7] * proj[12]
		clip[ 5] = modl[ 4] * proj[ 1] + modl[ 5] * proj[ 5] + modl[ 6] * proj[ 9] + modl[ 7] * proj[13]
		clip[ 6] = modl[ 4] * proj[ 2] + modl[ 5] * proj[ 6] + modl[ 6] * proj[10] + modl[ 7] * proj[14]
		clip[ 7] = modl[ 4] * proj[ 3] + modl[ 5] * proj[ 7] + modl[ 6] * proj[11] + modl[ 7] * proj[15]
		
		clip[ 8] = modl[ 8] * proj[ 0] + modl[ 9] * proj[ 4] + modl[10] * proj[ 8] + modl[11] * proj[12]
		clip[ 9] = modl[ 8] * proj[ 1] + modl[ 9] * proj[ 5] + modl[10] * proj[ 9] + modl[11] * proj[13]
		clip[10] = modl[ 8] * proj[ 2] + modl[ 9] * proj[ 6] + modl[10] * proj[10] + modl[11] * proj[14]
		clip[11] = modl[ 8] * proj[ 3] + modl[ 9] * proj[ 7] + modl[10] * proj[11] + modl[11] * proj[15]
		
		clip[12] = modl[12] * proj[ 0] + modl[13] * proj[ 4] + modl[14] * proj[ 8] + modl[15] * proj[12]
		clip[13] = modl[12] * proj[ 1] + modl[13] * proj[ 5] + modl[14] * proj[ 9] + modl[15] * proj[13]
		clip[14] = modl[12] * proj[ 2] + modl[13] * proj[ 6] + modl[14] * proj[10] + modl[15] * proj[14]
		clip[15] = modl[12] * proj[ 3] + modl[13] * proj[ 7] + modl[14] * proj[11] + modl[15] * proj[15]
		
		' Extract the numbers for the right plane
		_lastfrustum[0,0] = clip[ 3] - clip[ 0]
		_lastfrustum[0,1] = clip[ 7] - clip[ 4]
		_lastfrustum[0,2] = clip[11] - clip[ 8]
		_lastfrustum[0,3] = clip[15] - clip[12]
		
		' Normalize the result
		t = Sqr( _lastfrustum[0,0] * _lastfrustum[0,0] + _lastfrustum[0,1] * _lastfrustum[0,1] + _lastfrustum[0,2] * _lastfrustum[0,2] )
		_lastfrustum[0,0] :/ t
		_lastfrustum[0,1] :/ t
		_lastfrustum[0,2] :/ t
		_lastfrustum[0,3] :/ t
		
		' Extract the numbers for the left plane 
		_lastfrustum[1,0] = clip[ 3] + clip[ 0]
		_lastfrustum[1,1] = clip[ 7] + clip[ 4]
		_lastfrustum[1,2] = clip[11] + clip[ 8]
		_lastfrustum[1,3] = clip[15] + clip[12]
		
		' Normalize the result
		t = Sqr( _lastfrustum[1,0] * _lastfrustum[1,0] + _lastfrustum[1,1] * _lastfrustum[1,1] + _lastfrustum[1,2] * _lastfrustum[1,2] )
		_lastfrustum[1,0] :/ t
		_lastfrustum[1,1] :/ t
		_lastfrustum[1,2] :/ t
		_lastfrustum[1,3] :/ t
		
		' Extract the BOTTOM plane
		_lastfrustum[2,0] = clip[ 3] + clip[ 1]
		_lastfrustum[2,1] = clip[ 7] + clip[ 5]
		_lastfrustum[2,2] = clip[11] + clip[ 9]
		_lastfrustum[2,3] = clip[15] + clip[13]
		
		' Normalize the result
		t = Sqr( _lastfrustum[2,0] * _lastfrustum[2,0] + _lastfrustum[2,1] * _lastfrustum[2,1] + _lastfrustum[2,2] * _lastfrustum[2,2] )
		_lastfrustum[2,0] :/ t
		_lastfrustum[2,1] :/ t
		_lastfrustum[2,2] :/ t
		_lastfrustum[2,3] :/ t
		
		' Extract the TOP plane
		_lastfrustum[3,0] = clip[ 3] - clip[ 1]
		_lastfrustum[3,1] = clip[ 7] - clip[ 5]
		_lastfrustum[3,2] = clip[11] - clip[ 9]
		_lastfrustum[3,3] = clip[15] - clip[13]
		
		' Normalize the result
		t = Sqr( _lastfrustum[3,0] * _lastfrustum[3,0] + _lastfrustum[3,1] * _lastfrustum[3,1] + _lastfrustum[3,2] * _lastfrustum[3,2] )
		_lastfrustum[3,0] :/ t
		_lastfrustum[3,1] :/ t
		_lastfrustum[3,2] :/ t
		_lastfrustum[3,3] :/ t
		
		' Extract the FAR plane
		_lastfrustum[4,0] = clip[ 3] - clip[ 2]
		_lastfrustum[4,1] = clip[ 7] - clip[ 6]
		_lastfrustum[4,2] = clip[11] - clip[10]
		_lastfrustum[4,3] = clip[15] - clip[14]
		
		' Normalize the result
		t = Sqr( _lastfrustum[4,0] * _lastfrustum[4,0] + _lastfrustum[4,1] * _lastfrustum[4,1] + _lastfrustum[4,2] * _lastfrustum[4,2] )
		_lastfrustum[4,0] :/ t
		_lastfrustum[4,1] :/ t
		_lastfrustum[4,2] :/ t
		_lastfrustum[4,3] :/ t
		
		' Extract the NEAR plane
		_lastfrustum[5,0] = clip[ 3] + clip[ 2]
		_lastfrustum[5,1] = clip[ 7] + clip[ 6]
		_lastfrustum[5,2] = clip[11] + clip[10]
		_lastfrustum[5,3] = clip[15] + clip[14]

		' Normalize the result 
		t = Sqr( _lastfrustum[5,0] * _lastfrustum[5,0] + _lastfrustum[5,1] * _lastfrustum[5,1] + _lastfrustum[5,2] * _lastfrustum[5,2] )
		_lastfrustum[5,0] :/ t
		_lastfrustum[5,1] :/ t
		_lastfrustum[5,2] :/ t
		_lastfrustum[5,3] :/ t
	End Method

End Type
