
Strict

Rem
	bbdoc: Direct3D 9 renderer for MaxB3D
End Rem
Module MaxB3D.D3D9Driver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.D3D9Max2D

?Win32

Import "d3d9.bmx"

Private 
Function Pow2Size( n )
	Local t=1
	While t<n
		t:*2
	Wend
	Return t
End Function

Public

Type TD3D9MaxB3DDriver Extends TMaxB3DDriver
	Field _d3ddev:IDirect3DDevice9
	Field _viewporton
	
	Method SetGraphics( g:TGraphics )
		Super.SetGraphics g
		_d3ddev=Null
		If g<>Null
			_d3ddev=TD3D9Graphics(TMax2DGraphics(g)._graphics).GetDirect3DDevice()
			EndMax2D
		EndIf
	End Method
	
	Method Flip(sync)
		Super.Flip(sync)
		If _d3ddev<>Null EndMax2D ' TODO: Figure out when this needs to be called. Most likely NOT always!
	End Method
	
	Method GetCaps:TCaps()
		Local caps:TCaps=New TCaps
		Return caps
	End Method
	
	Method BeginMax2D()
		Global identity:TMatrix=TMatrix.Identity()
		Local width=GraphicsWidth(),height=GraphicsHeight()
		Local matrix#[]=[..
		2.0/width,0.0,0.0,0.0,..
		 0.0,-2.0/height,0.0,0.0,..
		 0.0,0.0,1.0,0.0,..
		 -1-(1.0/width),1+(1.0/height),1.0,1.0]
		
		_d3ddev.SetTransform D3DTS_PROJECTION,matrix
		_d3ddev.SetTransform D3DTS_WORLD,identity.ToPtr()
		_d3ddev.SetTransform D3DTS_VIEW,identity.ToPtr()
		_d3ddev.SetTransform D3DTS_TEXTURE0,identity.ToPtr()
		
		_d3ddev.SetVertexDeclaration Null
		_d3ddev.SetIndices Null
		_d3ddev.SetFVF D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1
		
		_d3ddev.SetRenderState D3DRS_LIGHTING,False
		_d3ddev.SetRenderState D3DRS_ZENABLE,False
		_d3ddev.SetRenderState D3DRS_SCISSORTESTENABLE,_viewporton		
		
		_d3ddev.SetRenderState D3DRS_ALPHATESTENABLE,True
		
		_d3ddev.SetRenderState D3DRS_WRAP0, 0
		
		_d3ddev.SetRenderState D3DRS_FOGENABLE,False
		
		For Local i=2 To 7
			_d3ddev.SetTexture i,Null
		Next
		
		_d3ddev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_MODULATE
		_d3ddev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_MODULATE
		
		_d3ddev.SetRenderState D3DRS_CULLMODE,D3DCULL_NONE
	End Method
	
	Method EndMax2D()
		_d3ddev.SetRenderState D3DRS_ZENABLE,True
		_d3ddev.SetRenderState D3DRS_ZWRITEENABLE,True

		_d3ddev.GetRenderState D3DRS_SCISSORTESTENABLE,_viewporton
		_d3ddev.SetRenderState D3DRS_SCISSORTESTENABLE,True
		
		_d3ddev.SetRenderState D3DRS_LIGHTING,True
		_d3ddev.SetRenderState D3DRS_NORMALIZENORMALS,True
		_d3ddev.SetRenderState D3DRS_AMBIENT,D3DCOLOR_RGB(WorldConfig.AmbientRed,WorldConfig.AmbientGreen,WorldConfig.AmbientBlue)
		_d3ddev.SetRenderState D3DRS_COLORVERTEX, True
		_d3ddev.SetRenderState D3DRS_DIFFUSEMATERIALSOURCE,D3DMCS_MATERIAL
		
		_d3ddev.SetRenderState D3DRS_SHADEMODE,D3DSHADE_GOURAUD
		
		'_d3ddev.SetRenderState D3DRS_ALPHAREF, 1
		'_d3ddev.SetRenderState D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL
				
		_d3ddev.SetRenderState D3DRS_CULLMODE,D3DCULL_CW		
	End Method
	
	Method SetCamera(camera:TCamera)
		Local clearflags		
		If camera._clsmode&CLSMODE_COLOR clearflags:|D3DCLEAR_TARGET
		If camera._clsmode&CLSMODE_DEPTH clearflags:|D3DCLEAR_ZBUFFER

		Local viewport[]=[camera._viewx,camera._viewy,camera._viewwidth-camera._viewx,camera._viewheight-camera._viewy]
		_d3ddev.SetScissorRect viewport
		_d3ddev.Clear(1,viewport,clearflags,D3DCOLOR_XRGB(camera._brush._r*255,camera._brush._g*255,camera._brush._b*255),1.0,0)
		
		Select camera._fogmode
		Case FOGMODE_LINEAR
			_d3ddev.SetRenderState D3DRS_FOGENABLE,True
			_d3ddev.SetRenderState D3DRS_FOGSTART,Int(Varptr camera._fognear)
			_d3ddev.SetRenderState D3DRS_FOGEND,Int(Varptr camera._fogfar)
		Default
			_d3ddev.SetRenderState D3DRS_FOGENABLE,False
		End Select
		
		Local ratio#=(Float(camera._viewwidth)/camera._viewheight)		
		Local proj_matrix:TMatrix=TMatrix.PerspectiveFovRH(ATan((1.0/(camera._zoom*ratio)))*2.0,ratio#,Max(0,camera._near-0.396250010),camera._far) ' Ugly hack. Real cause needs investigation.
		proj_matrix=TMatrix.Scale(-1,1,-1).Multiply(proj_matrix)
		_d3ddev.SetTransform D3DTS_PROJECTION,proj_matrix.ToPtr()
		
		Local matrix:TMatrix=camera._matrix.Inverse()
		_d3ddev.SetTransform D3DTS_VIEW,matrix.ToPtr()
		
		camera._lastmodelview=matrix
		camera._lastprojection=proj_matrix
		
		camera._lastviewport[0]=camera._viewx
		camera._lastviewport[1]=camera._viewy
		camera._lastviewport[2]=camera._viewwidth
		camera._lastviewport[3]=camera._viewheight
		
		camera._lastfrustum=TFrustum.Extract(camera._lastmodelview,camera._lastprojection)
	End Method
	
	Method SetLight(light:TLight,index)
		If light=Null 
			_d3ddev.LightEnable index,False
			Return
		EndIf
		
		Local brush:TBrush=light._brush

		Global d3dlight:D3DLIGHT9=New D3DLIGHT9
		d3dlight.Type_=D3DLIGHT_DIRECTIONAL   
		d3dlight.Diffuse_r=brush._r;d3dlight.Diffuse_g=brush._g;d3dlight.Diffuse_b=brush._b;d3dlight.Diffuse_a=brush._a
		'd3dlight.Ambient_r=WorldConfig.AmbientRed/255.0;d3dlight.Ambient_g=WorldConfig.AmbientGreen/255.0;d3dlight.Ambient_b=WorldConfig.AmbientBlue/255.0;d3dlight.Ambient_a=1.0
		
		d3dlight.Direction_x=0.0;d3dlight.Direction_y=0.0;d3dlight.Direction_z=1.0
				
		Local matrix:TMatrix=light._matrix,w#=1
		matrix.TransformVector d3dlight.Direction_x,d3dlight.Direction_y,d3dlight.Direction_z,w
		matrix.GetPosition d3dlight.Position_x,d3dlight.Position_y,d3dlight.Position_z		
		
		d3dlight.Range=light._range		
		
		_d3ddev.SetLight index,d3dlight
		_d3ddev.LightEnable index,True
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha)
		_d3ddev.SetRenderState D3DRS_ALPHATESTENABLE,False
		
		Local alpha_blending = (brush._fx&FX_FORCEALPHA Or hasalpha)>0
		_d3ddev.SetRenderState D3DRS_ALPHABLENDENABLE,alpha_blending 
		_d3ddev.SetRenderState D3DRS_ZWRITEENABLE,Not alpha_blending 
		
		If brush._fx&FX_FULLBRIGHT
			_d3ddev.SetRenderState D3DRS_AMBIENT,$ffffffff
		Else
			_d3ddev.SetRenderState D3DRS_AMBIENT,D3DCOLOR_RGB(WorldConfig.AmbientRed,WorldConfig.AmbientGreen,WorldConfig.AmbientBlue)
		EndIf
		
		If brush._fx&FX_NOCULLING
			_d3ddev.SetRenderState D3DRS_CULLMODE,D3DCULL_NONE
		Else
			_d3ddev.SetRenderState D3DRS_CULLMODE,D3DCULL_CW
		EndIf
		
		If brush._fx&FX_WIREFRAME Or WorldConfig.Wireframe
			_d3ddev.SetRenderState D3DRS_FILLMODE,D3DFILL_WIREFRAME
		Else
			_d3ddev.SetRenderState D3DRS_FILLMODE,D3DFILL_SOLID
		EndIf
		
		Local material:D3DMATERIAL9 = New D3DMATERIAL9
		material.Diffuse_r=brush._r;material.Diffuse_g=brush._g;material.Diffuse_b=brush._b;material.Diffuse_a=brush._a
		material.Ambient_r=brush._r;material.Ambient_g=brush._g;material.Ambient_b=brush._b;material.Ambient_a=brush._a

		_d3ddev.SetMaterial material
		
		For Local i=0 To 7
			Local texture:TTexture=brush._texture[i]
			If texture=Null Or texture._blend=BLEND_NONE 
				_d3ddev.SetTexture i,Null
				Continue
			EndIf
			
			_d3ddev.SetTexture i,UpdateTextureRes(texture)._tex

			Local matrix:TMatrix=TMatrix.Identity()
			'matrix._m[0,0]=-texture._sx
			'matrix._m[1,1]=texture._sy
			matrix=TMatrix.YawPitchRoll(0,0,-texture._r).Multiply(matrix)
			matrix=TMatrix.Scale(-texture._sx,texture._sy,1).Multiply(matrix)
			matrix._m[2,0]=-texture._px
			matrix._m[2,1]=-texture._py
			
			_d3ddev.SetTransform D3DTS_TEXTURE0+i,matrix.ToPtr()

			_d3ddev.SetTextureStageState i,D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_COUNT2
			
			_d3ddev.SetSamplerState i,D3DSAMP_MAGFILTER,D3DTEXF_LINEAR
			_d3ddev.SetSamplerState i,D3DSAMP_MINFILTER,D3DTEXF_LINEAR
						
			_d3ddev.SetRenderState D3DRS_ALPHATESTENABLE, texture._flags&TEXTURE_ALPHA			
			
			If texture._flags&TEXTURE_MIPMAP				
				_d3ddev.SetSamplerState i,D3DSAMP_MIPFILTER,D3DTEXF_LINEAR
			Else
				_d3ddev.SetSamplerState i,D3DSAMP_MIPFILTER,D3DTEXF_NONE
			EndIf
			
			If texture._flags&TEXTURE_CLAMPU
				_d3ddev.SetSamplerState i,D3DSAMP_ADDRESSU,D3DTADDRESS_CLAMP
			Else
				_d3ddev.SetSamplerState i,D3DSAMP_ADDRESSU,D3DTADDRESS_WRAP
			EndIf
			
			If texture._flags&TEXTURE_CLAMPV
				_d3ddev.SetSamplerState i,D3DSAMP_ADDRESSU,D3DTADDRESS_CLAMP
			Else
				_d3ddev.SetSamplerState i,D3DSAMP_ADDRESSV,D3DTADDRESS_WRAP
			EndIf
			
			If texture._flags&TEXTURE_SPHMAP
				_d3ddev.SetTextureStageState i,D3DTSS_TEXCOORDINDEX,D3DTSS_TCI_SPHEREMAP
			Else
				_d3ddev.SetTextureStageState i,D3DTSS_TEXCOORDINDEX,texture._coords
			EndIf
			
			'_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_SELECTARG1
			'_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
			
			Select texture._blend
			Case BLEND_ALPHA
				'glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_DECAL)
			Case BLEND_MULTIPLY
				_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_MODULATE
				_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_MODULATE
			Case BLEND_ADD
				_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_ADD
				_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_ADD
			Case BLEND_DOT3
				_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_DOTPRODUCT3
				_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_DOTPRODUCT3
			Case BLEND_MULTIPLY2
				_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_MODULATE2X
				_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_MODULATE2X
			Default
				_d3ddev.SetTextureStageState i,D3DTSS_COLOROP,D3DTOP_MODULATE
				_d3ddev.SetTextureStageState i,D3DTSS_ALPHAOP,D3DTOP_MODULATE
			End Select			
		Next
	End Method
	
	Method RenderSurface(resource:TSurfaceRes,brush:TBrush)
		Local res:TD3D9SurfaceRes=TD3D9SurfaceRes(resource)
		
		_d3ddev.SetFVF 0
		_d3ddev.SetVertexDeclaration GetD3D9MaxB3DVertexDecl(_d3ddev)
		_d3ddev.SetStreamSource 0,res._pos,0,12
		_d3ddev.SetStreamSource 1,res._nml,0,12
		_d3ddev.SetStreamSource 2,res._clr,0,16
		_d3ddev.SetStreamSource 3,res._tex[0],0,8
		_d3ddev.SetIndices res._tri
		_d3ddev.DrawIndexedPrimitive D3DPT_TRIANGLELIST,0,0,res._vertexcnt,0,res._trianglecnt

		Return res._trianglecnt
	End Method
	
	Method RenderSprite(sprite:TSprite)	
		Global _data#[]=[ -1.0, 1.0,0.0, 0.0,0.0,1.0, 0.0,0.0, ..
		                   1.0, 1.0,0.0, 0.0,0.0,1.0, 1.0,0.0, ..
		                  -1.0,-1.0,0.0, 0.0,0.0,1.0, 0.0,1.0, ..
		                   1.0,-1.0,0.0, 0.0,0.0,1.0, 1.0,1.0     ]
		
		_d3ddev.SetVertexDeclaration Null
		_d3ddev.SetFVF D3DFVF_XYZ|D3DFVF_NORMAL|D3DFVF_TEX1
		_d3ddev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_data,8*4
	End Method
	
	Method BeginEntityRender(entity:TEntity)
		_d3ddev.SetTransform D3DTS_WORLD,entity.GetMatrix(True).ToPtr()
	End Method
	
	Method EndEntityRender(entity:TEntity)
	End Method
	
	Method RenderPlane(plane:TPlane)
		Local x#,y#,z#
		plane.GetScale x,y,z,True

		Global _data#[]=[ -1.0,0.0, 1.0, 0.0,1.0,0.0, 0.0,0.0, ..
		                   1.0,0.0, 1.0, 0.0,1.0,0.0,   x,0.0, ..
		                  -1.0,0.0,-1.0, 0.0,1.0,0.0, 0.0,  z, ..
		                   1.0,0.0,-1.0, 0.0,1.0,0.0,   x,  z     ]		
		
		_d3ddev.SetVertexDeclaration Null
		_d3ddev.SetFVF D3DFVF_XYZ|D3DFVF_NORMAL|D3DFVF_TEX1
		_d3ddev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_data,8*4
	End Method
	
	Method RenderTerrain(terrain:TTerrain)
	End Method
	
	Method UpdateTextureRes:TD3D9TextureRes(texture:TTexture)
		Local res:TD3D9TextureRes=TD3D9TextureRes(texture._res)
		If res And texture._updateres=False Return res

		If res=Null res=New TD3D9TextureRes
		texture._res=res
		
		Local pixmap:TPixmap=texture._pixmap
		Local tex_width=Pow2Size(pixmap.width),tex_height=Pow2Size(pixmap.height)
		pixmap=ConvertPixmap(ResizePixmap(pixmap,tex_width,tex_height),PF_BGRA8888)
		If res._tex=Null Assert _d3ddev.CreateTexture(tex_width,tex_height,(texture._flags & TEXTURE_MIPMAP)=0,D3DUSAGE_AUTOGENMIPMAP,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,res._tex,Null)=D3D_OK
		
		Local rect:D3DLOCKED_RECT=New D3DLOCKED_RECT 
		res._tex.LockRect 0,rect,Null,0
		MemCopy rect.pBits,pixmap.pixels,pixmap.width*pixmap.height*4
		res._tex.UnlockRect 0
		
		texture._updateres=False
				
		Return res
	End Method
	
	Method UpdateSurfaceRes:TD3D9SurfaceRes(surface:TSurface)
		Local res:TD3D9SurfaceRes=TD3D9SurfaceRes(surface._res)
		If res=Null res=New TD3D9SurfaceRes;surface._reset=-1
		
		If surface._reset=0 Return res		
		If surface._reset=-1 surface._reset=1|2|4|8|16|32|64|128|256

		If surface._reset&1 And surface._vertexpos UploadVertexData res._pos,surface._vertexpos
		If surface._reset&2 And surface._vertexnml UploadVertexData res._nml,surface._vertexnml
		If surface._reset&4 And surface._vertexclr UploadVertexData res._clr,surface._vertexclr
		If surface._reset&8 And surface._triangle
			If res._tri=Null _d3ddev.CreateIndexBuffer(surface._triangle.length*4,0,D3DFMT_INDEX32,D3DPOOL_MANAGED,res._tri,Null)
			Local dataptr:Byte Ptr
			Assert res._tri.Lock(0,0,dataptr,0)=D3D_OK,"Failed to lock index buffer."
			MemCopy dataptr,surface._triangle,surface._triangle.length*4		
			res._tri.Unlock()
		EndIf
		
		For Local i=0 To surface._vertextex.length-1
			If surface._reset&Int(2^(4+i)) UploadVertexData res._tex[i],surface._vertextex[i]
		Next
		
		res._trianglecnt=surface._trianglecnt
		res._vertexcnt=surface._vertexcnt
		
		surface._reset=0
		surface._res=res
		
		Return res
	End Method

	Method MergeSurfaceRes:TSurfaceRes(base:TSurface,animation:TSurface,data)
		If animation=Null Return UpdateSurfaceRes(base)
		Local base_res:TD3D9SurfaceRes=UpdateSurfaceRes(base)
		Local anim_res:TD3D9SurfaceRes=UpdateSurfaceRes(animation)
		Local res:TD3D9SurfaceRes=base_res.Copy()
		res._pos=anim_res._pos
		Return res
	End Method
	
	Method UploadVertexData(buffer:IDirect3DVertexBuffer9 Var,data#[])
		If buffer=Null _d3ddev.CreateVertexBuffer(data.length*4,0,0,D3DPOOL_MANAGED,buffer,Null)
		Local dataptr:Byte Ptr
		Assert buffer.Lock(0,0,dataptr,0)=D3D_OK,"Failed to lock vertex buffer."
		MemCopy dataptr,data,data.length*4		
		buffer.Unlock()
	End Method
	
End Type

Type TD3D9TextureRes Extends TTextureRes
	Field _tex:IDirect3DTexture9
End Type

Type TD3D9SurfaceRes Extends TSurfaceRes
	Field _pos:IDirect3DVertexBuffer9
	Field _nml:IDirect3DVertexBuffer9
	Field _clr:IDirect3DVertexBuffer9
	Field _tri:IDirect3DIndexBuffer9
	Field _tex:IDirect3DVertexBuffer9[8]
	
	Method Copy:TD3D9SurfaceRes()
		Local res:TD3D9SurfaceRes=New TD3D9SurfaceRes
		res._vertexcnt=_vertexcnt;res._trianglecnt=_trianglecnt
		res._pos=_pos;res._nml=_nml;res._clr=_clr;res._tri=_tri;
		For Local i=0 To 7
			res._tex[i]=_tex[i]
		Next
		Return res
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function D3D9MaxB3DDriver:TD3D9MaxB3DDriver()
	If D3D9Max2DDriver()
		Global driver:TD3D9MaxB3DDriver=New TD3D9MaxB3DDriver
		driver._parent=D3D9Max2DDriver()
		Return driver
	End If
End Function

Rem
	bbdoc: Utility function that sets the MaxB3D D3D9 driver and calls Graphics.
End Rem
Function D3D9Graphics3D:TGraphics(width,height,depth=0,hertz=0,flags=0)
	SetGraphicsDriver D3D9MaxB3DDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
	Return Graphics(width,height,depth,hertz,flags)
End Function

Local driver:TD3D9MaxB3DDriver=D3D9MaxB3DDriver()
If driver SetGraphicsDriver driver,GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER

?