
Shader "Universal Render Pipeline/Dejavu/ProjectorShadow/Blur"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    
        [HDR]_FogColor("_FogColor (default = 1,1,1,1)", color) = (1,1,1,1)
    }


        HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float _BlurSize;
        CBUFFER_END

        //TEXTURE2D(_MainTex);
        //SAMPLER(sampler_MainTex);
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;



    struct appdata {
        float4 positionOS : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 positionCS : SV_POSITION;
        half2 uv[5]: TEXCOORD0; 
        UNITY_VERTEX_OUTPUT_STEREO
    };


    ////vertex shader
    //v2f vert(appdata v)
    //{
    //    v2f o;
    //    UNITY_SETUP_INSTANCE_ID(v);
    //    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    //    o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
    //    o.uv = v.uv;
    //    return o;
    //}

    ////fragment shader
    //float4 frag(v2f i) : SV_Target
    //{
    //    //float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
    //    //float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
    //    //float3 worldPos = _WorldSpaceCameraPos.xyz + ( linear01Depth) * i.viewRayWorld;
    //    //float blendParam  = saturate((_FogStartHeight - worldPos.y) / _FogHeight);
    //    //blendParam = max(linear01Depth * _FogHeight, blendParam);

    //    //half4 screenCol =  tex2D(_MainTex,  i.uv);
    //    return float4(0.5,0.5,0.5,1);
    //    //return screenCol;

    //}

    v2f vertBlurVertical(appdata v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

        half2 uv = v.uv;

        o.uv[0] = uv;
        o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
        o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
        o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
        o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

        return o;
    }

    v2f vertBlurHorizontal(appdata v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

        half2 uv = v.uv;

        o.uv[0] = uv;
        o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
        o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
        o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
        o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

        return o;
    }

    float4 fragBlur(v2f i) : SV_Target
    {
        float weight[3] = { 0.4026, 0.2442, 0.0545 };

        float3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

        for (int it = 1; it < 3; it++) {
            sum += tex2D(_MainTex, i.uv[it * 2 - 1]).rgb * weight[it];
            sum += tex2D(_MainTex, i.uv[it * 2]).rgb * weight[it];
        }

        return float4(sum, 1.0);
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
                NAME "GAUSSIAN_BLUR_VERTICAL"

                HLSLPROGRAM

                #pragma vertex vertBlurVertical  
                #pragma fragment fragBlur

                ENDHLSL
            }

            Pass
            {
                NAME "GAUSSIAN_BLUR_HORIZONTAL"

                HLSLPROGRAM

                #pragma vertex vertBlurHorizontal  
                #pragma fragment fragBlur

                ENDHLSL
            }



    }
    //后处理效果一般不给fallback，如果不支持，不显示后处理即可
}
