
Shader "Universal Render Pipeline/Dejavu/WorldDepthScanCircle"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        //_ScanTex("Base (RGB)", 2D) = "white" {}
        [HDR]_ScanLineColor("_ScanLineColor (default = 1,1,1,1)", color) = (1,1,1,1)
        _ScanValue("ScanValue", float) = 0
        _ScanLineWidth("ScanLineWidth", float) = 1
        _ScanLightStrength("ScanLightStrength", float) = 1
    }


        HLSLINCLUDE
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
      //  float4 _ScanTex_ST;
        half4 _ScanLineColor;
        float _ScanValue;
        float _ScanLineWidth;
        float _ScanLightStrength;
        float _DistortFactor;
        float3 _Center;
        float _Radius;
        CBUFFER_END


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
            float4 screenPos : TEXCOORD1;
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
            // prepare depth texture's screen space UV
            o.screenPos = ComputeScreenPos(o.positionCS);
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
                float4 screenCol = tex2D(_MainTex, i.uv);
                float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);
                float linear01Depth = Linear01Depth(sceneRawDepth, _ZBufferParams);
                float3 worldPos = _WorldSpaceCameraPos.xyz + (linear01Depth)*i.viewRayWorld;
                float3 distVector = worldPos - _Center;
                float distance = sqrt(distVector.x* distVector.x + distVector.z*distVector.z);

                 if (distance > _Radius * _ScanValue && distance < _Radius * _ScanValue + _ScanLineWidth)
                 {
                     return screenCol * _ScanLightStrength * _ScanLineColor;
                 }
                 //return float4(distance, distance, distance,1);

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
