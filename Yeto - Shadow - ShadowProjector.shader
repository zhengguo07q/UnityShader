// ***************************************************************
//  Copyright(c) Yeto
//  FileName	: Yeto - Shadow - ShadowProjector.cs
//  Creator 	: 
//  Date		: 2017-6-22
//  Comment		: 渲染投射出来的阴影贴图的shader
// ***************************************************************


Shader "Yeto/Shadow/ShadowProjector" 
{
	Properties 
	{
		_ShadowTex ("ShadowTex", 2D) = "gray" {}
		_ShadowFactor ("Shadowfactor", Range(0,1)) = 0.16
		_ShadowMask ("ShadowMask",2D) = "white"{}
	}
	SubShader 
	{
		Tags { "Queue"="AlphaTest+1" }
		Pass 
		{
			ZWrite Off
			ColorMask RGB
			Blend DstColor Zero
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos:POSITION;
				float4 sproj:TEXCOORD0;
			};

			float4x4 unity_Projector;
			sampler2D _ShadowTex;
			sampler2D _ShadowMask;
			uniform half4 _ShadowTex_TexelSize;
			float _ShadowFactor;

			v2f vert(float4 vertex:POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.sproj = mul(unity_Projector, vertex);
				return o;
			}

			float4 frag(v2f i):COLOR
			{
				half4 shadowCol = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.sproj));
				half maskCol = tex2Dproj(_ShadowMask, UNITY_PROJ_COORD(i.sproj)).r;
				half a = (shadowCol * maskCol).a;

				return float4(1, 1, 1, 1) - _ShadowFactor * a * float4(1, 1, 1, 1) * step(0, a);
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
