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

    }


        HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _ScanTex_ST;
        half4 _Color;
        float _Period;
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






            /*
            VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(v.positionOS);
            o.positionCS = vertexPositionInput.positionCS;

            o.cameraPosOSAndFogFactor.a = 0;
            o.screenPos = ComputeScreenPos(o.positionCS);

            // get "camera to vertex" ray in View space
            float3 viewRay = vertexPositionInput.positionVS;

            // [important note]
            //=========================================================
            // "viewRay z division" must do in the fragment shader, not vertex shader! (due to rasteriazation varying interpolation's perspective correction)
            // We skip the "viewRay z division" in vertex shader for now, and store the division value into varying o.viewRayOS.w first, 
            // we will do the division later when we enter fragment shader
            // viewRay /= viewRay.z; //skip the "viewRay z division" in vertex shader for now
            o.viewRay.w = viewRay.z;//store the division value to varying o.viewRayOS.w
            //=========================================================

            // unity's camera space is right hand coord(negativeZ pointing into screen), we want positive z ray in fragment shader, so negate it
            viewRay *= -1;

            // it is ok to write very expensive code in decal's vertex shader, 
            // it is just a unity cube(4*6 vertices) per decal only, won't affect GPU performance at all.
            float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);

            // transform everything to object space(decal space) in vertex shader first, so we can skip all matrix mul() in fragment shader
            o.viewRay.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
            o.cameraPosOSAndFogFactor.xyz = mul(ViewToObjectMatrix, float4(0, 0, 0, 1)).xyz; // hard code 0 or 1 can enable many compiler optimization
            */
            return o;
        }

        //fragment shader
        float4 frag(v2f i) : SV_Target
        {
            /*

            
            // now do "viewRay z division" that we skipped in vertex shader earlier.
            //i.viewRay.xyz /= i.viewRay.w;
            //i.viewRay.xyz = normalize(i.viewRay.xyz);
            float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
          //  float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;
            float sceneRawDepth = tex2D(_CameraDepthTexture, i.uv).r;

            // Sample the depth texture to get the linear 01 depth
           // float sceneRawDepth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.screenPos));
            //depth = Linear01Depth(depth);

            // if perspective camera, LinearEyeDepth will handle everything for user
        // remember we can't use LinearEyeDepth for orthographic camera!
           // float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
            float sceneDepthVS = Linear01Depth(sceneRawDepth, _ZBufferParams);
            // scene depth in any space = rayStartPos + rayDir * rayLength
            // here all data in ObjectSpace(OS) or DecalSpace
            // be careful, viewRayOS is not a unit vector, so don't normalize it, it is a direction vector which view space z's length is 1
            float4 ViewPos;
            ViewPos.xyz = i.viewRay.xyz * sceneDepthVS;

            // Pixel world position
            float3 worldPos = mul(UNITY_MATRIX_I_V, float4(ViewPos.xyz, 1)).xyz;
            float4 clipPos =  TransformWorldToHClip(worldPos);



            //float3 ViewPos = normalize(i.viewRay.xyz) * sceneDepthVS;
            ViewPos = mul(UNITY_MATRIX_P, float4 (ViewPos.xyz, 1));
           // float3 decalSpaceScenePos = normalize(i.viewRay.xyz) * sceneDepthVS;
            float4  decalSpaceScenePos = ComputeScreenPos(clipPos);

            // convert unity cube's [-0.5,0.5] vertex pos range to [0,1] uv. Only works if you use a unity cube in mesh filter!
            float2 decalSpaceUV = decalSpaceScenePos.xy / decalSpaceScenePos.w;
          //  float2 decalSpaceUV = decalSpaceScenePos.xy  + 0.5;
            //half4 color = tex2D(_CameraDepthTexture, screenSpaceUV);
            //half4 color = tex2D(_ScanTex, screenSpaceUV);
            half4 color = tex2D(_ScanTex, decalSpaceUV);
            color.xyz = worldPos;
            */


                    float2 screenSpaceUV2 = i.screenPos.xy / i.screenPos.w;
              float sceneRawDepth2 = tex2D(_CameraDepthTexture, screenSpaceUV2).r;
             float sceneDepthVS2 = LinearEyeDepth(sceneRawDepth2, _ZBufferParams);
           //  float sceneDepthVS2 = Linear01Depth(sceneRawDepth2, _ZBufferParams);
            // return float4(sceneDepthVS2, 0, 0, 1);






            // [important note]
            //========================================================================
            // now do "viewRay z division" that we skipped in vertex shader earlier.
            i.viewRay.xyz /= i.viewRay.w;
        //========================================================================

        float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
        float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;

        float3 decalSpaceScenePos;


            // if perspective camera, LinearEyeDepth will handle everything for user
            // remember we can't use LinearEyeDepth for orthographic camera!
            float sceneDepthVS = LinearEyeDepth(sceneRawDepth,_ZBufferParams);

            // scene depth in any space = rayStartPos + rayDir * rayLength
            // here all data in ObjectSpace(OS) or DecalSpace
            // be careful, viewRayOS is not a unit vector, so don't normalize it, it is a direction vector which view space z's length is 1
            decalSpaceScenePos = i.cameraPosOSAndFogFactor.xyz + i.viewRay.xyz * sceneDepthVS;


        float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;

    
        float2 uv = decalSpaceUV.xy * _MainTex_ST.xy + _MainTex_ST.zw;//Texture tiling & offset

        half4 col = tex2D(_ScanTex, uv);
        col *= _Color;// tint color
        //col.a = saturate(col.a * _AlphaRemap.x + _AlphaRemap.y);// alpha remap MAD
        //col.rgb *= lerp(1, col.a, _MulAlphaToRGB);// extra multiply alpha to RGB
        uv = (normalize(i.viewRay).xyzw * sceneDepthVS).xy;
        uv = i.uv + uv / 8;
        uv = uv * _ScanTex_ST.xy + _ScanTex_ST.zw;
        float offset = fmod(_Time.y, _Period) / _Period;
        float2 center = float2(0.5, 0.5);
        uv -= center;
        uv = uv - offset*uv;
        //uv = uv * 10;
        uv += center;
        col = tex2D(_ScanTex, uv);
        //return float4(normalize(i.viewRay).xyzw * sceneDepthVS);
        return col;

            //half4 color = tex2D(_ScanTex, i.uv);
            //half4 color = half4(0,0,0,0);
           // color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
          //  color *= _Color;// tint color
        //    return color;
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
