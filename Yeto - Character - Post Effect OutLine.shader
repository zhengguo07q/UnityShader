// ***************************************************************
// Copyright(c) Yeto
// FileName	: 
// Creator	: 
// Date		: 2017-9-27
// Comment	: 渲染外发光
// ***************************************************************

Shader "Yeto/Character/PostEffectOutLine"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	CGINCLUDE
#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float4 uv12 : TEXCOORD1;
		float4 uv34 : TEXCOORD2;
	};

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;

	float4 _Offsets;
	float4 _OutLineColor;
	float _AntiAliasing;

	v2f vert(appdata_img v)
	{
		v2f o;
		_Offsets *= _MainTex_TexelSize.xyxy;	//贴图像素大小归一化
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		o.uv12 = v.texcoord.xyxy + _Offsets.xyxy * float4(1, 1, -1, 1);
		o.uv34 = v.texcoord.xyxy + _Offsets.xyxy * float4(-1, -1, 1, -1);


#if UNITY_UV_STARTS_AT_TOP					//D3D平台是1， OPENGL是0 电脑上会有效		
		
		if (_AntiAliasing == 0)				//==0则没有开启抗锯齿
		{
			o.uv.y = 1 - o.uv.y;
			o.uv12.yw = 1 - o.uv12.yw;
			o.uv34.yw = 1 - o.uv34.yw;
		}
#endif
		return o;
	}


	fixed4 frag(v2f i) :SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv);

		fixed t = tex2D(_MainTex, i.uv12.xy).a;		//上
		fixed b = tex2D(_MainTex, i.uv12.zw).a;		//下 
		fixed l = tex2D(_MainTex, i.uv34.xy).a;		//左
		fixed r = tex2D(_MainTex, i.uv34.zw).a;		//右
		fixed4 g = fixed4(t, b, l, r) - color.a;	//边缘的颜色为-1
		color.xyz = lerp(_OutLineColor, color.rgb, 1.0 - saturate((sqrt(dot(g, g)) * 1000.0)));
		return color;
	}
	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}