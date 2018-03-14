// ***************************************************************
// Copyright(c) Yeto
// FileName : Yeto - Character - Outline.shader
// Creator	: zg
// Date		: 2017 - 5 - 19
// Comment	: 这个是外边线效果， 这个效果的原理是放大原来的模型， 绘制2次。 这样部分像素被对象本身遮挡， 其他的外边框没有被遮挡的就成边线
// ***************************************************************

Shader "Yeto/Character/Outline"
{
	Properties
	{
		_MainColor("Main Color", Color) = (0.5,0.5,0.5,1)				//主颜色
		_MainTex("Albedo (RGB)", 2D) = "white" {}						//漫反射贴图
		_OutlineColor("Outline Color", Color) = (0.17,0.36,0.81,0.0)	//外边线的颜色
		_OutlineWidth("Outline Width", Range(0.00001, 0.1)) = 0.01		//外边缘的宽度
	}

	SubShader
	{
		//不透明的模型
		Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }		//多边形为先画前面的在画后面的， 这样会导致描边被后面的怪遮挡， 改成透明的， 就会先画后面的在画前面的
		LOD 200

		Pass
		{
			Cull Off
			ZWrite Off		//关闭Z缓冲， 这样避免画出来的平板边框存在像素深度排序，这样所有的边都有描边了
			Cull Front

			CGPROGRAM

#include "UnityCG.cginc"
#pragma vertex vert
#pragma fragment frag

			half _OutlineWidth;
			fixed4 	_OutlineColor;
		
			struct V2F
			{
				float4 pos:SV_POSITION;		//把顶点的位置传入
			};

			V2F vert(appdata_base IN)
			{
				V2F v;
				IN.vertex.xyz += IN.normal * _OutlineWidth;	//把顶点的数据往法线方向放大一些， 放大的倍数为*Width
				v.pos = UnityObjectToClipPos(IN.vertex);
				return v;
			}

			fixed4 frag(V2F V):COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}

		CGPROGRAM

#pragma surface surf Lambert

		sampler2D _MainTex;
		fixed4 _MainColor;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainColor;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
