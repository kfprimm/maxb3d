
Strict

Rem
	bbdoc: Primitive mesh loader for MaxB3D.
End Rem
Module MaxB3D.Primitives
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateCube:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*cube*",parent)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateCone:TMesh(segments=8,solid=True,parent:TEntity=Null)
	Return _currentworld.AddMesh("*cone*("+segments+","+solid+")",parent)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateCylinder:TMesh(segments=8,solid=True,parent:TEntity=Null)
	Return _currentworld.AddMesh("*cylinder*("+segments+","+solid+")",parent)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateSphere:TMesh(segments=8,parent:TEntity=Null)
	Return _currentworld.AddMesh("*sphere*("+segments+")",parent)
End Function
Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CreateTorus:TMesh(radius#,width#,segments,sides,parent:TEntity=Null)
	Return _currentworld.AddMesh("*torus*("+radius+","+width+","+segments+","+sides+")",parent)
End Function

Type TMeshLoaderPrimitives Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local str$=String(url)
		Local params$[]=str[str.Find("(")+1..str.FindLast(")")].Split(",")
		
		Select str[str.Find("*")+1..str.FindLast("*")]
		Case "sphere"
			Local segments=Int(params[0])
			If segments<2 Or segments>100 Then Return Null
			
			'Vertex count
			'((segments*2)*4) '2
			'((segments*2)*6)+((segments*2)*((segments-2)*4)) '>2
			
			'Triangle count
			'(segments*2)*2
			'(segments*2)*2+(segments*2)*(segments-2)*2

			Local vertexcount=4*segments*(3+((segments-2)*2))
			Local trianglecount=segments*4*(1+(segments-2))
			If segments=2
				vertexcount=segments*8
				trianglecount=segments*4
			EndIf
			
			Local surface:TSurface=mesh.AddSurface(vertexcount,trianglecount)
			
			Local div#=Float(360.0/(segments*2))
			Local height#=1.0
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments*2))
			Local vdiv#=Float(1.0/segments)
			Local RotAngle#=90	
			
			If segments=2
				For Local i=1 To (segments*2)
					Local np=(i-1)*4+0,sp=np+1
					surface.SetCoord(np,0.0,height,0.0);surface.SetTexCoord(np,upos#-(udiv#/2.0),0) 'northpole					
					surface.SetCoord(sp,0.0,-height,0.0);surface.SetTexCoord(sp,upos#-(udiv#/2.0),1) 'southpole
					Local XPos#=-Cos(RotAngle#)
					Local ZPos#=Sin(RotAngle#)
					Local v0=sp+1
					surface.SetCoord(v0,XPos#,0,ZPos#)
					surface.SetTexCoord(v0,upos#,0.5)
					RotAngle#=RotAngle#+div#
					If RotAngle#>=360.0 Then RotAngle#=RotAngle#-360.0
					XPos#=-Cos(RotAngle#)
					ZPos#=Sin(RotAngle#)
					upos#=upos#-udiv#
					Local v1=v0+1
					surface.SetCoord(v1,XPos#,0,ZPos#)
					surface.SetTexCoord(v1,upos#,0.5)
					
					surface.SetTriangle((i-1)*2+0,np,v0,v1)
					surface.SetTriangle((i-1)*2+1,v1,v0,sp)	
				Next	
			Else
				For Local i=1 To (segments*2)	
					Local np=(i-1)*6+0,sp=np+1
					surface.SetCoord(np,0.0,height,0.0)
					surface.SetTexCoord(np,upos#-(udiv#/2.0),0)'northpole
					surface.SetCoord(sp,0.0,-height,0.0)
					surface.SetTexCoord(sp,upos#-(udiv#/2.0),1)'southpole
					
					Local YPos#=Cos(div#)
					
					Local XPos#=-Cos(RotAngle#)*(Sin(div#))
					Local ZPos#=Sin(RotAngle#)*(Sin(div#))
					
					Local v0t=sp+1
					surface.SetCoord(v0t,XPos#,YPos#,ZPos#)
					surface.SetTexCoord(v0t,upos#,vdiv#)
					Local v0b=v0t+1
					surface.SetCoord(v0b,XPos#,-YPos#,ZPos#)
					surface.SetTexCoord(v0b,upos#,1-vdiv#)
					
					RotAngle#=RotAngle#+div#
					
					XPos#=-Cos(RotAngle#)*(Sin(div#))
					ZPos#=Sin(RotAngle#)*(Sin(div#))
					
					upos#=upos#-udiv#
			
					Local v1t=v0b+1
					surface.SetCoord(v1t,XPos#,YPos#,ZPos#)
					surface.SetTexCoord(v1t,upos#,vdiv#)
					Local v1b=v1t+1
					surface.SetCoord(v1b,XPos#,-YPos#,ZPos#)
					surface.SetTexCoord(v1b,upos#,1-vdiv#)
					
					
					surface.SetTriangle((i-1)*2+0,np,v0t,v1t)
					surface.SetTriangle((i-1)*2+1,v1b,v0b,sp)					
				Next
			
				upos#=1.0
				RotAngle#=90
				For Local i=1 To (segments*2)
				
					Local mult#=1
					Local YPos#=Cos(div#*(mult#))
					Local YPos2#=Cos(div#*(mult#+1.0))
					Local Thisvdiv#=vdiv#
					For Local j=1 To (segments-2)			
						Local XPos#=-Cos(RotAngle#)*(Sin(div#*(mult#)))
						Local ZPos#=Sin(RotAngle#)*(Sin(div#*(mult#)))
			
						Local XPos2#=-Cos(RotAngle#)*(Sin(div#*(mult#+1.0)))
						Local ZPos2#=Sin(RotAngle#)*(Sin(div#*(mult#+1.0)))
									
						Local v0t=(segments*2)*6+((i-1)*(segments-2)*4)+((j-1)*4),v0b=v0t+1
						surface.SetCoord(v0t,XPos#,YPos#,ZPos#)
						surface.SetTexCoord(v0t,upos#,Thisvdiv#,0.0)
						surface.SetCoord(v0b,XPos2#,YPos2#,ZPos2#)						
						surface.SetTexCoord(v0b,upos#,Thisvdiv#+vdiv#,0.0)
					
						Local tempRotAngle#=RotAngle#+div#
					
						XPos#=-Cos(tempRotAngle#)*(Sin(div#*(mult#)))
						ZPos#=Sin(tempRotAngle#)*(Sin(div#*(mult#)))
						
						XPos2#=-Cos(tempRotAngle#)*(Sin(div#*(mult#+1.0)))
						ZPos2#=Sin(tempRotAngle#)*(Sin(div#*(mult#+1.0)))				
					
						Local temp_upos#=upos-udiv
			
						Local v1t=v0b+1,v1b=v1t+1
						surface.SetCoord(v1t,XPos,YPos,ZPos)
						surface.SetTexCoord(v1t,temp_upos,Thisvdiv,0.0)
						surface.SetCoord(v1b,XPos2,YPos2,ZPos2)
						surface.SetTexCoord(v1b,temp_upos,Thisvdiv+vdiv,0.0)
						
						surface.SetTriangle((segments*2)*2+((i-1)*(segments-2)*2)+((j-1)*2)+0,v1t,v0t,v0b)
						surface.SetTriangle((segments*2)*2+((i-1)*(segments-2)*2)+((j-1)*2)+1,v1b,v1t,v0b)
						
						Thisvdiv#=Thisvdiv#+vdiv#			
						mult#=mult#+1
						YPos#=Cos(div#*(mult#))
						YPos2#=Cos(div#*(mult#+1.0))
					
					Next
					upos#=upos#-udiv#
					RotAngle#=RotAngle#+div#
				Next
			EndIf			
			
			mesh.UpdateNormals() 
			'mesh.ForEachSurfaceDo FlipNormals
			Return True 
		Case "cylinder"
			Local ringsegments=0
			
			Local segments=Int(params[0]),solid=Int(params[1])
				
			Local tr,tl,br,bl
			Local ts0,ts1,newts
			Local bs0,bs1,newbs
			If segments<3 Or segments>100 Then Return Null
			If ringsegments<0 Or ringsegments>100 Then Return Null
			
			Local surface:TSurface=mesh.AddSurface(1000,1000)
			Local solidsurface:TSurface
			If solid=True
				solidsurface=mesh.AddSurface(1000,1000)
			EndIf
			Local div#=Float(360.0/(segments))
			
			Local height#=1.0
			Local ringSegmentHeight#=(height#*2.0)/(ringsegments+1)
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments))
			Local vpos#=1.0
			Local vdiv#=Float(1.0/(ringsegments+1))
			
			Local SideRotAngle#=90
			
			Local tRing[segments+1]
			Local bRing[segments+1]
			
			If solid=True
				Local xpos#=-Cos(SideRotAngle#)
				Local zpos#=Sin(SideRotAngle#)
			
				ts0=solidsurface.AddVertex(xpos,height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
				bs0=solidsurface.AddVertex(xpos,-height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
				
				solidsurface.SetTexCoord(ts0,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
				solidsurface.SetTexCoord(bs0,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
			
				SideRotAngle=SideRotAngle+div
			
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				
				ts1=solidsurface.AddVertex(xpos#,height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
				bs1=solidsurface.AddVertex(xpos#,-height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
			
				solidsurface.SetTexCoord(ts1,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
				solidsurface.SetTexCoord(bs1,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
				
				For Local i=1 To (segments-2)
					SideRotAngle#=SideRotAngle#+div#
			
					xpos#=-Cos(SideRotAngle#)
					zpos#=Sin(SideRotAngle#)
					
					newts=solidsurface.AddVertex(xpos#,height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
					newbs=solidsurface.AddVertex(xpos#,-height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
					
					solidsurface.SetTexCoord(newts,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
					solidsurface.SetTexCoord(newbs,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
					
					solidsurface.AddTriangle(ts0,ts1,newts)
					solidsurface.AddTriangle(newbs,bs1,bs0)
				
					If i<(segments-2)
						ts1=newts
						bs1=newbs
					EndIf
				Next
			EndIf
			
			Local thisHeight#=height#
			
			SideRotAngle#=90
			Local xpos#=-Cos(SideRotAngle#)
			Local zpos#=Sin(SideRotAngle#)
			Local thisUPos#=upos#
			Local thisVPos#=0
			tRing[0]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)		
			surface.SetTexCoord(tRing[0],thisUPos#,thisVPos#,0.0)
			For Local i=0 To (segments-1)
				SideRotAngle#=SideRotAngle#+div#
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				thisUPos#=thisUPos#-udiv#
				tRing[i+1]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
				surface.SetTexCoord(tRing[i+1],thisUPos#,thisVPos#,0.0)
			Next	
			
			For Local ring=0 To ringsegments
				Local thisHeight=thisHeight-ringSegmentHeight#
				
				SideRotAngle#=90
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				thisUPos#=upos#
				thisVPos#=thisVPos#+vdiv#
				bRing[0]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
				surface.SetTexCoord(bRing[0],thisUPos#,thisVPos#,0.0)
				For Local i=0 To (segments-1)
					SideRotAngle#=SideRotAngle#+div#
					xpos#=-Cos(SideRotAngle#)
					zpos#=Sin(SideRotAngle#)
					thisUPos#=thisUPos#-udiv#
					bRing[i+1]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
					surface.SetTexCoord(bRing[i+1],thisUPos#,thisVPos#,0.0)
				Next
				
				For Local v=1 To (segments)
					tl=tRing[v]
					tr=tRing[v-1]
					bl=bRing[v]
					br=bRing[v-1]
					
					surface.AddTriangle(tl,tr,br)
					surface.AddTriangle(bl,tl,br)
				Next
				
				For Local v=0 To (segments)
					tRing[v]=bRing[v]
				Next		
			Next
					
			mesh.UpdateNormals()
			Return True
		Case "cone"
			Local segments=Int(params[0]),solid=Int(params[1])
						
			If segments<3 Or segments>100 Then Return Null
			
			Local surface:TSurface=mesh.AddSurface(1+segments*2,segments)
			Local bottomsurface:TSurface
			If solid bottomsurface=mesh.AddSurface(1+segments,segments-1)
			
			Local div#=Float(360.0/(segments))
		
			Local height#=1.0
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments))
			Local angle#=90	
		
			Local xpos#=-Cos(angle)
			Local zpos#=Sin(angle)
		
			surface.SetCoord(0,0.0,height,0.0);surface.SetTexCoord(0,upos-(udiv/2.0),0)
			surface.SetCoord(1,xpos,-height,zpos);surface.SetTexCoord(1,upos,1)
		
			If solid bottomsurface.SetCoord(0,xpos,-height,zpos);bottomsurface.SetTexCoord(0,xpos/2.0+0.5,zpos/2.0+0.5)
		
			angle:+div
		
			xpos=-Cos(angle)
			zpos=Sin(angle)
						
			surface.SetCoord(2,xpos,-height,zpos);surface.SetTexCoord(2,upos-udiv,1)
		
			If solid bottomsurface.SetCoord(1,xpos,-height,zpos);bottomsurface.SetTexCoord(1,xpos/2.0+0.5,zpos/2.0+0.5)
			
			surface.SetTriangle(0,2,0,1) 'br,top,bl
		
			For Local i=1 To segments-1
				Local v=1+(i*2)
				upos:-udiv
				surface.SetCoord(v+0,0.0,height,0.0);surface.SetTexCoord(v+0,upos-(udiv/2.0),0)
			
				angle:+div
		
				xpos=-Cos(angle)
				zpos=Sin(angle)
				
				surface.SetCoord(v+1,xpos,-height,zpos);surface.SetTexCoord(v+1,upos-udiv,1)			
				surface.SetTriangle(i,v+1,v+0,v-1)
				
				If solid=True
					bottomsurface.SetCoord(i+1,xpos,-height,zpos);bottomsurface.SetTexCoord(i+1,xpos/2.0+0.5,zpos/2.0+0.5)
					bottomsurface.SetTriangle(i-1,i+1,i,0)
				EndIf
			Next		
			
			mesh.UpdateNormals()
			Return True
		Case "cube"
			Local surface:TSurface=mesh.AddSurface(24,12)

			For Local i=0 To 3
				surface.SetNormal(i,0,-1,0)
			Next
			surface.SetCoord( 0, 1.0, 1.0,-1.0);surface.SetTexCoord( 0, 0.0, 0.0)
			surface.SetCoord( 1,-1.0, 1.0,-1.0);surface.SetTexCoord( 1, 0.0, 1.0)
			surface.SetCoord( 2,-1.0, 1.0, 1.0);surface.SetTexCoord( 2,-1.0, 1.0)
			surface.SetCoord( 3, 1.0, 1.0, 1.0);surface.SetTexCoord( 3,-1.0, 0.0)
			surface.SetTriangle( 0, 0, 1, 2)
			surface.SetTriangle( 1, 3, 0, 2)			
			
			For Local i=4 To 7
				surface.SetNormal(i,0,1,0)
			Next
			surface.SetCoord( 4, 1.0,-1.0, 1.0);surface.SetTexCoord( 4, 0.0, 0.0)
			surface.SetCoord( 5,-1.0,-1.0, 1.0);surface.SetTexCoord( 5, 0.0, 1.0)
			surface.SetCoord( 6,-1.0,-1.0,-1.0);surface.SetTexCoord( 6,-1.0, 1.0)
			surface.SetCoord( 7, 1.0,-1.0,-1.0);surface.SetTexCoord( 7,-1.0, 0.0)
			surface.SetTriangle( 2, 4, 5, 6)
			surface.SetTriangle( 3, 7, 4, 6)	
			
			For Local i=8 To 11
				surface.SetNormal(i,0,0,-1)
			Next
			surface.SetCoord( 8, 1.0, 1.0, 1.0);surface.SetTexCoord( 8,-1.0, 0.0)
			surface.SetCoord( 9,-1.0, 1.0, 1.0);surface.SetTexCoord( 9, 0.0, 0.0)
			surface.SetCoord(10,-1.0,-1.0, 1.0);surface.SetTexCoord(10, 0.0, 1.0)
			surface.SetCoord(11, 1.0,-1.0, 1.0);surface.SetTexCoord(11,-1.0, 1.0)
			surface.SetTriangle( 4,8 , 9,10)
			surface.SetTriangle( 5,11, 8,10)	
	
			For Local i=12 To 15
				surface.SetNormal(i,0,0,1)
			Next
			surface.SetCoord(12, 1.0,-1.0,-1.0);surface.SetTexCoord(12, 0.0, 1.0)
			surface.SetCoord(13,-1.0,-1.0,-1.0);surface.SetTexCoord(13,-1.0, 1.0)
			surface.SetCoord(14,-1.0, 1.0,-1.0);surface.SetTexCoord(14,-1.0, 0.0)
			surface.SetCoord(15, 1.0, 1.0,-1.0);surface.SetTexCoord(15, 0.0, 0.0)
			surface.SetTriangle( 6,12,13,14)
			surface.SetTriangle( 7,15,12,14)	
			
			For Local i=16 To 19
				surface.SetNormal(i,1,0,0)
			Next
			surface.SetCoord(16,-1.0, 1.0, 1.0);surface.SetTexCoord(16,-1.0, 0.0)
			surface.SetCoord(17,-1.0, 1.0,-1.0);surface.SetTexCoord(17, 0.0, 0.0)
			surface.SetCoord(18,-1.0,-1.0,-1.0);surface.SetTexCoord(18, 0.0, 1.0)
			surface.SetCoord(19,-1.0,-1.0, 1.0);surface.SetTexCoord(19,-1.0, 1.0)
			surface.SetTriangle( 8,16,17,18)
			surface.SetTriangle( 9,19,16,18)	
			
			For Local i=20 To 23
				surface.SetNormal(i,-1,0,0)
			Next
			surface.SetCoord(20, 1.0, 1.0,-1.0);surface.SetTexCoord(20,-1.0, 0.0)
			surface.SetCoord(21, 1.0, 1.0, 1.0);surface.SetTexCoord(21, 0.0, 0.0)
			surface.SetCoord(22, 1.0,-1.0, 1.0);surface.SetTexCoord(22, 0.0, 1.0)
			surface.SetCoord(23, 1.0,-1.0,-1.0);surface.SetTexCoord(23,-1.0, 1.0)
			surface.SetTriangle(10,20,21,22)
			surface.SetTriangle(11,23,20,22)	
			Return True
		Case "torus"
			'torrad#,torwidth#,segments,sides
			Local torrad#=Float(params[0]),torwidth#=Float(params[1]),segments=Int(params[2]),sides=Int(params[3])
			
			Local surface:TSurface=mesh.AddSurface(segments*sides,segments*sides*2)
			
			Local FATSTEP#=360.0/sides
			Local DEGSTEP#=360.0/segments
			
			Local radius#=0,x#=0,y#=0,z#=0
			For Local f=0 To sides-1
				Local fat#=FATSTEP*f
				radius = torrad + torwidth*Sin(fat)
				z=torwidth*Cos(fat)
				For Local d=0 To segments-1
					Local deg#=DEGSTEP*f
					x=radius*Cos(deg)
					y=radius*Sin(deg)
					surface.SetCoord f*segments+d,x,y,z
					surface.SetTexCoord f*segments+d,x,y				
				Next
			Next
			
			For Local v=0 To segments*sides-1
				Local v0=v,v1=v+segments,v2=v+1,v3=v+1+segments
				
				If v1>=segments*sides v1:-(segments*sides)
				If v2>=segments*sides v2:-(segments*sides)
				If v3>=segments*sides v3:-(segments*sides)
				
				surface.SetTriangle v*2+0,v0,v1,v2
				surface.SetTriangle v*2+1,v1,v3,v2	
			Next

		Default
			Return False
		End Select
	End Method
	
	Method Name$()
		Return "Primitives"
	End Method
	Method ModuleName$()
		Return "primitives"
	End Method

	
	Function FlipNormals(surface:TSurface)
		For Local v=0 To surface._vertexcnt-1
			Local nx#,ny#,nz#
			surface.GetNormal(v,nx,ny,nz)
			surface.SetNormal(v,-nx,-ny,-nz)
		Next
	End Function	
End Type

New TMeshLoaderPrimitives