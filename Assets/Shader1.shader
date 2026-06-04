Shader "Unlit/Shader1"
{
    Properties
    {
        _HeightMap ("Height Map", 2D) = "white" {}
        _WaveLength ("Wave Length", Float) = 0.1 
        _ColorA ("Color A", Color) = (1,0,0,1)
        _ColorB ("Color B", Color)  = (0,0,1,1)
        _TextureBreathingStrength ("Texture Breathing Strength", Float) = 1
        _TextureWaveStrength ("Texture Wave Strength", Float) = 1
        _TextureWaveSpeed ("Texture Wave Speed", Float) = 1
        _VectorDisplacementModifier ("Vector Displacement Modifier", Float) = 1
        _Transparency ("Transparency", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _HeightMap;
            float4 _HeightMap_ST;
            float _VectorDisplacementModifier;
            float _TextureWaveSpeed;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); 
                float4 brightness;
                float2 uvDisplacement = v.uv + float2(_Time.y * _TextureWaveSpeed,0);
                
                brightness = tex2Dlod(_HeightMap, float4(uvDisplacement,0,1));
                o.vertex.y += brightness.x * _VectorDisplacementModifier;
                o.uv = TRANSFORM_TEX(v.uv, _HeightMap);

                return o;
            }

            float _WaveLength;
            float4 _ColorA;
            float4 _ColorB;
            float _TextureBreathingStrength;
            float _TextureWaveStrength;
            float _Transparency;
            fixed4 frag (v2f i) : SV_Target
            
            {
                
                
                //WAVE PATTERN
                fixed4 returnColor = float4(0,0,0,1);
                float slant = float(fmod(((i.uv.x + i.uv.y) + (sin(_Time.y) * _TextureWaveStrength)),_WaveLength)); // the higher, the more to the right

                returnColor += float4(lerp(_ColorA,_ColorB,slant * sin(_Time.y) * _TextureBreathingStrength));
                returnColor.w = _Transparency;
                                
                
                return returnColor;
            }
            ENDCG
        }
    }
}
