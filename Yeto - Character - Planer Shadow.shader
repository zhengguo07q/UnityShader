// ***************************************************************
// Copyright(c) Yeto
// FileName	: Yeto - Character - Planer Shadow.shader
// Creator	: 
// Date		: 
// Comment	: 平面阴影
// ***************************************************************


Shader "Yeto/Character/Planer Shadow"
{
	Properties
	{
	//	_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100
		pass
		{
			Stencil
			{
				Ref 1
				Comp NotEqual
				Pass replace
			}
			Cull Back
			Blend DstColor SrcColor
			Offset -1,-1
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"
			float4x4 _World2Ground;
			float4x4 _Ground2World;
			float4 vert(float4 vertex: POSITION) : SV_POSITION
			{
				float3 litDir = WorldSpaceLightDir(vertex);				//顶点在世界空间的光照方向	
				litDir = mul(_World2Ground,float4(litDir,0)).xyz;		//光照方向转到地板空间
				litDir = normalize(litDir);
				float4 vt;
				vt = mul(unity_ObjectToWorld, vertex);					//对象在世界空间位置
				vt = mul(_World2Ground,vt);								//对象在地板空间位置
				vt.xz = vt.xz - (vt.y / litDir.y)*litDir.xz;
				vt.y = 0;
				vt = mul(_Ground2World,vt);
				vt = mul(unity_WorldToObject,vt);
				return UnityObjectToClipPos(vt);
			}
			float4 frag(void) : COLOR
			{
				return float4(0.3,0.3,0.3,1);//跟多层有关系，跟深度有关系
			}
			ENDCG
		}
	}
}
