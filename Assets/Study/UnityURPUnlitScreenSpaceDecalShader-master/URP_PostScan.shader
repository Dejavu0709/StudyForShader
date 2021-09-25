// see README here: 
// github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader

Shader "Universal Render Pipeline/Dejavu/PostScan"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _ScanTex("Base (RGB)", 2D) = "white" {}
          [HDR]_Color("_Color (default = 1,1,1,1)", color) = (1,1,1,1)
                      [Header(Blending)]
          // https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
          [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
          [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha

       _Period("Move Period", float) = 1
       _DepthAffect("Depth Affect", float) = 0.125
    }


        HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _ScanTex_ST;
        half4 _Color;
        float _Period;
        float _DepthAffect;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        sampler2D _ScanTex;
        sampler2D _CameraDepthTexture;
     //   TEXTURE2D(_ScanTex);
      //  SAMPLER(sampler_ScanTex);


        struct appdata {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 viewRay : TEXCOORD1; // xyz: viewRayOS, w: extra copy of positionVS.z 
            float4 screenPos : TEXCOORD2;
            float4 cameraPosOSAndFogFactor : TEXCOORD3;
            UNITY_VERTEX_OUTPUT_STEREO
        };


        //vertex shader
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
            o.uv = v.uv;
            // prepare depth texture's screen space UV
            o.screenPos = ComputeScreenPos(o.positionCS);
            // NDC position
            float4 ndcPos = (o.screenPos / o.screenPos.w) * 2 - 1;

            // Camera parameter
            float far = _ProjectionParams.z;

            // View space vector pointing to the far plane
            float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
            o.viewRay = mul(unity_CameraInvProjection, clipVec.xyzz).xyzw;
            return o;
        }

        //fragment shader
        float4 frag(v2f i) : SV_Target
        {
            
             float2 screenSpaceUV2 = i.screenPos.xy / i.screenPos.w;
             float sceneRawDepth2 = tex2D(_CameraDepthTexture, screenSpaceUV2).r;
             float sceneDepthVS2 = LinearEyeDepth(sceneRawDepth2, _ZBufferParams);
            //  float sceneDepthVS2 = Linear01Depth(sceneRawDepth2, _ZBufferParams);
            // return float4(sceneDepthVS2, 0, 0, 1);

             // [important note]
             //========================================================================
             // now do "viewRay z division" that we skipped in vertex shader earlier.
             //i.viewRay.xyz /= i.viewRay.w;
            //========================================================================

             float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
             float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;

             float3 decalSpaceScenePos;


             // if perspective camera, LinearEyeDepth will handle everything for user
             // remember we can't use LinearEyeDepth for orthographic camera!
             float sceneDepthVS = LinearEyeDepth(sceneRawDepth,_ZBufferParams);
             //float sceneDepthVS = Linear01Depth(sceneRawDepth, _ZBufferParams);
             // scene depth in any space = rayStartPos + rayDir * rayLength
             // here all data in ObjectSpace(OS) or DecalSpace
             // be careful, viewRayOS is not a unit vector, so don't normalize it, it is a direction vector which view space z's length is 1
             decalSpaceScenePos = i.viewRay.xyz * sceneDepthVS;


             float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;

             float2 uv = decalSpaceUV.xy * _MainTex_ST.xy + _MainTex_ST.zw;//Texture tiling & offset

             half4 col = tex2D(_ScanTex, uv);
             col *= _Color;// tint color
             uv = (normalize(i.viewRay).xyzw * sceneDepthVS).xy;
             uv = i.uv + uv * _DepthAffect;
             uv = uv * _ScanTex_ST.xy + _ScanTex_ST.zw;
             float offset = fmod(_Time.y, _Period) / _Period;
             float2 center = float2(0.5, 0.5);
             uv -= center;
             uv = uv - offset*uv;
             uv += center;
             col = tex2D(_ScanTex, uv);
             return col;
        }


        ENDHLSL
        //开始SubShader
        SubShader
        {
                //Tags {"RenderType" = "Opaque"  "RenderPipeline" = "UniversalPipeline"}
                Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
                LOD 100
               ZTest Always Cull Off ZWrite Off
                Blend[_SrcBlend][_DstBlend]
                Pass
                {
                     Name "Scan"
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
