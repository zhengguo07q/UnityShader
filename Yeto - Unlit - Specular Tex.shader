// ***************************************************************
//  Copyright(c) Yeto
//  FileName	: Yeto - Unlit - Specular Tex.cs
//  Creator 	: 
//  Date		: 2017-6-2
//  Comment		: 支持高光贴图， 支持一盏灯光
// ***************************************************************


Shader "Yeto/Unlit/Specular Tex" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular Tex", 2D) = "white" {}
		_SpecularPower("Specular Range", Range(0.0, 1000.0)) = 1.0
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
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

		//自定义的输出结构
		struct SurfaceOutputSpecular
		{
			fixed3 Albedo;	//环境光
			fixed3 Normal;	//法线
			fixed3 Emission;//自发光颜色值
			half Specular;	//镜面反射度
			fixed Gloss;	//光泽度
			fixed Alpha;	//透明度

			fixed3 SpecularTex;
		};

		inline fixed4 LightingPhong(SurfaceOutputSpecular s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			float diff = dot(s.Normal, lightDir);								//计算法线与光照夹脚
			float3 reflection = normalize(2.0 * s.Normal * diff - lightDir);	//高光算法
			float spec = pow(max(0, dot(reflection, viewDir)), _SpecularPower);	//高光强度
			float3 finalSpec = _SpecularColor.rgb * spec * s.SpecularTex;		//最终的高光颜色， 增加了高光贴图
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff) + (_LightColor0.rgb * finalSpec) * (atten * 2); //漫反射颜色+高光颜色
			c.a = 1.0;
			return c;
		}

		void surf (Input IN, inout SurfaceOutputSpecular o) 
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.SpecularTex = tex2D(_SpecularTex, IN.uv_MainTex);		//高光贴图
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
