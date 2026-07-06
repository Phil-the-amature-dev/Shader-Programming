Shader "Unlit/PatternShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Direction("Direction", Vector) = (0,0,0,0) // x = outer radius, y = inner radius, z = intensity multiplier, w = unused
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            Name "PatternShader"
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            
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

            float4      _Color;
            float4 _Direction;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 center = float2(0.5, 0.5); 
                float4 color = float4(0,0,0,1) * _Color;
                float pi = 3.14159265f;

              
                // distance from current pixel to offset from center
                float borderWidth = length(uv - float2(_Direction.x - 0.5,_Direction.y - 0.5));
                float innerCenter = borderWidth/2;

               
                float lengthToCenter = uv - innerCenter;
                
                

               
                
                if (length(uv - center) < _Direction.x && length(uv - center) > _Direction.y)
                {
                    
                    color = float4(abs(lengthToCenter) * _Direction.z * (length(uv - center)) * uv.x,0,abs(lengthToCenter) * _Direction.z * (length(uv - center)) * uv.y,1);
                }
				return color;
            }
            ENDCG
        }
    }
}