
//打印在世界空间位置
Shader "Universal Render Pipeline/Dejavu/HexMap/VertexColors"
{	
	Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        //[HDR]_Color("Color (default = 1,1,1,1)", Color) = (1,1,1,1)
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
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			//half4 _Color;
			CBUFFER_END
			ENDHLSL
			HLSLPROGRAM
			sampler2D _MainTex;
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = TransformObjectToHClip(v.vertex);
				o.uv = v.uv;
				o.color = v.color;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				half4  col = tex2D(_MainTex, i.uv);
				col *= i.color;// tint color
				return col;
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