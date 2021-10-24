
//打印在世界空间位置
Shader "Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/WorldPosPrint"
{
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
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = TransformObjectToHClip(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return float4(i.worldPos, 1.0);
			}
				ENDHLSL
		}

		 Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

				// -------------------------------------
				// Material Keywords
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

				//--------------------------------------
				// GPU Instancing
				#pragma multi_compile_instancing
				#pragma multi_compile _ DOTS_INSTANCING_ON

				#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
				ENDHLSL
			}

	}
}