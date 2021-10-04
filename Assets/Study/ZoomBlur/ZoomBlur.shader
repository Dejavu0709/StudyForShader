Shader "PostEffect/ZoomBlur"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }

        SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Tags { "RenderPipeline" = "UniversalPipeline"}
        Pass
        {
            CGPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag

                sampler2D _MainTex;
                float2 _FocusScreenPosition;
                float _FocusPower;
                int _FocusDetail;
                int _ReferenceResolutionX;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                v2f Vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                float4 Frag(v2f i) : SV_Target
                {
                    //_FocusScreenPosition 范围是(-width/2,-height/2) 到( width/2, height/2) ，（0,0）变换到屏幕中心为（_ScreenParams.xy / 2）
                    float2 focusPos = _FocusScreenPosition + _ScreenParams.xy / 2;
                    float2 uv = i.uv;
                    //根据屏幕坐标计算UV
                    float2 focusPosUV = (focusPos / _ScreenParams.xy);
                    //计算像素点距离中心焦点的UV差，以中心点乘系数外扩
                    uv = uv - focusPosUV;
                    float4 outColor = float4(0, 0, 0, 1);
                    //多层模糊
                    for (int i = 0; i < _FocusDetail; i++) {
                        //计算模糊的强度，也就是UV的偏移强度
                        float power = 1.0 - _FocusPower/1000 * float(i);
                        //以中心点乘系数外扩
                        outColor.rgb += tex2D(_MainTex , uv * power + focusPosUV).rgb;
                    }
                    outColor.rgb *= 1.0 / float(_FocusDetail);
                    return outColor;
                }
            ENDCG
        }
    }
}
