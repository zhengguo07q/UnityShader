// ***************************************************************
// Copyright(c) Yeto
// FileName	: Yeto - Character - HideBody.shader
// Creator	: 
// Date		: 2017-6-2
// Comment	: ÒþÉí
// ***************************************************************


Shader "Yeto/Character/HideBody" 
{
    Properties 
	{
        _MainColor ("MainColor", Color) = (0.3411765,0.5803922,0.7372549,1)
        _FresnelExp ("node_3161", Range(0, 10)) = 2.965811
        _FresnelIntensity ("node_9530", Range(0, 1)) = 0.7606838
    }
    SubShader 
	{
        Tags {"IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent" }
        Pass 
		{
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _MainColor;
            uniform float _FresnelExp;
            uniform float _FresnelIntensity;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = 0.5;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float3 node_75 = ((pow(1.0-max(0,dot(normalDirection, viewDirection)),_FresnelExp)*_MainColor.rgb)*exp2(_FresnelIntensity));
                float3 specularColor = node_75;
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
////// Emissive:
                float3 emissive = node_75;
/// Final Color:
                float3 finalColor = specular + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
