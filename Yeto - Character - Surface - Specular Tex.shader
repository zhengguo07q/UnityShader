// ***************************************************************
// Copyright(c) Yeto
// FileName	: Yeto - Character - Surface - Specular Tex.shader
// Creator	: 
// Date		: 2017-6-2
// Comment	: 支持高光贴图
// ***************************************************************


Shader "Yeto/Character/Surface/Specular Tex" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

		_RoughnessTex("Roughness Tex", 2D) = "white" {}
		_Roughness("Roughness", Range(0,1)) = 0.5

		_SpecularPower("Specular Power", Range(0.0, 30)) = 2.0
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Fresnel("Fresnel Value", Range(0,1.0)) = 0.05

		_FixColor("Fix Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_FixPos("Fix Pos", Color) = (1.0, 1.0, 1.0, 1.0)
		_FixPower("Fix Power", Range(0.0, 30)) = 2.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200 
		
		CGPROGRAM
		#pragma surface surf MetallicSoft fullforwardshadows

		sampler2D _MainTex;
		 
		struct Input 
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		 
		sampler2D _RoughnessTex;
		float _Roughness;

		half _SpecularPower;
		fixed4 _SpecularColor;

		float _Fresnel;

		fixed4 _FixColor;
		fixed4 _FixPos;
		float _FixPower;

		inline fixed4 LightingMetallicSoft(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			//统一计算视线方向等
			float3 halfVector = normalize(lightDir + viewDir);
			float NdotL = saturate(dot(s.Normal, normalize(lightDir)));			//灯光方向与法线方向
/*			float NdotH_raw = dot(s.Normal, halfVector);
			float NdotH = saturate(dot(s.Normal, halfVector));
			float NdotV = saturate(dot(s.Normal, normalize(viewDir)));
			float VdotH = saturate(dot(halfVector, normalize(viewDir)));

			//G微表面反射
			float geoEnum = 2.0*NdotH;
			float3 G1 = (geoEnum * NdotV) / NdotH;
			float3 G2 = (geoEnum * NdotL) / NdotH;
			float3 G = min(1.0f, min(G1, G2));

			//通过BRDF查找高光
			float roughness = tex2D(_RoughnessTex, float2(NdotH_raw * 0.5 + 0.5, _Roughness)).r;

			//菲涅尔
			float fresnel = pow(1.0 - VdotH, 5.0);
			fresnel *= (1.0 - _Fresnel);
			fresnel += _Fresnel;

			//最终的高光
			float3 spec = float3(fresnel * G * roughness * roughness) * _SpecularPower;
		*/
			//计算固定位方向光
			float3 fixDiff = saturate(dot(s.Normal, normalize(_FixPos.xyz)));

			float4 c;
		//	c.rgb = (s.Albedo * _LightColor0.rgb * NdotL) + (spec * _SpecularColor.rgb) * (atten * 2.0f) + _FixColor * pow(fixDiff, _FixPower);
			c.rgb = (s.Albedo * _LightColor0.rgb * NdotL) + _FixColor * pow(fixDiff, _FixPower);
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
