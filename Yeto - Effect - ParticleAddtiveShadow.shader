Shader "Yeto/Effect/ParticleAddtiveShadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ShadowCol("Shadow Col", Color) = (0.1, 0.1, 0.1, 0.5)
	}

	CGINCLUDE
#include "UnityCG.cginc"
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _ShadowCol;

	float4x4 _World2Ground;
	float4x4 _Ground2World;

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 color : TEXCOORD1;
	};

	v2f vert_part(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.color = v.color;
		return o;
	}

	fixed4 frag_part(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		col *= i.color;
		return col;
	}
			
	v2f vert_shadow(appdata v)
	{
		v2f o;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.color = v.color;

		float3 litDir;
		litDir = WorldSpaceLightDir(v.vertex);
		litDir = mul(_World2Ground,float4(litDir,0)).xyz;
		litDir = normalize(litDir);
		float4 vt;
		vt = mul(unity_ObjectToWorld, v.vertex);
		vt = mul(_World2Ground,vt);
		vt.xz = vt.xz - (vt.y / litDir.y)*litDir.xz;
		vt.y = 0;
		vt = mul(_Ground2World,vt);
		vt = mul(unity_WorldToObject,vt);
		o.vertex = UnityObjectToClipPos(vt);

		return o;
	}
	float4 frag_shadow(v2f i) : COLOR
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		_ShadowCol.a = col.a * i.color.a * _ShadowCol.a;
		return _ShadowCol;
	}

	ENDCG

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "IGNOREPROJECTOR" = "TRUE" "QUEUE" = "AlphaTest" }		//使用AlphaTest的渲染队列来进行渲染， 这样所有的渲染在不透明之后
		LOD 100

		Pass
		{

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Offset -10000, -1
			Cull Off
			Lighting Off
			CGPROGRAM
#pragma vertex vert_shadow
#pragma fragment frag_shadow
			ENDCG
		}
		Pass
		{

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			Lighting Off
			ZWrite Off
			CGPROGRAM
#pragma vertex vert_part
#pragma fragment frag_part
			ENDCG
		}
	}
}
