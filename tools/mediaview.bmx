
Strict

Framework MaxB3D.GUI

SetWorld CreateWorld()
New TApplet.Run

Type TApplet
	Field window:TGadget,canvas:TGadget
	Field camera:TCamera
	
	Method New()
		window=CreateWindow(AppTitle,0,0,400,400)
		canvas=CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
		SetGadgetLayout canvas,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
		
		CreateCube()
		camera=CreateCamera()
		SetEntityPosition camera,0,0,-5
		
		AddHook EmitEventHook, EventHook,Self
	End Method
	
	Function EventHook:Object(id,data:Object,context:Object)
		TApplet(context).PollEvent(TEvent(data))
	End Function
	
	Method PollEvent(event:TEvent)
		Select event.id
		Case EVENT_WINDOWCLOSE
			End
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