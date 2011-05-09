
#include <windows.h>
#include <d3d9.h>

D3DVERTEXELEMENT9 _maxb3d_d3d9_vertexelement[] =	{{0,0,D3DDECLTYPE_FLOAT3,D3DDECLMETHOD_DEFAULT,D3DDECLUSAGE_POSITION,0},
                      										 {0,12,D3DDECLTYPE_FLOAT3,D3DDECLMETHOD_DEFAULT,D3DDECLUSAGE_NORMAL,0},
																	// {0,24,D3DDECLTYPE_FLOAT4,D3DDECLMETHOD_DEFAULT,D3DDECLUSAGE_COLOR,0},
                            								 D3DDECL_END()};

extern "C" D3DVERTEXELEMENT9 *maxb3dD3D9VertexElements() {return _maxb3d_d3d9_vertexelement;}