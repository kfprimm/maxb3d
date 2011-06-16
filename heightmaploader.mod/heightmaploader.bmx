
Strict

Rem
	bbdoc: Heightmap mesh loader for MaxB3D
End Rem
Module MaxB3D.HeightmapLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core

Type TMeshLoaderHMAP Extends TMeshLoader
	Method Run(mesh:TMesh,stream:TStream,url:Object)
		Local pixmap:TPixmap=TPixmap(url)
		If pixmap=Null pixmap=LoadPixmap(stream)
		If pixmap=Null Return False
		
		pixmap=XFlipPixmap(ConvertPixmap(pixmap,PF_I8))
		Local width=PixmapWidth(pixmap),height=PixmapHeight(pixmap)
		
		Local surface:TSurface=mesh.AddSurface(height*width,height*width*2)		
		
		Local stx#=-1,sty#=stx,y#=sty
		For Local a=0 To height-1
			Local x#=stx,v#=a/Float(height)
			For Local b=0 To width-1
				Local u#=b/Float(width)
				Local vert=width*a+b
				surface.SetCoord vert,x,pixmap.pixels[a*height+b]/255.0,y
				surface.SetTexCoord vert,u,v
				x:+2.0/width
			Next
			y:+2.0/height
		Next
		
		For Local a=0 To height-2
			For Local b=0 To width-2
				Local v0=a*width+b,v1=v0+1
				Local v2=(a+1)*width+(b+1),v3=v2-1
				surface.SetTriangle(2*(a*(width-2)+b)+0,v0,v2,v1)
				surface.SetTriangle(2*(a*(width-2)+b)+1,v0,v3,v2)
			Next
		Next
		
		mesh.UpdateNormals()
		
		Return True
	End Method
	
	Method Name$()
		Return "Heightmap"
	End Method
	Method ModuleName$()
		Return "heightmaploader"
	End Method

End Type
New TMeshLoaderHMAP