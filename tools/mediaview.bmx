
Strict

Framework MaxB3D.GUI
Import MaxB3D.Loaders
Import BRL.Timer

AppTitle="MediaView"
SetGraphicsDriver D3D9MaxB3DDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER

New TApplet.Run

Type TApplet
	Field window:TGadget,canvas:TGadget
	Field camera:TCamera,mesh:TMesh
	
	Method New()
		window=CreateWindow(AppTitle,0,0,400,400)
		canvas=CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
		SetGadgetLayout canvas,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
		
		CreateLight()	
			
		mesh=CreateCube()
		camera=CreateCamera()
		SetEntityPosition camera,0,0,-5
		
		CreateTimer(60)
		
		AddHook EmitEventHook, EventHook,Self
	End Method
	
	Function EventHook:Object(id,data:Object,context:Object)
		TApplet(context).PollEvent(TEvent(data))
	End Function
	
	Method PollEvent(event:TEvent)
		Select event.id
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_TIMERTICK
			TurnEntity mesh,1,1,0
			RedrawGadget canvas
		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics(canvas)
			RenderWorld
			Flip
		End Select
	End Method
	
	Method Run()
		Repeat
			WaitSystem
		Forever	
	End Method
End Type