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

            // Input from the mesh (per-vertex data)
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Data passed from vertex shader to fragment shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4      _Color;
            float4 _Direction;

            // Vertex shader: transforms vertex position to clip space, passes UVs through unchanged
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.uv;
                float2 center = float2(0.5, 0.5); // center of the quad in UV space
                float4 color = float4(0,0,0,1) * _Color; // default fallback color = black, used outside the ring
                float pi = 3.14159265f;

                // 0.5, 0.5 to innerBorder,uv.y
                // distance from current pixel to a point offset by (_Direction.x, _Direction.y) from center
                float borderWidth = length(uv - float2(_Direction.x - 0.5,_Direction.y - 0.5));
                float innerCenter = borderWidth/2;

                // NOTE: uv is a float2 and innerCenter is a float, so this subtracts
                // innerCenter from both components (broadcast), producing a float2,
                // then implicitly truncates to just the .x component when assigned here.
                float lengthToCenter = uv - innerCenter;
                
                // if (lengthToCenter < 0)
                // {
                //     lengthToCenter *= -1;
                // }

                // Ring mask: only color pixels whose distance from center falls between
                // the inner radius (_Direction.y) and outer radius (_Direction.x)
                if (length(uv - center) < _Direction.x && length(uv - center) > _Direction.y)
                {
                    // Red and blue channels scaled by distance-based falloff (lengthToCenter),
                    // distance from center, an intensity multiplier (_Direction.z), and raw UV position.
                    // This creates the directional/uneven glow inside the ring.
                    color = float4(abs(lengthToCenter) * _Direction.z * (length(uv - center)) * uv.x,0,abs(lengthToCenter) * _Direction.z * (length(uv - center)) * uv.y,1);
                }
				return color;
            }
            ENDCG
        }
    }
}