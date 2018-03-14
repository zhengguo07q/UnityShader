// ***************************************************************
// Copyright(c) Yeto
// FileName	: 
// Creator	: 
// Date		: 2017-6-2
// Comment	: 加了一个自发光贴图, 一种内的边缘发光
// ***************************************************************


Shader "Yeto/Character/Unlit/Diffuse Alpha Outline"
{
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		_Illumin("Illumin Color", Color) = (0,0,0,0)

		_OutlineWidth("Outline Width",Range(0,0.1)) = 0.01
		_OutLineColor("Outline Color",Color) = (0,0,0,1)
	}
	SubShader
	{
			//不透明的模型
		Tags{ "Queue"="Geometry" "RenderType"="Opaque" }		//多边形为先画前面的在画后面的， 这样会导致描边被后面的怪遮挡， 改成透明的， 就会先画后面的在画前面的
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color; 
			 
			struct appdata 
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a = sign(col.r + col.g + col.b) * -1 + 1;
				return col;
			}
			ENDCG
		}


	}
}
