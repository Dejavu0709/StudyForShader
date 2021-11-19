
//打印在世界空间位置
Shader "Universal Render Pipeline/Dejavu/ProjectorShadow/ShadowCaster"
{
	SubShader
	{
		Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
		LOD 300
		ZWrite[_ZWrite]
		Cull Off ZWrite On
		Pass
		{
			Name "ProjectorShadowCaster"
			HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		    ENDHLSL
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 srcPos : TEXCOORD0;

			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = TransformObjectToHClip(v.vertex);
				o.srcPos = ComputeScreenPos(o.vertex);
				o.srcPos = o.vertex;
				o.srcPos.xy = o.srcPos.xy / o.srcPos.w;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				//return 0.5;

				float4 col = i.srcPos;
				//return col;
				//col.xy = col.xy / col.w;
				return float4(col.xy, 0, 0);
				return 1;
			}
				ENDHLSL
		}

		

	}
}