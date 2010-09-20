
Strict

Module MaxB3D.D3D9Driver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import MaxB3D.Core
Import BRL.D3D9Max2D

?Win32

Import "d3d9.bmx"

Type TD3D9MaxB3DDriver Extends TMaxB3DDriver
	Field _d3ddev:IDirect3DDevice9
	
	Method SetGraphics( g:TGraphics )
		Super.SetGraphics g
		_d3ddev=Null
		If g<>Null _d3ddev=TD3D9Graphics(TMax2DGraphics(g)._graphics).GetDirect3DDevice()
	End Method
	
	Method BeginMax2D()
		Global identity:TMatrix=TMatrix.Identity()
		_d3ddev.SetRenderState D3DRS_ZENABLE,False
		_d3ddev.SetTransform D3DTS_WORLD,identity.GetPtr()
		_d3ddev.SetTransform D3DTS_VIEW,identity.GetPtr()
		_d3ddev.SetVertexDeclaration(Null)
		_d3ddev.SetIndices(Null)
		_d3ddev.SetFVF(D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1)
		_d3ddev.SetRenderState(D3DRS_LIGHTING,False)
		
		Local width=GraphicsWidth(),height=GraphicsHeight()
		Local matrix#[]=[..
		2.0/width,0.0,0.0,0.0,..
		 0.0,-2.0/height,0.0,0.0,..
		 0.0,0.0,1.0,0.0,..
		 -1-(1.0/width),1+(1.0/height),1.0,1.0]
		
		_d3ddev.SetTransform D3DTS_PROJECTION,matrix
	End Method
	
	Method EndMax2D()
		_d3ddev.SetRenderState D3DRS_ZENABLE,True
		_d3ddev.SetRenderState D3DRS_ZWRITEENABLE,True
		_d3ddev.SetRenderState(D3DRS_LIGHTING,True)
	End Method
	
	Method SetCamera(camera:TCamera)
		Local clearflags		
		If camera._clsmode&CLSMODE_COLOR clearflags:|D3DCLEAR_TARGET
		If camera._clsmode&CLSMODE_DEPTH clearflags:|D3DCLEAR_ZBUFFER
				
		Local viewport[]=[camera._viewx,camera._viewy,camera._viewwidth,camera._viewheight]
		_d3ddev.SetScissorRect viewport
		_d3ddev.Clear(1,viewport,clearflags,D3DCOLOR_XRGB(camera._brush._r*255,camera._brush._g*255,camera._brush._b*255),1.0,0)
		
		Local ratio#=(Float(camera._viewwidth)/camera._viewheight)
		_d3ddev.SetTransform D3DTS_PROJECTION,TMatrix.PerspectiveFOV(ATan((1.0/(camera._zoom*ratio)))*2.0,ratio#,camera._near,camera._far).GetPtr()
		
		Local matrix:TMatrix=camera._matrix.Inverse()
		_d3ddev.SetTransform D3DTS_VIEW,matrix.GetPtr()
	End Method
	
	Method SetLight(light:TLight,index)
		_d3ddev.LightEnable index,light.GetVisible()
		Global d3dlight:D3DLIGHT9=New D3DLIGHT9
		d3dlight.Position_x=0.0;d3dlight.Position_y=0.0;d3dlight.Position_z=1.0
		d3dlight.Direction_x=0.0;d3dlight.Direction_y=0.0;d3dlight.Direction_z=-1.0
		d3dlight.Ambient_r=light._brush._r;d3dlight.Ambient_g=light._brush._g;d3dlight.Ambient_b=light._brush._b
		
		_d3ddev.SetLight(index,d3dlight)
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha) 
	End Method
	
	Method RenderSurface(surface:TSurface,brush:TBrush)
		Local res:TD3D9SurfaceRes=UpdateSurfaceRes(surface)
		
		_d3ddev.SetVertexDeclaration(GetD3D9MaxB3DVertexDecl(_d3ddev))
		_d3ddev.SetStreamSource(0,res._pos,Null,12)
		_d3ddev.SetStreamSource(1,res._nml,Null,12)
		_d3ddev.SetStreamSource(2,res._clr,Null,16)
		_d3ddev.SetIndices(res._tri)
		_d3ddev.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,surface._vertexcnt,0,surface._trianglecnt)

		Return surface._trianglecnt
	End Method
	
	Method BeginRender(entity:TEntity)
		_d3ddev.SetTransform D3DTS_WORLD,entity._matrix.GetPtr()
	End Method
	
	Method EndRender(entity:TEntity)
	End Method
	
	Method RenderPlane(plane:TPlane)
	End Method
	
	Method UpdateTextureRes:TD3D9TextureRes(texture:TTexture)
		
	End Method
	
	Method UpdateSurfaceRes:TD3D9SurfaceRes(surface:TSurface)
		Local res:TD3D9SurfaceRes=TD3D9SurfaceRes(surface._res)
		If res=Null res=New TD3D9SurfaceRes;surface._reset=-1
		
		If surface._reset=0 Return res		
		If surface._reset=-1 surface._reset=1|2|4|8|16|32|64|128|256

		If surface._reset&1 UploadVertexData res._pos,surface._vertexpos
		If surface._reset&2 UploadVertexData res._nml,surface._vertexnml
		If surface._reset&4 UploadVertexData res._clr,surface._vertexclr
		If surface._reset&8
			If res._tri=Null _d3ddev.CreateIndexBuffer(surface._triangle.length*4,0,D3DFMT_INDEX32,D3DPOOL_MANAGED,res._tri,Null)
			Local dataptr:Byte Ptr
			Assert res._tri.Lock(0,0,dataptr,0)=D3D_OK,"Failed to lock index buffer."
			MemCopy dataptr,surface._triangle,surface._triangle.length*4		
			res._tri.Unlock()
		EndIf
		
		surface._reset=0
		surface._res=res
		
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

End Type

Type TD3D9SurfaceRes Extends TSurfaceRes
	Field _pos:IDirect3DVertexBuffer9
	Field _nml:IDirect3DVertexBuffer9
	Field _clr:IDirect3DVertexBuffer9
	Field _tri:IDirect3DIndexBuffer9
	Field _tex:IDirect3DVertexBuffer9[8]
End Type

Function D3D9MaxB3DDriver:TD3D9MaxB3DDriver()
	If D3D9Max2DDriver()
		Global driver:TD3D9MaxB3DDriver=New TD3D9MaxB3DDriver
		driver._parent=D3D9Max2DDriver()
		Return driver
	End If
End Function

Local driver:TD3D9MaxB3DDriver=D3D9MaxB3DDriver()
If driver SetGraphicsDriver driver,GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER

?