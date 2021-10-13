// see README here: 
// github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader

Shader "Universal Render Pipeline/Dejavu/DepthScanLine"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        //_ScanTex("Base (RGB)", 2D) = "white" {}
        [HDR]_ScanLineColor("_ScanLineColor (default = 1,1,1,1)", color) = (1,1,1,1)
        _ScanValue("ScanValue", float) = 0
        _ScanLineWidth("ScanLineWidth", float) = 1
        _ScanLightStrength("ScanLightStrength", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha

    }


        HLSLINCLUDE
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
       // float4 _MainTex_ST;
      //  float4 _ScanTex_ST;
        half4 _ScanLineColor;
        float _ScanValue;
        float _ScanLineWidth;
        float _ScanLightStrength;
        float _DistortFactor;
        CBUFFER_END

        //TEXTURE2D(_MainTex);
        //SAMPLER(sampler_MainTex);
        sampler2D _MainTex;
      //  sampler2D _ScanTex;
        sampler2D _CameraDepthTexture;


        struct appdata {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 screenPos : TEXCOORD1;
            UNITY_VERTEX_OUTPUT_STEREO
        };


        //vertex shader
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
            // prepare depth texture's screen space UV
            o.screenPos = ComputeScreenPos(o.positionCS);
            o.uv = v.uv;
            return o;
        }

        //fragment shader
        float4 frag(v2f i) : SV_Target
        {
            //float  sceneRawDepth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
            //float sceneDepthVS2 = Linear01Depth(sceneRawDepth2, _ZBufferParams);

             //float sceneRawDepth = tex2D(_CameraDepthTexture, i.uv).r;
            // float sceneDepth = Linear01Depth(sceneRawDepth, _ZBufferParams);
             //float sceneDepthVS2 = LinearEyeDepth(sceneRawDepth2, _ZBufferParams);
             float2 dir = i.uv - float2(0.5, 0.5);
             //float2 offset = _DistortFactor * normalize(dir) * (1 - length(dir));
             //float2 uv = i.uv - offset * sceneDepthVS2;
            // float2 uv = i.uv - normalize(dir) * (1 - length(dir));
             float2 offset = _DistortFactor * dir * (1 - length(dir));
             //float2 uv = i.uv - offset * sceneDepthVS2;
             float2 uv = i.uv - offset;

             float sceneRawDepth2 = tex2D(_CameraDepthTexture, uv).r;
             float sceneDepth2 = Linear01Depth(sceneRawDepth2, _ZBufferParams);


             float4 screenCol = tex2D(_MainTex, uv);
             //screenCol = half4( 100*sceneDepthVS2,0,0,1);
             if (sceneDepth2 * 20 > _ScanValue && sceneDepth2 * 20 < _ScanValue + _ScanLineWidth)
             {
                 return screenCol * _ScanLightStrength * _ScanLineColor;
             }
             return screenCol;
        }



        ENDHLSL
        //开始SubShader
        SubShader
        {

                //Tags {"RenderType" = "Opaque"  "RenderPipeline" = "UniversalPipeline"}
                Tags { "RenderPipeline" = "UniversalPipeline"  "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
                LOD 100
                ZTest Always Cull Off ZWrite Off
                Blend one OneMinusSrcAlpha
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
