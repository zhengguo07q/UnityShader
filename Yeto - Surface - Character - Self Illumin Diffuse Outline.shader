// ***************************************************************
// Copyright(c) Yeto
// FileName	: Yeto - Surface - Character - Self Illumin Diffuse Outline.shader
// Creator	: 
// Date		: 2017-6-2
// Comment	: 
// ***************************************************************


Shader "Yeto/Surface/Character/Self Illumin Diffuse Outline" 
{
	Properties 
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular Tex", 2D) = "white" {}
		_SpecularPower("Specular Range", Range(0.0, 1000.0)) = 1.0
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_OutlineWidth("Outline Width",Range(0,2)) = 0.01
		_OutLineColor("Outline Color",Color) = (0,0,0,1)

		_FixColor("Fix Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_FixPos("Fix Pos", Color) = (1.0, 1.0, 1.0, 1.0)
		_FixPower("Fix Power", Range(0.0, 30)) = 3.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
			CGPROGRAM
#pragma surface surf Phong fullforwardshadows

			sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		sampler2D _SpecularTex;
		half _SpecularPower;
		fixed4 _SpecularColor;

		fixed4 _FixColor;
		fixed4 _FixPos;
		float _FixPower;

		//自定义的输出结构
		struct SurfaceOutputSpecular
		{
			fixed3 Albedo;	//环境光
			fixed3 Normal;	//法线
			fixed3 Emission;//自发光颜色值
			half Specular;	//镜面反射度
			fixed Gloss;	//光泽度
			fixed Alpha;	//透明度

			fixed4 SpecularTex;
		};

		inline fixed4 LightingPhong(SurfaceOutputSpecular s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			float diff = dot(s.Normal, lightDir);								//计算法线与光照夹脚
			float3 reflection = normalize(2.0 * s.Normal * diff - lightDir);	//高光算法
			float spec = pow(max(0, dot(reflection, viewDir)), _SpecularPower);	//高光强度
			float3 finalSpec = _SpecularColor.rgb * spec * s.SpecularTex.rrr;		//最终的高光颜色， 增加了高光贴图
																					//计算固定位方向光
			float3 fixDiff = saturate(dot(s.Normal, normalize(_FixPos.xyz)));		//测光
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff) + (_LightColor0.rgb * finalSpec) * (atten * 2) + _FixColor * pow(fixDiff, _FixPower); //漫反射颜色+高光颜色
			c.a = 1.0;
			return c;
		}

		void surf(Input IN, inout SurfaceOutputSpecular o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.SpecularTex = tex2D(_SpecularTex, IN.uv_MainTex);		//高光贴图
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG

		Pass
		{
			Cull Off
			ZWrite Off		//关闭Z缓冲， 这样避免画出来的平板边框存在像素深度排序，这样所有的边都有描边
			Cull Front

			CGPROGRAM

	#include "UnityCG.cginc"
	#pragma vertex vert
	#pragma fragment frag

				struct v2f
			{
				float4 pos : POSITION;
			};

			float _OutlineWidth;
			half4 _OutLineColor;

			v2f vert(appdata_full v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _OutlineWidth;	//把顶点的数据往法线方向放大一些， 放大的倍数为*Width
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			half4 frag(v2f IN) :COLOR
			{
				return _OutLineColor;
			}
				ENDCG
			}
		}
	FallBack "Diffuse"
}
