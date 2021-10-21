

// see README here: 
// github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader

Shader "Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/ReconstructPositionByRay"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    //_ScanTex("Base (RGB)", 2D) = "white" {}
    [HDR]_ScanLineColor("_ScanLineColor (default = 1,1,1,1)", color) = (1,1,1,1)

    [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
    [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha

    }


        HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
       //  float4 _ScanTex_ST;
        float4x4 _InverseVPMatrix;
        float4x4 _InverseVMatrix;
        float4x4 _InversePMatrix;
        half4 _ScanLineColor;
        CBUFFER_END

        //TEXTURE2D(_MainTex);
        //SAMPLER(sampler_MainTex);
        sampler2D _MainTex;
    //  sampler2D _ScanTex;
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
        float3 viewRay : TEXCOORD1;
        float3 viewRayWorld : TEXCOORD2;
        UNITY_VERTEX_OUTPUT_STEREO
    };


    //vertex shader
    v2f vert(appdata v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.positionCS = TransformObjectToHClip(v.positionOS.xyz);


        
        float4 clipPos =  ComputeClipSpacePosition(v.uv, 0);
        float4 viewRay = mul(UNITY_MATRIX_I_P, clipPos);
        o.viewRay = viewRay;
        o.viewRay = viewRay.xyz / viewRay.w;
        o.viewRayWorld = mul(_InverseVMatrix, float4(o.viewRay, 1));
        o.viewRayWorld = o.viewRayWorld - _WorldSpaceCameraPos.xyz;
        
        o.viewRayWorld = mul((float3x3)_InverseVMatrix, o.viewRay);





        /*
        float sceneRawDepth = 1;
#if defined(UNITY_REVERSED_Z)
        sceneRawDepth = 1 - sceneRawDepth;
#endif
        float3 worldPos = ComputeWorldSpacePosition(v.uv, sceneRawDepth, UNITY_MATRIX_I_VP);
        o.viewRayWorld = worldPos - _WorldSpaceCameraPos.xyz;
        */

        o.uv = v.uv;
        return o;
    }

    //fragment shader
    float4 frag(v2f i) : SV_Target
    {
        //  return float4(i.uv,0, 1);
        /*
        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);

    #if defined(UNITY_REVERSED_Z)
        sceneRawDepth = 1 - sceneRawDepth;
    #endif
        float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, sceneRawDepth * 2 - 1, 1);

        float4 worldPos = mul(_InverseVPMatrix, ndc);
        worldPos /= worldPos.w;
        worldPos.z *= 1;
        return worldPos;
        */



        /*
        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
        float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, sceneRawDepth, 1);
        #if UNITY_UV_STARTS_AT_TOP
           ndc.y *= -1;
        #endif
        float4 worldPos = mul(UNITY_MATRIX_I_VP, ndc);
        worldPos /= worldPos.w;
        return worldPos;
        */

        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
    
        float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
        //float3 worldPos = _WorldSpaceCameraPos.xyz + linear01Depth * i.viewRay;
        //float3 worldPos = linear01Depth * i.viewRayWorld;
        //float3 worldPos = _WorldSpaceCameraPos.xyz + (linear01Depth) * i.viewRayWorld;
        //float3 worldPos = i.viewRay;
        float3 worldPos = _WorldSpaceCameraPos.xyz + ( linear01Depth) * i.viewRayWorld ;

       // float3 worldPos = i.viewRayWorld;
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
             Name "ScanLine"
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
