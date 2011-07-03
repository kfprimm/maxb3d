
Strict

Rem
	bbdoc: OpenGL 1.1 driver for MaxB3D
End Rem
Module MaxB3D.GLDriver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import sys87.GLBufferedMax2D

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "gldriver",message
End Function

Public

Global GL_LIGHT[]=[GL_LIGHT0,GL_LIGHT1,GL_LIGHT2,GL_LIGHT3,GL_LIGHT4,GL_LIGHT5,GL_LIGHT6,GL_LIGHT7]

Type TGLMaxB3DDriver Extends TMaxB3DDriver
	Field _currentdata:TShaderData=New TShaderData
	
	Method SetGraphics(g:TGraphics)
		Super.SetGraphics g
		If g<>Null Startup
	End Method
	
	Function BindTexture(index,tex)
		If index=-1
			For Local i=0 To 7
				BindTexture i,tex
			Next
			Return
		EndIf
		Global currenttexture[] = [-1,-1,-1,-1,-1,-1,-1,-1]
		If tex<>currenttexture[index]
			glBindTexture GL_TEXTURE_2D,tex
			currenttexture[index]=tex
		EndIf
	End Function
	
	Method Startup()
		Global _firsttime=True
		If _firsttime
			Local caps:TGLCaps=TGLCaps(_caps)
			ModuleLog "Initializing GL driver"
			ModuleLog "Vendor:   "+String.FromCString(Byte Ptr(glGetString(GL_VENDOR)))
			ModuleLog "Renderer: "+String.FromCString(Byte Ptr(glGetString(GL_RENDERER))) 
			ModuleLog "Version:  "+String.FromCString(Byte Ptr(glGetString(GL_VERSION)))
			ModuleLog "Extensions supported: "
			For Local ext$=EachIn caps.Extensions
				ModuleLog ext
			Next
			_firsttime=False
		Else
			EnableStates
		EndIf		
	End Method
	
	Function EnableStates()	
		glEnable GL_LIGHTING
		glEnable GL_DEPTH_TEST
		glEnable GL_CULL_FACE
		glEnable GL_SCISSOR_TEST
		
		glEnable GL_NORMALIZE
		
		glEnableClientState GL_VERTEX_ARRAY
		glEnableClientState GL_COLOR_ARRAY
		glEnableClientState GL_NORMAL_ARRAY
		
		glFrontFace GL_CCW
		
		glLightModeli GL_LIGHT_MODEL_COLOR_CONTROL,GL_SEPARATE_SPECULAR_COLOR
		glLightModeli GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE
	
		glClearDepth 1.0
		glDepthFunc GL_LEQUAL
		glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
	
		glAlphaFunc GL_GEQUAL,0.5
		
		BindTexture -1,0
	End Function	
	
	Method MakeBuffer:TBuffer(src:Object,width,height,flags)
		Local buffer:TBuffer
		Select True
		Case TTextureFrame(src)<>Null
			buffer=TGLBuffer(TTextureFrame(src)._buffer)
			If buffer=Null
				Local res:TGLTextureRes=UpdateTextureRes(TTextureFrame(src),0)
				buffer=TGLBufferedMax2DDriver(_parent).MakeGLBuffer(res._id,width,height,flags)
			EndIf
		Default
			buffer=_parent.MakeBuffer(src,width,height,flags)
		End Select
		Return buffer
	End Method
	
	Method GetCaps:TCaps()
		Local caps:TGLCaps=New TGLCaps
		caps.Extensions=String.FromCString(glGetString(GL_EXTENSIONS)).Split(" ")
		If caps.HasExtension("GL_ARB_point_sprite")<>-1
			caps.PointSprites=True
			glGetFloatv GL_POINT_SIZE_MAX_ARB, Varptr caps.MaxPointSize
		EndIf
		Return caps
	End Method
	
	Method SetMax2D(enable)
		If enable
			glPopClientAttrib
			glPopAttrib
			If _shaderdriver _shaderdriver.Use(Null,Null)	
			TGLBufferedMax2DDriver(_parent).ResetGLContext _current
			glMatrixMode GL_TEXTURE
			glLoadIdentity
			glMatrixMode GL_COLOR	
			glPopMatrix					
		Else			
			glPushAttrib GL_ALL_ATTRIB_BITS
			glPushClientAttrib GL_CLIENT_ALL_ATTRIB_BITS
			glMatrixMode GL_TEXTURE
			glPushMatrix
			glMatrixMode GL_COLOR
			glPushMatrix 
			
			EnableStates()
		EndIf
	End Method	
	Method SetCamera(camera:TCamera)
		Local vy#=WorldConfig.Height-camera._viewheight-camera._viewy
		glViewport(camera._viewx,vy,camera._viewwidth,camera._viewheight)
		glScissor(camera._viewx,vy,camera._viewwidth,camera._viewheight)
		glClearColor(camera._brush._r,camera._brush._g,camera._brush._b,1.0)
		
		If camera._clsmode&CLSMODE_COLOR And camera._clsmode&CLSMODE_DEPTH
			glDepthMask GL_TRUE
			glClear GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
		Else
			If camera._clsmode&CLSMODE_COLOR
				glClear GL_COLOR_BUFFER_BIT
			Else
				If camera._clsmode&CLSMODE_DEPTH
					glDepthMask GL_TRUE
					glClear GL_DEPTH_BUFFER_BIT
				EndIf
			EndIf
		EndIf
		
		If camera._fogmode<>FOGMODE_NONE
			glEnable GL_FOG
			glFogi GL_FOG_MODE,GL_LINEAR
			glFogf GL_FOG_START,camera._fognear
			glFogf GL_FOG_END,camera._fogfar
			Local rgb#[]=[camera._fogr,camera._fogg,camera._fogb]
			glFogfv GL_FOG_COLOR,rgb
		Else
			glDisable GL_FOG
		EndIf

		Local ratio#=(Float(camera._viewwidth)/camera._viewheight)
		
		glMatrixMode GL_PROJECTION
		glLoadIdentity
		glLoadMatrixf TMatrix.PerspectiveFovRH(ATan((1.0/(camera._zoom*ratio)))*2.0,ratio#,camera._near,camera._far).ToPtr()
		glScalef -1,1,-1
		
		glMatrixMode GL_MODELVIEW		
		glLoadMatrixf camera._matrix.Inverse().ToPtr()
		
		glGetFloatv GL_MODELVIEW_MATRIX,camera._lastmodelview._m
		glGetFloatv GL_PROJECTION_MATRIX,camera._lastprojection._m
		glGetIntegerv GL_VIEWPORT,camera._lastviewport

		_currentdata._projection=camera._lastprojection
		
		camera._lastfrustum=TFrustum.Extract(camera._lastmodelview,camera._lastprojection)
	End Method	
	
	Method SetLight(light:TLight,index)
		If light=Null
			glDisable GL_LIGHT[index]
			Return
		Else
			If light._hidden=True 
				glDisable GL_LIGHT[index]
				Return False
			EndIf
		EndIf
		
		glEnable GL_LIGHT[index]
		
		glPushMatrix
		glMultMatrixf light.GetMatrix(True).ToPtr()
		
		Local white_light#[]=[1.0,1.0,1.0,1.0]
		glLightfv GL_LIGHT[index],GL_SPECULAR,white_light
		
		Local z#=1.0
		Local w#=0.0
		If light._mode>LIGHT_DIRECTIONAL
			z=0.0
			w=1.0
		EndIf
		
		Local rgba#[]=[light._brush._r,light._brush._g,light._brush._b,1.0]
		Local pos#[]=[0.0,0.0,-z,w]
		
		glLightfv GL_LIGHT[index],GL_POSITION,pos
		glLightfv GL_LIGHT[index],GL_DIFFUSE,rgba
	
		If light._mode<>LIGHT_DIRECTIONAL
			Local light_range#[]=[0.0]
			Local range#[]=[light._range]
			glLightfv GL_LIGHT[index],GL_CONSTANT_ATTENUATION,light_range
			glLightfv GL_LIGHT[index],GL_LINEAR_ATTENUATION,range
		EndIf		

		If light._mode<>LIGHT_DIRECTIONAL		
		EndIf

		If light._mode=LIGHT_SPOT		
			Local dir#[]=[0.0,0.0,-1.0]
			Local outer#[]=[light._outer/2.0]
			Local exponent#[]=[10.0]	
			glLightfv GL_LIGHT[index],GL_SPOT_DIRECTION,dir
			glLightfv GL_LIGHT[index],GL_SPOT_CUTOFF,outer
			glLightfv GL_LIGHT[index],GL_SPOT_EXPONENT,exponent
		EndIf
		
		glPopMatrix
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha)
		glDisable GL_ALPHA_TEST
			
		Local ambient#[]=[WorldConfig.AmbientRed/255.0,WorldConfig.AmbientGreen/255.0,WorldConfig.AmbientBlue/255.0]			
					
		If brush._fx&FX_FORCEALPHA Or hasalpha
			glEnable GL_BLEND
			glDepthMask GL_FALSE
		Else
			glDisable GL_BLEND
			glDepthMask GL_TRUE
		EndIf
		
		Select brush._blend
			Case BLEND_NONE,BLEND_ALPHA
				glBlendFunc GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA
			Case BLEND_MULTIPLY
				glBlendFunc GL_DST_COLOR,GL_ZERO
			Case BLEND_ADD
				glBlendFunc GL_SRC_ALPHA,GL_ONE
		End Select
		
		If brush._fx&FX_FULLBRIGHT
			ambient[0]=1.0
			ambient[1]=1.0
			ambient[2]=1.0		
		EndIf
		
		If brush._fx&FX_VERTEXCOLOR
			glEnable GL_COLOR_MATERIAL
		Else
			glDisable GL_COLOR_MATERIAL
		EndIf
		
		If brush._fx&FX_FLATSHADED
			glShadeModel GL_FLAT
		Else
			glShadeModel GL_SMOOTH
		EndIf

		If brush._fx&FX_NOFOG
			glDisable GL_FOG
		EndIf
		
		If brush._fx&FX_NOCULLING
			glDisable GL_CULL_FACE
		Else
			glEnable GL_CULL_FACE
		EndIf
		
		If brush._fx&FX_WIREFRAME Or WorldConfig.Wireframe
			glPolygonMode GL_FRONT_AND_BACK,GL_LINE
		Else
			glPolygonMode GL_FRONT_AND_BACK,GL_FILL
		EndIf			
		
		Local no_mat#[]=[0.0,0.0]
		Local mat_ambient#[]=[brush._r,brush._g,brush._b,brush._a]
		Local mat_diffuse#[]=[brush._r,brush._g,brush._b,brush._a]
		Local mat_specular#[]=[brush._shine,brush._shine,brush._shine,brush._shine]
		Local mat_shininess#[]=[100.0]
			
		glMaterialfv GL_FRONT,GL_AMBIENT,mat_ambient
		glMaterialfv GL_FRONT,GL_DIFFUSE,mat_diffuse
		glMaterialfv GL_FRONT,GL_SPECULAR,mat_specular
		glMaterialfv GL_FRONT,GL_SHININESS,mat_shininess
		glLightModelfv GL_LIGHT_MODEL_AMBIENT,ambient
		
		For Local i=0 To 7
			glActiveTextureARB GL_TEXTURE0+i

			Local texture:TTexture=brush._texture[i]
			If texture=Null Or texture._blend=BLEND_NONE
				glDisable GL_TEXTURE_2D
				BindTexture i,0
				Continue
			EndIf
			
			Local texres:TGLTextureRes=TGLTextureRes(UpdateTextureRes(texture._frame[brush._textureframe[i]],texture._flags))
			
			glEnable GL_TEXTURE_2D
			
			BindTexture i,texres._id	
			
			glMatrixMode GL_TEXTURE
			glLoadIdentity
			glTranslatef texture._px,-texture._py,0
			glScalef -texture._sx,texture._sy,1
			
			If texture._flags&TEXTURE_ALPHA
				glEnable GL_ALPHA_TEST
			Else
				glDisable GL_ALPHA_TEST
			EndIf
		
			If texture._flags&TEXTURE_MIPMAP
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR
			Else
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
			EndIf
			
			If texture._flags&TEXTURE_CLAMPU
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE
			Else						
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT
			EndIf
			
			If texture._flags&TEXTURE_CLAMPV
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE
			Else
				glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT
			EndIf
	
			If texture._flags&TEXTURE_SPHMAP				
				glEnable GL_TEXTURE_GEN_S
				glEnable GL_TEXTURE_GEN_T
				glTexGeni GL_S,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
				glTexGeni GL_T,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
			Else
				glDisable GL_TEXTURE_GEN_S 
				glDisable GL_TEXTURE_GEN_T
			EndIf
			
			Select texture._blend
			Case BLEND_NONE glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_REPLACE)
			Case BLEND_ALPHA 	glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE)
			Case BLEND_MULTIPLY glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE)
			'Case BLEND_MULTIPLY glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_RGB_EXT,GL_MODULATE)
			Case BLEND_ADD glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_ADD)
			Case BLEND_DOT3
				glTexEnvf GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_EXT
				glTexEnvf GL_TEXTURE_ENV, GL_COMBINE_RGB_EXT, GL_DOT3_RGB_EXT
			Case BLEND_MULTIPLY2
				glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_COMBINE)
				glTexEnvi(GL_TEXTURE_ENV,GL_COMBINE_RGB,GL_MODULATE)
				glTexEnvi(GL_TEXTURE_ENV,GL_RGB_SCALE,2.0)
			Default glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE)
			End Select			
		Next	
		
		If _shaderdriver _shaderdriver.Use(brush._shader,_currentdata)	
	End Method
	
	Method RenderSurface(resource:TSurfaceRes,brush:TBrush)
		Local res:TGLSurfaceRes=TGLSurfaceRes(resource)	
		
		For Local i=0 To 7
			glClientActiveTextureARB GL_TEXTURE0+i
			
			Local texture:TTexture=brush._texture[i]
			If texture=Null 
				glDisableClientState GL_TEXTURE_COORD_ARRAY
				Continue
			EndIf
			
			glEnableClientState GL_TEXTURE_COORD_ARRAY
			glBindBufferARB GL_ARRAY_BUFFER_ARB,res._vbo[4+texture._coords]
			glTexCoordPointer 2,GL_FLOAT,0,Null
		Next
		
		glBindBufferARB GL_ARRAY_BUFFER_ARB,res._vbo[0]
		glVertexPointer 3,GL_FLOAT,0,Null
		
		glBindBufferARB GL_ARRAY_BUFFER_ARB,res._vbo[1]
		glNormalPointer GL_FLOAT,0,Null
		
		glBindBufferARB GL_ARRAY_BUFFER_ARB,res._vbo[2]
		glColorPointer 4,GL_FLOAT,0,Null
	
		glBindBufferARB GL_ELEMENT_ARRAY_BUFFER_ARB,res._vbo[3]
		glDrawElements GL_TRIANGLES,res._trianglecnt*3,GL_UNSIGNED_INT,Null
		
		Return res._trianglecnt
	End Method
	
	Method BeginEntityRender(entity:TEntity)		
		If entity._order<>0
			glDisable GL_DEPTH_TEST
			glDepthMask GL_FALSE
		Else
			glEnable GL_DEPTH_TEST
			glDepthMask GL_TRUE
		EndIf
		
		glMatrixMode GL_MODELVIEW
		glPushMatrix
		glMultMatrixf entity.GetMatrix(True,False).ToPtr()
		
		Global matrix:TMatrix=New TMatrix
		glGetFloatv GL_MODELVIEW_MATRIX,matrix._m
		_currentdata._modelviewproj=matrix.Multiply(_currentdata._projection)
	End Method
	Method EndEntityRender(entity:TEntity)
		glMatrixMode GL_MODELVIEW
		glPopMatrix
	End Method
	
	Method RenderFlat(flat:TFlat)
		Local x#,y#,z#
		flat.GetScale x,y,z,True
		
		glBegin GL_QUADS
			glNormal3f 0,1,0
			glTexCoord2f 0,0
			glVertex3f -1,0, 1
			glTexCoord2f x,0	
			glVertex3f 1, 0, 1
			glTexCoord2f x,z
			glVertex3f 1, 0, -1
			glTexCoord2f 0,z
			glVertex3f -1,0, -1
		glEnd
		Return 2
	End Method
	
	Method RenderSprite(sprite:TSprite)
		If False
			glPointParameterfvARB GL_POINT_DISTANCE_ATTENUATION_ARB, [0.0, 0.0, 1.0]
			
			glPointSize 1.0
			
			glPointParameterfARB GL_POINT_FADE_THRESHOLD_SIZE_ARB,60.0
			glPointParameterfARB GL_POINT_SIZE_MIN_ARB,0.0
			glPointParameterfARB GL_POINT_SIZE_MAX_ARB,9999.0
			
			glTexEnvf GL_POINT_SPRITE_ARB,GL_COORD_REPLACE_ARB,GL_TRUE
			
			glEnable GL_POINT_SPRITE_ARB
			
			glBegin GL_POINTS			
			glVertex3f 0,0,0
			glEnd
			
			glDisable GL_POINT_SPRITE_ARB
		Else
			glBegin GL_QUADS
				glNormal3f 0,0,-1
				glTexCoord2f 0,1
				glVertex3f 1, -1, 0			
				glTexCoord2f 0,0
				glVertex3f 1, 1, 0			
				glTexCoord2f 1,0
				glVertex3f -1,1, 0			
				glTexCoord2f 1,1
				glVertex3f -1,-1, 0
			glEnd
		EndIf
	End Method
	
	Method RenderTerrain(terrain:TTerrain)
	
		glDisableClientState GL_TEXTURE_COORD_ARRAY
		For Local i=0 To 7
			Local texture:TTexture=terrain._brush._texture[i]
			If texture=Null Continue
			glEnableClientState(GL_TEXTURE_COORD_ARRAY)
			glClientActiveTextureARB(GL_TEXTURE0+i)
			glTexCoordPointer(2,GL_FLOAT,20,terrain._data)
		Next
		
		glEnableClientState  GL_VERTEX_ARRAY
		glDisableClientState GL_COLOR_ARRAY
		glDisableClientState GL_NORMAL_ARRAY
		
		glVertexPointer(3,GL_FLOAT, 20, terrain._data+2)
		glDrawArrays(GL_TRIANGLES, 0, 3*terrain._count)
		
		glEnableClientState GL_VERTEX_ARRAY
		glEnableClientState GL_COLOR_ARRAY 
		glEnableClientState GL_NORMAL_ARRAY 
	End Method
	
	Method RenderBSPTree(tree:TBSPTree)
		Local node:TBSPNode=tree.Node
		If node=Null Return
		Local triangles
		triangles:+RenderBSPTree(node.In)
		
		glBegin GL_TRIANGLES
		
		For Local poly:TBSPPolygon=EachIn node.On
			glNormal3f poly.Plane.x,poly.Plane.y,poly.Plane.z
			Local ptA:TVector=poly.Point[0],v0
			For Local i=1 To poly.Count()-2
				Local ptB:TVector=poly.Point[i],ptC:TVector=poly.Point[i+1]
				glVertex3f ptA.x,ptA.y,ptA.z
				glVertex3f ptB.x,ptB.y,ptB.z
				glVertex3f ptC.x,ptC.y,ptC.z
			Next
			triangles:+poly.Count()-2
		Next
		
		glEnd
		
		triangles:+RenderBSPTree(node.Out)
		Return triangles
	End Method

	Method UpdateTextureRes:TGLTextureRes(frame:TTextureFrame,flags)
		If frame=Null Return Null
		
		Local glres:TGLTextureRes=TGLTextureRes(frame._res)
		If glres=Null
			glres=New TGLTextureRes
			frame._res=glres
			frame._updateres=True
		EndIf		
		If Not frame._updateres Return glres
		
		If glres._id=0 glGenTextures(1,Varptr glres._id)
		BindTexture 0,glres._id
		Local pixmap:TPixmap=frame._pixmap
		gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGBA8,pixmap.width,pixmap.height,GL_BGRA,GL_UNSIGNED_BYTE,pixmap.pixels)
		
		frame._updateres=0
		Return glres
	End Method
	
	Method UpdateSurfaceRes:TGLSurfaceRes(surface:TSurface)
		Local res:TGLSurfaceRes=TGLSurfaceRes(surface._res)
		If res=Null res=New TGLSurfaceRes;surface._res=res
		If surface._reset=0 Return res
		
		If res._vbo[0]=0 glGenBuffersARB(4,res._vbo)
	
		If surface._reset=-1 Then surface._reset=1|2|4|8|16|32|64|128|256
	
		If surface._reset&1 UploadVertexBuffer res._vbo[0],surface._vertexpos
		If surface._reset&2 UploadVertexNormals res._vbo[1],surface._vertexnml
		If surface._reset&4 UploadVertexBuffer res._vbo[2],surface._vertexclr
		If surface._reset&8
			glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,res._vbo[3])
			glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,surface._triangle.length*4,surface._triangle,GL_STATIC_DRAW_ARB)
		EndIf
		
		For Local i=0 To surface._vertextex.length-1
			If res._vbo[4+i]=0 glGenBuffersARB(1,Varptr res._vbo[4+i])
			If surface._reset&Int(2^(4+i)) UploadVertexBuffer res._vbo[4+i],surface._vertextex[i]
		Next	
		
		res._trianglecnt=surface._trianglecnt
		res._vertexcnt=surface._vertexcnt		
		surface._reset=0		
		Return res
	End Method
	
	Method MergeSurfaceRes:TGLSurfaceRes(base:TSurface,animation:TSurface,data)
		If animation=Null Return UpdateSurfaceRes(base)
		Local res_base:TGLSurfaceRes=UpdateSurfaceRes(base)
		Local res_anim:TGLSurfaceRes=UpdateSurfaceRes(animation)
		Local res:TGLSurfaceRes=res_base.Copy()
		res._vbo[0]=res_anim._vbo[0]
		Return res
	End Method
	
	Method UploadVertexBuffer(vbo,data#[])
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbo)
		glBufferDataARB(GL_ARRAY_BUFFER_ARB,data.length*4,data,GL_STATIC_DRAW_ARB)
	End Method
	
	Method UploadVertexNormals(vbo,data#[])
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbo)
		glBufferDataARB(GL_ARRAY_BUFFER_ARB,data.length*4,data,GL_STATIC_DRAW_ARB)
	End Method
End Type

Type TGLCaps Extends TCaps
	Field Extensions$[]
	
	Method HasExtension(ext$)
		For Local extension$=EachIn Extensions
			If extension.Find(ext)<>-1 Return True
		Next
		Return False 
	End Method
	
	Method Copy:TGLCaps()
		Local caps:TGLCaps=New TGLCaps
		caps.CopyBase(Self)
		caps.Extensions=Extensions[..]
		Return caps		
	End Method
End Type

Type TGLSurfaceRes Extends TSurfaceRes
	Field _vbo[12]
	Field _texcoord
	
	Method Copy:TGLSurfaceRes()
		Local res:TGLSurfaceRes=New TGLSurfaceRes
		res._vertexcnt=_vertexcnt;res._trianglecnt=_trianglecnt
		res._vbo=_vbo[..]
		res._texcoord=_texcoord
		Return res
	End Method
End Type

Type TGLTextureRes Extends TTextureRes
	Field _id
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GLMaxB3DDriver:TGLMaxB3DDriver()
	If GLBufferedMax2DDriver()
		Global driver:TGLMaxB3DDriver=New TGLMaxB3DDriver
		driver._parent=GLBufferedMax2DDriver()
		Return driver
	End If
End Function

Rem
	bbdoc: Utility function that sets the MaxB3D GL driver and calls Graphics.
End Rem
Function GLGraphics3D:TGraphics(width,height,depth=0,hertz=60,flags=0)
	SetGraphicsDriver GLMaxB3DDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
	Return Graphics(width,height,depth,hertz,flags)
End Function

Local driver:TGLMaxB3DDriver=GLMaxB3DDriver()
If driver SetGraphicsDriver driver,GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER