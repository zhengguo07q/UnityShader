// ***************************************************************
//  Copyright(c) Yeto
//  FileName	: Yeto - UI - Unlit - Guide Mask.shader
//  Creator 	:  
//  Date		: 
//  Comment		: 
// ***************************************************************
 

Shader "Yeto/UI/Unlit/Guide Mask"
{
	Properties
	{
		_MainTex("Base (RGB), Alpha (A)", 2D) = "black" {}
		_PositionX("Position X",float) = 500
		_PositionY("Position Y",float) = 500
		_Range("Range", float) = 200
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog{ Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag			
	#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Range;
			float _PositionX;
			float _PositionY;
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				half4 screenPos: TEXCOORD1;
				fixed4 color : COLOR;
			};

			v2f o;

			v2f vert(appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				float2 fragCoord = (IN.screenPos.xy / IN.screenPos.w) * _ScreenParams.xy;						//当前点在屏幕上的坐标(1280,720)
				float aspect = 1 / min(_ScreenParams.x, _ScreenParams.y);
				float2 p = (fragCoord.xy - float2(_PositionX, _PositionY)) * aspect;
				float a = length(p) - _Range * aspect;
				col .a -= smoothstep(0.1, -0.005, a);
				return col;
			}
			ENDCG
		}
	}

	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog{ Mode Off }
			Offset -1, -1
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse

			SetTexture[_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
