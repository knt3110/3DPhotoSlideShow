Shader "Custom/BlackEdge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineWidth ("Outline Width", float) = 0.1
        _OutlineColor ("Oitline Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha 
        Cull Off

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 縁の内側の写真を動かす
                fixed4 col = tex2D(_MainTex, i.uv + float2(_Time.x, _Time.x) * 0.15);
                
                // 内側のジャギーを解消
                if (i.uv.y < 0.13 || i.uv.y > 1 - 0.13)
                {
                    col = _OutlineColor * (abs(i.uv.y - 0.5) - 0.37) / 0.01 + col * (0.01 - (abs(i.uv.y - 0.5) - 0.37)) / 0.01;
                }

                // 縁をつける
                if (i.uv.x < 0.08 || i.uv.x > 1 - 0.08 || i.uv.y < 0.12 || i.uv.y > 1 - 0.12)
                {
                    col = _OutlineColor;
                }
                
                // 外側のジャギーを解消
                if (i.uv.y < 0.1 || i.uv.y > 1 - 0.1)
                {
                    float alpha = (0.01 - (abs(i.uv.y - 0.5) - 0.4)) / 0.01;
                    col.a = alpha;
                }

                // 縁の内側で写真を動かす余裕を持たせるために外側を少しカリング
                if (i.uv.x < 0.06 || i.uv.x > 1 - 0.06 || i.uv.y < 0.09 || i.uv.y > 1 - 0.09)
                {
                    clip(-1);
                }
                
                return col;
            }
            ENDCG
        }
    }
}
