

Shader "Universal Render Pipeline/Dejavu/MotionBlur"
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
        float4x4 _PreInverseVPMatrix;
        float _BlurStrength;
        float3 _BlurWeight;
        CBUFFER_END


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
            float3 viewRayWorldPre : TEXCOORD2;
            UNITY_VERTEX_OUTPUT_STEREO
        };


        //vertex shader
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

            float sceneRawDepth = 1;
            float4 ndc = float4(v.uv.x * 2 - 1, v.uv.y * 2 - 1, sceneRawDepth * 2 - 1, 1);
            float4 worldPos = mul(_InverseVPMatrix, ndc);
            worldPos /= worldPos.w;
            o.viewRayWorld = worldPos.xyz - _WorldSpaceCameraPos.xyz;

            worldPos = mul(_PreInverseVPMatrix, ndc);
            worldPos /= worldPos.w;
            o.viewRayWorldPre = worldPos.xyz - _WorldSpaceCameraPos.xyz;

            o.uv = v.uv;
            return o;
        }

        //fragment shader
        float4 frag(v2f i) : SV_Target
        {

            float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
            float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
            float3 worldPos = _WorldSpaceCameraPos.xyz + (linear01Depth)*i.viewRayWorld;

            float3 worldPosPre = _WorldSpaceCameraPos.xyz + (linear01Depth)*i.viewRayWorldPre;

            float2 velocity = (worldPos - worldPosPre).xy * _BlurStrength;
            float4 screenTex = tex2D(_MainTex, i.uv);
            screenTex += tex2D(_MainTex, i.uv + velocity * 1.0) * _BlurWeight.x;
            screenTex += tex2D(_MainTex, i.uv + velocity * 2.0) * _BlurWeight.y;
            screenTex += tex2D(_MainTex, i.uv + velocity * 3.0) * _BlurWeight.z;
            screenTex /= (1.0 + _BlurWeight.x + _BlurWeight.y + _BlurWeight.z);
 
            return screenTex;
            
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
