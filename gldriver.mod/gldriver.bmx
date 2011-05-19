
Strict

Rem
	bbdoc: OpenGL 1.1 driver for MaxB3D
End Rem
Module MaxB3D.GLDriver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import BRL.GLMax2D
Import PUB.GLew

Private
Function ModuleLog(message$)
	_maxb3d_logger.Write "gldriver",message
End Function

Public

Global GL_LIGHT[]=[GL_LIGHT0,GL_LIGHT1,GL_LIGHT2,GL_LIGHT3,GL_LIGHT4,GL_LIGHT5,GL_LIGHT6,GL_LIGHT7]

Type TGLMaxB3DDriver Extends TMaxB3DDriver
	Method SetGraphics(g:TGraphics)
		Super.SetGraphics g
		glewInit()
		If g<>Null Startup
	End Method
	
	Function BindTexture(tex)
		Global currenttexture = -1
		If tex<>currenttexture
			glBindTexture GL_TEXTURE_2D,tex
			currenttexture=tex
		EndIf
	End Function
	
	Method Startup()
		Global _firsttime=True
		If _firsttime
			ModuleLog "Initializing GL driver"
			ModuleLog "Extensions supported: "+String.FromCString(glGetString(GL_EXTENSIONS))
			_firsttime=False
		EndIf
		EndMax2D
	End Method
	
	Function EnableStates()	
		glEnable GL_LIGHTING
		glEnable GL_DEPTH_TEST
		glEnable GL_FOG
		glEnable GL_CULL_FACE
		glEnable GL_SCISSOR_TEST
		
		glEnable GL_NORMALIZE
		
		glEnableClientState GL_VERTEX_ARRAY
		glEnableClientState GL_COLOR_ARRAY
		glEnableClientState GL_NORMAL_ARRAY
		
		glFrontFace GL_CW
		
		glLightModeli GL_LIGHT_MODEL_COLOR_CONTROL,GL_SEPARATE_SPECULAR_COLOR
		glLightModeli GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE
	
		glClearDepth 1.0
		glDepthFunc GL_LEQUAL
		glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
	
		glAlphaFunc GL_GEQUAL,0.5
		
		BindTexture 0
	End Function	
	
	Method BeginMax2D()
		glPopClientAttrib
		glPopAttrib
		glMatrixMode GL_MODELVIEW
		glPopMatrix
		glMatrixMode GL_PROJECTION
		glPopMatrix
		glMatrixMode GL_TEXTURE
		glPopMatrix
		glMatrixMode GL_COLOR
		glPopMatrix 
	End Method
	Method EndMax2D()
		glPushAttrib GL_ALL_ATTRIB_BITS
		glPushClientAttrib GL_CLIENT_ALL_ATTRIB_BITS
		glMatrixMode GL_MODELVIEW
		glPushMatrix
		glMatrixMode GL_PROJECTION
		glPushMatrix
		glMatrixMode GL_TEXTURE
		glPushMatrix
		glMatrixMode GL_COLOR
		glPushMatrix 
		
		EnableStates()
	End Method
	
	Method SetCamera(camera:TCamera)
		glViewport(camera._viewx,camera._viewy,camera._viewwidth,camera._viewheight)
		glScissor(camera._viewx,camera._viewy,camera._viewwidth,camera._viewheight)
		glClearColor(camera._brush._r,camera._brush._g,camera._brush._b,1.0)
		
		If camera._clsmode&CLSMODE_COLOR And camera._clsmode&CLSMODE_DEPTH
			glDepthMask(GL_TRUE)
			glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)
		Else
			If camera._clsmode&CLSMODE_COLOR
				glClear(GL_COLOR_BUFFER_BIT)
			Else
				If camera._clsmode&CLSMODE_DEPTH
					glDepthMask(GL_TRUE)
					glClear(GL_DEPTH_BUFFER_BIT)
				EndIf
			EndIf
		EndIf

		If camera._fogmode>FOGMODE_NONE
			glEnable(GL_FOG)
			glFogi(GL_FOG_MODE,GL_LINEAR)
			glFogf(GL_FOG_START,camera._fognear)
			glFogf(GL_FOG_END,camera._fogfar)
			Local rgb#[]=[camera._fogr,camera._fogg,camera._fogb]
			glFogfv(GL_FOG_COLOR,rgb)
		Else
			glDisable(GL_FOG)
		EndIf

		Local ratio#=(Float(camera._viewwidth)/camera._viewheight)
		
		glMatrixMode GL_PROJECTION
		glLoadIdentity
		glLoadMatrixf TMatrix.PerspectiveFovRH(ATan((1.0/(camera._zoom*ratio)))*2.0,ratio#,camera._near,camera._far).GetPtr()
		glScalef 1,1,-1
		
		glMatrixMode GL_MODELVIEW		
		camera._lastglobal=camera._matrix.Inverse()
		glLoadMatrixf camera._lastglobal.GetPtr()
		
		glGetFloatv GL_MODELVIEW_MATRIX,camera._lastmodelview._m
		glGetFloatv GL_PROJECTION_MATRIX,camera._lastprojection._m
		glGetIntegerv GL_VIEWPORT,camera._lastviewport

		camera.ExtractFrustum
	End Method	
	
	Method SetLight(light:TLight,index)
		If light=Null
			glDisable GL_LIGHT[index]
			Return
		EndIf
		
		glEnable GL_LIGHT[index]
		
		glPushMatrix()

		glMultMatrixf(light._matrix.GetPtr())
		
		Local white_light#[]=[1.0,1.0,1.0,1.0]
		glLightfv(GL_LIGHT[index],GL_SPECULAR,white_light)
		
		Local z#=1.0
		Local w#=0.0
		If light._mode>LIGHT_DIRECTIONAL
			z=0.0
			w=1.0
		EndIf
		
		Local rgba#[]=[light._brush._r,light._brush._g,light._brush._b,1.0]
		Local pos#[]=[0.0,0.0,-z,w]
		
		glLightfv(GL_LIGHT[index],GL_POSITION,pos#)
		glLightfv(GL_LIGHT[index],GL_DIFFUSE,rgba#)

		If light._mode>LIGHT_DIRECTIONAL		
			Local range#[]=[light._range]			
			glLightfv(GL_LIGHT[index],GL_LINEAR_ATTENUATION,range)
		EndIf

		If light._mode=LIGHT_SPOT		
			Local dir#[]=[0.0,0.0,-1.0]
			Local outer#[]=[light._outer]		
			glLightfv(GL_LIGHT[index],GL_SPOT_DIRECTION,dir)
			glLightfv(GL_LIGHT[index],GL_SPOT_CUTOFF,outer)		
		EndIf
		
		glPopMatrix()
	End Method
	
	Method SetBrush(brush:TBrush,hasalpha)
		glDisable(GL_ALPHA_TEST)
		
		Local ambient#[]=[WorldConfig.AmbientRed/255.0,WorldConfig.AmbientGreen/255.0,WorldConfig.AmbientBlue/255.0]			
					
		Local no_mat#[]=[0.0,0.0]
		Local mat_ambient#[]=[brush._r,brush._g,brush._b,brush._a]
		Local mat_diffuse#[]=[brush._r,brush._g,brush._b,brush._a]
		Local mat_specular#[]=[brush._shine,brush._shine,brush._shine,brush._shine]
		Local mat_shininess#[]=[100.0]
	
		If brush._fx&FX_FORCEALPHA Or hasalpha
			glEnable(GL_BLEND)
			glDepthMask(GL_FALSE)
		Else
			glDisable(GL_BLEND)
			glDepthMask(GL_TRUE)
		EndIf
		
		Select brush._blend
			Case BLEND_NONE,BLEND_ALPHA
				glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)
			Case BLEND_MULTIPLY
				glBlendFunc(GL_DST_COLOR,GL_ZERO)
			Case BLEND_ADD
				glBlendFunc(GL_SRC_ALPHA,GL_ONE)
		End Select
		
		If brush._fx&FX_FULLBRIGHT
			ambient[0]=1.0
			ambient[1]=1.0
			ambient[2]=1.0		
		EndIf
		
		If brush._fx&FX_VERTEXCOLOR
			glEnable(GL_COLOR_MATERIAL)
		Else
			glDisable(GL_COLOR_MATERIAL)
		EndIf
		
		If brush._fx&FX_FLATSHADED
			glShadeModel(GL_FLAT)
		Else
			glShadeModel(GL_SMOOTH)
		EndIf

		If brush._fx&FX_NOFOG
			glDisable(GL_FOG)
		EndIf
		
		If brush._fx&FX_NOCULLING
			glDisable(GL_CULL_FACE)
		Else
			glEnable(GL_CULL_FACE)
		EndIf
		
		If brush._fx&FX_WIREFRAME Or WorldConfig.Wireframe
			glPolygonMode(GL_FRONT_AND_BACK,GL_LINE)
		Else
			glPolygonMode(GL_FRONT_AND_BACK,GL_FILL)
		EndIf			
			
		glMaterialfv(GL_FRONT,GL_AMBIENT,mat_ambient)
		glMaterialfv(GL_FRONT,GL_DIFFUSE,mat_diffuse)
		glMaterialfv(GL_FRONT,GL_SPECULAR,mat_specular)
		glMaterialfv(GL_FRONT,GL_SHININESS,mat_shininess)
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT,ambient)	
				
		glDisable GL_TEXTURE_2D
		For Local i=0 To 7
			Local texture:TTexture=brush._texture[i]
			If texture=Null Continue
			
			Local texres:TGLTextureRes=TGLTextureRes(UpdateTextureRes(texture))
			
			glActiveTextureARB(GL_TEXTURE0+i)
						
			glEnable GL_TEXTURE_2D
			BindTexture texres._id	
			
			glMatrixMode GL_TEXTURE
			glLoadIdentity
			glScalef texture._sx,texture._sy,1
			
			If texture._flags&TEXTURE_ALPHA
				glEnable(GL_ALPHA_TEST)
			Else
				glDisable(GL_ALPHA_TEST)
			EndIf
		
			If texture._flags&TEXTURE_MIPMAP
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
			Else
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
			EndIf
			
			If texture._flags&TEXTURE_CLAMPU
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
			Else						
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT)
			EndIf
			
			If texture._flags&TEXTURE_CLAMPV
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
			Else
				glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT)
			EndIf
	
			If texture._flags&TEXTURE_SPHMAP				
				glEnable(GL_TEXTURE_GEN_S)
				glEnable(GL_TEXTURE_GEN_T)
				glTexGeni(GL_S,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP)
				glTexGeni(GL_T,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP)
			Else
				glDisable(GL_TEXTURE_GEN_S)
				glDisable(GL_TEXTURE_GEN_T)
			EndIf						
		Next		
	End Method
	
	Method RenderSurface(resource:TSurfaceRes,brush:TBrush)
		Local res:TGLSurfaceRes=TGLSurfaceRes(resource)	
		
		glDisableClientState GL_TEXTURE_COORD_ARRAY
		For Local i=0 To 7
			Local texture:TTexture=brush._texture[i]
			If texture=Null Continue
			glEnableClientState(GL_TEXTURE_COORD_ARRAY)
			glClientActiveTextureARB(GL_TEXTURE0+i)
			glBindBufferARB(GL_ARRAY_BUFFER_ARB,res._vbo[4+texture._coords])
			glTexCoordPointer(2,GL_FLOAT,0,Null)
		Next
		
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,res._vbo[0])
		glVertexPointer(3,GL_FLOAT,0,Null)		
		
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,res._vbo[1])
		glNormalPointer(GL_FLOAT,0,Null)
		
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,res._vbo[2])
		glColorPointer(4,GL_FLOAT,0,Null)
	
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,res._vbo[3])
		glDrawElements(GL_TRIANGLES,res._trianglecnt*3,GL_UNSIGNED_INT,Null)
		
		Return res._trianglecnt
	End Method
	
	Method BeginEntityRender(entity:TEntity)		
		If entity._order<>0
			glDisable(GL_DEPTH_TEST)
			glDepthMask(GL_FALSE)
		Else
			glEnable(GL_DEPTH_TEST)
			glDepthMask(GL_TRUE)
		EndIf
		
		glMatrixMode(GL_MODELVIEW)
		glPushMatrix()
		glMultMatrixf(entity.GetMatrix(True,False).GetPtr())
	End Method
	Method EndEntityRender(entity:TEntity)
		glMatrixMode(GL_MODELVIEW)
		glPopMatrix()
	End Method
	
	Method RenderPlane(plane:TPlane)
		glDisable(GL_BLEND)		
		glDepthMask(GL_TRUE)
		glBegin(GL_QUADS)	
			glNormal3f 0,1,0
			glTexCoord2f 0,0
			glVertex3f(-1,0, 1)				
			glTexCoord2f 1,0	
			glVertex3f(1, 0, 1)			
			glTexCoord2f 1,1
			glVertex3f(1, 0, -1)
			glTexCoord2f 0,1
			glVertex3f(-1,0, -1)			
		glEnd()
		Return 2
	End Method
	
	Method RenderSprite(sprite:TSprite)
		glBegin GL_QUADS
			glNormal3f 0,0,1
			glTexCoord2f 0,1
			glVertex3f 1, -1, 0			
			glTexCoord2f 0,0
			glVertex3f 1, 1, 0			
			glTexCoord2f 1,0
			glVertex3f -1,1, 0			
			glTexCoord2f 1,1
			glVertex3f -1,-1, 0
		glEnd
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
	
	Method UpdateTextureRes:TTextureRes(texture:TTexture)
		Local glres:TGLTextureRes=TGLTextureRes(texture._res)
		If glres=Null
			glres=New TGLTextureRes
			texture._res=glres
			texture._updateres=True
		EndIf		
		If Not texture._updateres Return texture._res
		
		If glres._id=0 glGenTextures(1,Varptr glres._id)
		BindTexture glres._id
		gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGBA8,texture._width,texture._height,GL_RGBA,GL_UNSIGNED_BYTE,texture._pixmap.pixels)
		
		texture._updateres=0
		Return glres
	End Method
	
	Method UpdateSurfaceRes:TGLSurfaceRes(surface:TSurface)
		Local res:TGLSurfaceRes=TGLSurfaceRes(surface._res)
		If res=Null res=New TGLSurfaceRes;surface._res=res
		If surface._reset=0 Return res
		
		If res._vbo[0]=0 glGenBuffersARB(4,res._vbo)
	
		If surface._reset=-1 Then surface._reset=1|2|4|8|16
	
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
		Global res:TGLSurfaceRes=New TGLSurfaceRes
		Local res_base:TGLSurfaceRes=TGLSurfaceRes(UpdateSurfaceRes(base))
		Local res_anim:TGLSurfaceRes=TGLSurfaceRes(UpdateSurfaceRes(animation))
		res._vbo=res_base._vbo[..]
		res._texcoord=res_base._texcoord
		res._vbo[0]=res_anim._vbo[0]
		Return res
	End Method
	
	Method UploadVertexBuffer(vbo,data#[])
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbo)
		glBufferDataARB(GL_ARRAY_BUFFER_ARB,data.length*4,data,GL_STATIC_DRAW_ARB)
	End Method
	
	Method UploadVertexNormals(vbo,data#[])
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbo)
		Local cpy#[]=data[..]
		For Local i=0 To cpy.length-1
			cpy[i]:*-1
		Next
		glBufferDataARB(GL_ARRAY_BUFFER_ARB,data.length*4,cpy,GL_STATIC_DRAW_ARB)
	End Method
End Type

Type TGLSurfaceRes Extends TSurfaceRes
	Field _vbo[12]
	Field _texcoord
End Type

Type TGLTextureRes Extends TTextureRes
	Field _id
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function GLMaxB3DDriver:TGLMaxB3DDriver()
	If GLMax2DDriver()
		Global driver:TGLMaxB3DDriver=New TGLMaxB3DDriver
		driver._parent=GLMax2DDriver()
		Return driver
	End If
End Function

Local driver:TGLMaxB3DDriver=GLMaxB3DDriver()
If driver SetGraphicsDriver driver,GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER