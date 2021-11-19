
//打印在世界空间位置
Shader "Universal Render Pipeline/Dejavu/ProjectorShadow/ShadowReceiver"
{
	Properties
	{
		ShadowTex("Base (RGB)", 2D) = "white" {}
		_BlurSize("Blur Size", Float) = 1.0
		[HDR]_FogColor("_FogColor (default = 1,1,1,1)", color) = (1,1,1,1)
	}



	SubShader
	{
		Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
		LOD 300
		ZWrite[_ZWrite]
		Cull Off ZWrite On
		Pass
		{
			Name "ForwardLit"
			Tags{"LightMode" = "UniversalForward"}
			HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


		    ENDHLSL
			HLSLPROGRAM
			CBUFFER_START(UnityPerMaterial)
			float4 ShadowTex_ST;
			float4x4 _ShadowVPMatrix;
			float _BlurSize;
			//half4 _FogColor;
			//float _FogStartHeight;
			//float _FogHeight;
			//float _FogIntensity;
			CBUFFER_END

			//TEXTURE2D(_MainTex);
			//SAMPLER(sampler_MainTex);
			sampler2D ShadowTex;
			float4 ShadowTex_TexelSize;

			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 shadowCilpPos : TEXCOORD1;
				float2 shadowUVs[12]: TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = TransformObjectToHClip(v.vertex);
				VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(v.vertex);
				o.shadowCilpPos = mul(_ShadowVPMatrix, float4(vertexPositionInput.positionWS, 1));
				//o.srcPos = o.vertex;
				o.shadowCilpPos.xy = o.shadowCilpPos.xy / o.shadowCilpPos.w;
				o.shadowCilpPos = o.shadowCilpPos * 0.5 + 0.5;
				float2 centerShadowUV = o.shadowCilpPos * 0.5 + 0.5;

				o.shadowUVs[0] = float2(-2, 2) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[1] = float2(-1, 2) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[2] = float2(0, 2) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[3] = float2(1, 2) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[4] = float2(2, 2) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[5] = float2(-2, 1) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[6] = float2(-1, 1) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[7] = float2(0, 1) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[8] = float2(1, 1) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[9] = float2(2, 1) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[10] = float2(-2, 0) * _BlurSize * ShadowTex_TexelSize.xy;
				o.shadowUVs[11] = float2(-1, 0) * _BlurSize * ShadowTex_TexelSize.xy;


				o.uv = v.uv;


				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				half4 col = 0.1621 * tex2D(ShadowTex, i.shadowCilpPos.xy);
				

				col += 0.0030 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[0].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[1].xy);
				col += 0.0219 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[2].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[3].xy);
				col += 0.0030 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[4].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[5].xy);
				col += 0.0596 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[6].xy);
				col += 0.0983 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[7].xy);
				col += 0.0596 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[8].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[9].xy);
				col += 0.0219 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[10].xy);
				col += 0.0983 * tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[11].xy);

				col += 0.0030 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[11].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[10].xy);
				col += 0.0219 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[9].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[8].xy);
				col += 0.0030 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[7].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[6].xy);
				col += 0.0596 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[5].xy);
				col += 0.0983 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[4].xy);
				col += 0.0596 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[3].xy);
				col += 0.0133 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[2].xy);
				col += 0.0219 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[1].xy);
				col += 0.0983 * tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[0].xy);


				/**
				for (int it = 0; it < 12; it++)
				{
					col += tex2D(ShadowTex, i.shadowCilpPos.xy + i.shadowUVs[it].xy);
				}
				for (int it = 0; it < 12; it++)
				{
					col += tex2D(ShadowTex, i.shadowCilpPos.xy - i.shadowUVs[it].xy);
				}
				*/
				return col;
				 //return  col/25;
			}
				ENDHLSL
		}

		

	}
}