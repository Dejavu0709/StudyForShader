
Shader "Universal Render Pipeline/Dejavu/HeightFog"
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
        half4 _FogColor;
        float  _FogStartHeight;
        float _FogHeight;
        float _FogIntensity;
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
        
        float sceneRawDepth = 1;
 #if defined(UNITY_REVERSED_Z)
        sceneRawDepth = 1 - sceneRawDepth;
#endif
        float3 worldPos = ComputeWorldSpacePosition(v.uv, sceneRawDepth, UNITY_MATRIX_I_VP);
        o.viewRayWorld = worldPos - _WorldSpaceCameraPos.xyz;
        o.uv = v.uv;
        return o;
    }

    //fragment shader
    float4 frag(v2f i) : SV_Target
    {
        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
        float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
        float3 worldPos = _WorldSpaceCameraPos.xyz + ( linear01Depth) * i.viewRayWorld;
        float blendParam  = saturate((_FogStartHeight - worldPos.y) / _FogHeight);
        blendParam = max(linear01Depth * _FogHeight, blendParam);
        half4 screenCol =  tex2D(_MainTex,  i.uv);
        return lerp(screenCol, _FogColor, blendParam * _FogIntensity);

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
             Name "HeightFog"
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
