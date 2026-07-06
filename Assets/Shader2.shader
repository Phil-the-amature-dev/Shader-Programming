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
                //sample neighbouring vertecies
                float2 uvDisplacement = v.uv + float2(_Time.y * _TextureWaveSpeed,0); // Time updated UV Coordinate
                float4 heightLeft = tex2Dlod(_HeightMap, float4(uvDisplacement.x-0.1,uvDisplacement.y,0,1));
                heightLeft.y *= _VectorDisplacementModifier;
                float3 vertexLeft = float3(-0.1,heightLeft.x,0); //left sample

                float4 heightRight = tex2Dlod(_HeightMap, float4(uvDisplacement.x+0.1,uvDisplacement.y,0,1));
                heightRight.y *= _VectorDisplacementModifier;
                float3 vertexRight = float3(0.1,heightRight.x,0); //right sample

                float4 heightUp = tex2Dlod(_HeightMap, float4(uvDisplacement.x,uvDisplacement.y+0.1,0,1));
                heightUp.y *= _VectorDisplacementModifier;
                float3 vertexUp = float3(0,heightUp.x,0.1); //up sample

                float4 heightDown = tex2Dlod(_HeightMap, float4(uvDisplacement.x,uvDisplacement.y-0.1,0,1));
                heightDown.y *= _VectorDisplacementModifier;
                float3 vertexDown = float3(0,heightDown.x,-0.1); //lower sample


                float3 xVertex = float3(vertexLeft - vertexRight);
                float3 yVertex = float3(vertexUp - vertexDown);
                
                float4 brightness;
                brightness = tex2Dlod(_HeightMap, float4(uvDisplacement,0,1));
                v.vertex.y += brightness.x * _VectorDisplacementModifier;
                o.vertex = UnityObjectToClipPos(v.vertex); 


                v.normal = float4(cross(xVertex,yVertex),v.normal.z ); // cross product of xVertex & yVertex
                o.normal = normalize(mul(UNITY_MATRIX_M, v.normal)); // calculate world space normal
                
                
               
                o.worldPos = mul(unity_ObjectToWorld, o.vertex); // vertex to world space 
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
                float4 normal = normalize(i.normal);
                
                diffuseLight = saturate(dot((normal),normalize(_WorldSpaceLightPos0)));
                
                
                toCameraVector = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
                float3 halfVector = normalize(normalize(_WorldSpaceLightPos0.xyz) + toCameraVector);
                reflectionStrength = saturate(pow(saturate(dot(normalize(normal.xyz), halfVector)), _MaterialSmoothness));
                
                
                float slant = float(fmod(((i.uv.x + i.uv.y) + (sin(_Time.y) * _TextureWaveStrength)),_WaveLength)); // the higher, the more to the right

                returnColor += float4(lerp(_ColorA,_ColorB,slant * sin(_Time.y) * _TextureBreathingStrength)); // Albedo
                returnColor += (diffuseLight * _CustomLightColor * _LightColorStrength); // light
                returnColor += _GlobalIllumination * _GlobalIlluminationStrength; // global illumination
                returnColor += saturate((_SpecularLight * reflectionStrength
                    * diffuseLight * _SpecularLightStrength)); //Specular light

                returnColor.w = _Transparency;
                                
                
                return saturate(returnColor);
                // return float4(i.normal.xyz,1);
            }
            ENDCG
        }
    }
}
