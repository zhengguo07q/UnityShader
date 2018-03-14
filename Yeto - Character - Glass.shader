Shader "Yeto/Character/Glass"
{
	Properties
	{
		_MainCol("Main Color", Color) = (1, 1, 1, 1)
		_Opacity("Opacity", Range( 0 , 1)) = 0.085
		_SpecularTex("Specular Texture", 2D) = "white" {}
		_Fresnel("Fresnel", Range( 0 , 10)) = 1.39
		_SpecularPower("Specular Range", Range(0.0, 1000.0)) = 1.0
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Phong keepalpha
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _Fresnel;
		uniform sampler2D _SpecularTex;
		uniform float4 _SpecularTex_ST;
		uniform float _Opacity;

		uniform float4 _MainCol;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

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
			fixed Fresnel;
		};

		inline fixed4 LightingPhong(SurfaceOutputSpecular s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			float diff = dot(s.Normal, lightDir);								//计算法线与光照夹脚
			float3 reflection = normalize(2.0 * s.Normal * diff - lightDir);	//高光算法
			float spec = pow(max(0, dot(reflection, viewDir)), _SpecularPower);	//高光强度
			float3 finalSpec = _SpecularColor.rgb * spec * s.SpecularTex;		//最终的高光颜色， 增加了高光贴图
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * s.Fresnel) +  (s.Albedo * _LightColor0.rgb * diff ) + (_LightColor0.rgb * finalSpec) * (atten * 2); //漫反射颜色+高光颜色
			c.a = s.Alpha;
			return c;
		}

		void surf( Input i , inout SurfaceOutputSpecular o )
		{
			fixed4 c = _MainCol;
			o.SpecularTex = tex2D(_SpecularTex, i.uv_texcoord);		//高光贴图
			o.Albedo = c.rgb;
			o.Alpha = _Opacity;

			float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			o.Fresnel = (0.0 + 1.0*pow(1.0 - dot(i.worldNormal, worldViewDir), _Fresnel));
		}

		ENDCG
	}
}
