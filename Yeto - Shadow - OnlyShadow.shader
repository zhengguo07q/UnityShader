// ***************************************************************
//  Copyright(c) Yeto
//  FileName	: Yeto - Shadow - OnlyShadow.shader
//  Creator 	: zg
//  Date		: 2016-7-1
//  Comment		: 
// ***************************************************************

Shader "Yeto/Shadow/OnlyShadow"
{
	Properties
	{
		_ShadowColor("Shadow Color", Color) = (1, 1, 1, 1)
	}

	SubShader
		{
			Tags{ "RenderType" = "Opaque" }

			pass
			{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM

				#pragma target 3.0
				#pragma fragmentoption ARB_precision_hint_fastest

				#pragma vertex vertShadow
				#pragma fragment fragShadow
				#pragma multi_compile_fwdbase

				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				float4 _ShadowColor;
				float4 _LightColor0;

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					LIGHTING_COORDS(1, 2)
				};

				v2f vertShadow(appdata_base v)
				{
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;

					TRANSFER_VERTEX_TO_FRAGMENT(o);

					return o;
				}

				float4 fragShadow(v2f i) : COLOR
				{
					float attenuation = LIGHT_ATTENUATION(i) ;		//没有阴影的时候这里为1， 有阴影的时候这里为0， 阴影越强值越小[0-1]
					
					if (attenuation >= 0.99)							//深度<0 抛弃
						discard;

					float4 finalColor = attenuation * _ShadowColor * _LightColor0;
					return finalColor;
				}
				ENDCG
			}
		}
	FallBack "Diffuse"
}