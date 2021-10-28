

Shader "Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/ReconstructPositionByRay"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        [HDR]_ScanLineColor("_ScanLineColor (default = 1,1,1,1)", color) = (1,1,1,1)
    }


    HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4x4 _InverseVPMatrix;
        float4x4 _InverseVMatrix;
        float4x4 _InversePMatrix;
        half4 _ScanLineColor;
        CBUFFER_END

        //TEXTURE2D(_MainTex);
        //SAMPLER(sampler_MainTex);
        sampler2D _MainTex;
        TEXTURE2D(_CameraDepthTexture);
        SAMPLER(sampler_CameraDepthTexture);



    struct appdata {
        float4 positionOS : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 viewRayWorld : TEXCOORD1;
        UNITY_VERTEX_OUTPUT_STEREO
    };


    //vertex shader
    v2f vert(appdata v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

        //方法1
        /*
        float sceneRawDepth = 1;
 #if defined(UNITY_REVERSED_Z)
        sceneRawDepth = 1 - sceneRawDepth;
#endif
        float3 worldPos = ComputeWorldSpacePosition(v.uv, sceneRawDepth, UNITY_MATRIX_I_VP);
        o.viewRayWorld = worldPos - _WorldSpaceCameraPos.xyz;
        */
     
        //方法2
        /*
        float4 clipPos =  ComputeClipSpacePosition(v.uv, 0);
        float4 viewPos = mul(UNITY_MATRIX_I_P, clipPos);
        viewPos.xyz = viewPos.xyz / viewPos.w;
        float3 worldPos = mul(_InverseVMatrix, viewPos).xyz;
        o.viewRayWorld = worldPos - _WorldSpaceCameraPos.xyz;
        */

        //方法3 
        float4 clipPos =  ComputeClipSpacePosition(v.uv, 0);
        float4 viewPos = mul(UNITY_MATRIX_I_P, clipPos);
        float3 viewRay = viewPos.xyz / viewPos.w;
        o.viewRayWorld = mul((float3x3)_InverseVMatrix, viewRay);
        o.uv = v.uv;
        return o;
    }

    //fragment shader
    float4 frag(v2f i) : SV_Target
    {
        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
        float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
        float3 worldPos = _WorldSpaceCameraPos.xyz + ( linear01Depth) * i.viewRayWorld ;
        return float4(worldPos, 1);
    }
    ENDHLSL

     //开始SubShader
    SubShader
    {

        //Tags {"RenderType" = "Opaque"  "RenderPipeline" = "UniversalPipeline"}
        Tags{ "RenderPipeline" = "UniversalPipeline"  "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
            LOD 100
            ZTest Always Cull Off ZWrite Off
            Blend one zero
            Pass
        {
             Name "ReconstructPositionByRay"
             //后处理效果一般都是这几个状态

             //使用上面定义的vertex和fragment shader
             HLSLPROGRAM
              #pragma vertex vert
              #pragma fragment frag
             ENDHLSL
        }

    }
    //后处理效果一般不给fallback，如果不支持，不显示后处理即可
}
