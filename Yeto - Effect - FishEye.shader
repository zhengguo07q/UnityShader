Shader "Yeto/Effect/FishEye"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Scale("Scale", Range(0, 1)) = 0.5
		_Intensity_x("Intensity x", Range(0, 1)) = 0.5
		_Intensity_y("Intensity y", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _Intensity_x;
			float _Intensity_y;
			float _Scale;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 coords = i.uv;
				coords = (coords - 0.5) * 2.0;

				half2 realCoordOffs;
				realCoordOffs.x = (1 - coords.y * coords.y) * _Intensity_y * coords.x;
				realCoordOffs.y = (1 - coords.x * coords.x) * _Intensity_x * coords.y;
				return tex2D(_MainTex, i.uv * _Scale - realCoordOffs);
			}
			ENDCG
		}
	}
}
