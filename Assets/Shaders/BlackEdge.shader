Shader "Custom/BlackEdge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineThresholdX ("Outline Threshold X", float) = 0.072
        _OutlineThresholdY ("Outline Threshold Y", float) = 0.108
        _CullingThresholdX ("Culling Threshold X", float) = 0.06
        _CullingThresholdY ("Culling Threshold Y", float) = 0.09
        _AntiAliasingWidth ("Anti-Aliasing Width", float) = 0.01
        _OutlineColor ("Oitline Color", Color) = (0.1, 0.1, 0.1, 1)
        
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
            float _OutlineThresholdX;
            float _OutlineThresholdY;
            float _CullingThresholdX;
            float _CullingThresholdY;
            float _AntiAliasingWidth;
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
                fixed4 col = tex2D(_MainTex, i.uv + float2(sin(_Time.x * 3.14 * 4), sin(_Time.x * 3.14 * 4)) * 0.05);
                
                // 内側のジャギーを解消
                float innerAntiAliasingThreshold = _OutlineThresholdY + _AntiAliasingWidth;
                if (i.uv.y < innerAntiAliasingThreshold || i.uv.y > 1 - innerAntiAliasingThreshold)
                {
                    col = _OutlineColor * (abs(i.uv.y - 0.5) - (0.5 - innerAntiAliasingThreshold)) / _AntiAliasingWidth + col * (_AntiAliasingWidth - (abs(i.uv.y - 0.5) - (0.5 - innerAntiAliasingThreshold))) / _AntiAliasingWidth;
                }

                // 縁をつける
                if (i.uv.x < _OutlineThresholdX || i.uv.x > 1 - _OutlineThresholdX || i.uv.y < _OutlineThresholdY || i.uv.y > 1 - _OutlineThresholdY)
                {
                    col = _OutlineColor;
                }
                
                // 外側のジャギーを解消
                float outerAntiAliasingThreshold = _CullingThresholdY + _AntiAliasingWidth;
                if (i.uv.y < outerAntiAliasingThreshold || i.uv.y > 1 - outerAntiAliasingThreshold)
                {
                    float alpha = (_AntiAliasingWidth - (abs(i.uv.y - 0.5) - (0.5 - outerAntiAliasingThreshold))) / _AntiAliasingWidth;
                    col.a = alpha;
                }

                // 縁の内側で写真を動かす余裕を持たせるために外側を少しカリング
                if (i.uv.x < _CullingThresholdX || i.uv.x > 1 - _CullingThresholdX || i.uv.y < _CullingThresholdY || i.uv.y > 1 - _CullingThresholdY)
                {
                    clip(-1);
                }
                
                return col;
            }
            ENDCG
        }
    }
}
