//puppet_master
//https://blog.csdn.net/puppet_master  
//2018.6.10  
//打印对象在世界空间位置
Shader "Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/WorldPosPrint"
{
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.worldPos, 1.0);
			}
			ENDCG
		}
	}
		//fallback使之有shadow caster的pass
				FallBack "Legacy Shaders/Diffuse"
}