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
                    //_FocusScreenPosition ��Χ��(-width/2,-height/2) ��( width/2, height/2) ����0,0���任����Ļ����Ϊ��_ScreenParams.xy / 2��
                    float2 focusPos = _FocusScreenPosition + _ScreenParams.xy / 2;
                    float2 uv = i.uv;
                    //������Ļ�������UV
                    float2 focusPosUV = (focusPos / _ScreenParams.xy);
                    //�������ص�������Ľ����UV������ĵ��ϵ������
                    uv = uv - focusPosUV;
                    float4 outColor = float4(0, 0, 0, 1);
                    //���ģ��
                    for (int i = 0; i < _FocusDetail; i++) {
                        //����ģ����ǿ�ȣ�Ҳ����UV��ƫ��ǿ��
                        float power = 1.0 - _FocusPower/1000 * float(i);
                        //�����ĵ��ϵ������
                        outColor.rgb += tex2D(_MainTex , uv * power + focusPosUV).rgb;
                    }
                    outColor.rgb *= 1.0 / float(_FocusDetail);
                    return outColor;
                }
            ENDCG
        }
    }
}
