
Strict

Import MaxB3D.Core
Import sys87.Newton

Type TNewtonPhysicsDriver Extends TPhysicsDriver
	Field _world:Byte Ptr
	
	Method Init()
		_world = NewtonCreate()
		NewtonSetPlatformArchitecture _world, 0

		Local minSize#[] = [-500.0, -500.0, -500.0]
		Local maxSize#[] = [ 500.0,  500.0,  500.0]
		NewtonSetWorldSize _world, minSize, maxSize		
	
		NewtonSetSolverModel _world, 1
	End Method
	
	Method Destroy()
		NewtonDestroyAllBodies _world
		NewtonDestroy _world
	End Method
	
	Method Update(config:TWorldConfig)		
		NewtonUpdate _world, 1.0/60.0
	End Method
End Type

