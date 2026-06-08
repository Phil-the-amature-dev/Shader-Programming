Shader "Unlit/Shader1"
{
    Properties
    {
        _HeightMap ("Height Map", 2D) = "white" {}
        _WaveLength ("Wave Length", Float) = 0.1 
        _ColorA ("Color A", Color) = (1,0,0,1)
        _ColorB ("Color B", Color)  = (0,0,1,1)
        _GlobalIllumination ("Global Illumination", Color)  = (1,1,1,1)
        _CustomLightColor ("Light Color", Color)  = (1,0,1,1)
        _SpecularLight ("SpecularLight", Color)  = (1,0,1,1)
        _TextureBreathingStrength ("Texture Breathing Strength", Float) = 1
        _TextureWaveStrength ("Texture Wave Strength", Float) = 1
        _TextureWaveSpeed ("Texture Wave Speed", Float) = 1
        _VectorDisplacementModifier ("Vector Displacement Modifier", Float) = 1
        _Transparency ("Transparency", Float) = 1
        _GlobalIlluminationStrength ("Global Illumination Strength", Float) = 0.05
        _LightColorStrength ("Light Color Strength", Float) = 0.05
        _SpecularLightStrength ("Specular Light Strength", Float) = 0.1
        _MaterialSmoothness ("Material Smoothnes", Float) = 0.1
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
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 normal : TEXCOORD3;
                float4 worldPos : TEXCOORD2;
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
                o.normal = normalize(mul(v.normal, UNITY_MATRIX_M)); // calculate world space normal
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                brightness = tex2Dlod(_HeightMap, float4(uvDisplacement,0,1));
                o.vertex.y += brightness.x * _VectorDisplacementModifier;
                o.uv = TRANSFORM_TEX(v.uv, _HeightMap);

                return o;
            }

            float _WaveLength;
            float4 _ColorA;
            float4 _ColorB;
            float4 _CustomLightColor;
            float4 _GlobalIllumination;
            float4 _SpecularLight;
            float _GlobalIlluminationStrength;
            float _TextureBreathingStrength;
            float _TextureWaveStrength;
            float _Transparency;
            float _SpecularLightStrength;
            float _LightColorStrength;
            float _MaterialSmoothness;
            fixed4 frag (v2f i) : SV_Target
            
            {
                
                
                //WAVE PATTERN
                fixed4 returnColor = float4(0,0,0,1);
                float diffuseLight;
                float3 toCameraVector;
                float reflectionStrength;
                
                diffuseLight = saturate(dot((i.normal),normalize(_WorldSpaceLightPos0)));
                
                
                toCameraVector = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);;
                reflectionStrength = saturate(pow(dot(toCameraVector, normalize(_WorldSpaceLightPos0)), _MaterialSmoothness));
                
                
                float slant = float(fmod(((i.uv.x + i.uv.y) + (sin(_Time.y) * _TextureWaveStrength)),_WaveLength)); // the higher, the more to the right

                returnColor += float4(lerp(_ColorA,_ColorB,slant * sin(_Time.y) * _TextureBreathingStrength)); // Albedo
                returnColor += (diffuseLight * _CustomLightColor * _LightColorStrength); // light
                returnColor += _GlobalIllumination * _GlobalIlluminationStrength; // global illumination
                returnColor += saturate((_SpecularLight * reflectionStrength * diffuseLight * _SpecularLightStrength)); //Specular light

                returnColor.w = _Transparency;
                                
                
                return saturate(returnColor);
            }
            ENDCG
        }
    }
}
