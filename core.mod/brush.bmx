
Strict

Import Prime.Max2DEx
Import "texture.bmx"

Const FX_NONE        = 0
Const FX_FULLBRIGHT  = 1
Const FX_VERTEXCOLOR = 2
Const FX_FLATSHADED  = 4
Const FX_NOFOG	       = 8
Const FX_NOCULLING   = 16
Const FX_FORCEALPHA  = 32
Const FX_WIREFRAME   = 64

Type TBrush
	Field _name$
	Field _r#=1.0,_g#=1.0,_b#=1.0,_a#=1.0
	Field _shine#
	Field _texture:TTexture[8],_textureframe[8]
	Field _blend,_fx
	Field _shader:TShader
	
	Method Copy:TBrush()
		Local newbrush:TBrush=New TBrush
		newbrush.Load Self
		Return newbrush
	End Method
	
	Method Merge:TBrush(master:TBrush)
		Local red#,green#,blue#,alpha#,shine#,blend,fx,shader:TShader
		red=master._r;green=master._g;blue=master._b;alpha=master._a
		blend=master._blend;fx=master._fx;shader=master._shader
		
		red:*_r;green:*_g;blue:*_b;alpha:*_a
		Local shine2#=_shine
		If shine=0.0 Then shine=shine2
		If shine<>0.0 And shine2<>0.0 Then shine:*shine2
		If blend=0 Then blend=_blend
		fx:|_fx
		If shader=Null shader=_shader
		
		Local newbrush:TBrush=New TBrush
		newbrush.SetColor red*255,green*255,blue*255
		newbrush.SetAlpha alpha
		newbrush.SetShine shine
		newbrush.SetBlend blend
		newbrush.SetFX fx
		newbrush.SetShader shader
		
		For Local i=0 To 7
			newbrush.SetTexture _texture[i],i,_textureframe[i]
			If master._texture[i] newbrush.SetTexture master._texture[i],i,master._textureframe[i]
		Next
		
		Return newbrush
	End Method
		
	Method Load(brush:TBrush)
		If brush=Null brush=New TBrush
		_r=brush._r;_g=brush._g;_b=brush._b;_a=brush._a
		_shine=brush._shine
		For Local i=0 To 7
			_texture[i]=brush._texture[i]
			_textureframe[i]=brush._textureframe[i]
		Next
		_blend=brush._blend;_fx=brush._fx
	End Method
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
	
	Method GetColor(red Var,green Var,blue Var)
		red=_r*255.0;green=_g*255.0;blue=_b*255.0
	End Method
	Method SetColor(red,green,blue)
		_r=red/255.0;_g=green/255.0;_b=blue/255.0
	End Method
	
	Method GetAlpha#()
		Return _a
	End Method
	Method SetAlpha(alpha#)
		_a=alpha
	End Method
	
	Method GetShine#()
		Return _shine
	End Method
	Method SetShine(shine#)
		_shine=shine
	End Method
	
	Method GetTexture:TTexture(index=0)
		Return _texture[index]
	End Method
	Method SetTexture(texture:TTexture,index=0,frame=0)
		_texture[index]=texture
		_textureframe[index]=frame
	End Method
	
	Method GetFrame(index=0)
		Return _textureframe[index]
	End Method
	Method SetFrame(frame,index=0)
		_textureframe[index]=frame
	End Method
	
	Method GetBlend()
		Return _blend
	End Method
	Method SetBlend(blend)
		_blend=blend
	End Method
	
	Method GetFX()
		Return _fx
	End Method
	Method SetFX(fx)
		_fx=fx
	End Method	
	
	Method GetShader:TShader()
		Return _shader
	End Method
	Method SetShader(shader:TShader)
		_shader=shader
	End Method
End Type
