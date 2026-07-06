Shader "Unlit/Shader3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}          
        _Albedo ("Albedo", Color) = (1,0,0,1)          
        _AlbedoStrength ("Albedo Strength", Float) = 1  

        _AmbientColor ("Ambient Color", Color) = (0.1,0.1,0.15,1) 
                                                                     

        _LightColor ("Light Color", Color) = (1,1,1,1)         
        _LightColorStrength ("Light Color Strength", Float) = 1 

        _RimLightColor ("Rim Light Color", Color) = (0.6,0.85,1,1) 
        _RimLightStrenght ("Rim Light Strength", Float) = 3         

        _Transperency ("Transperency", Float) = 0.8
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;   
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;     
            };

           
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION; 
                float3 normal : TEXCOORD3;   
                float4 worldPos : TEXCOORD2; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Albedo;
            float _AlbedoStrength;
            float4 _AmbientColor;
            float4 _LightColor;
            float _LightColorStrength;
            float4 _RimLightColor;
            float _RimLightStrenght;
            float _Transperency;

            v2f vert (appdata v)
            {
                v2f o;

                //vertex from object to clip space
                o.vertex = UnityObjectToClipPos(v.vertex);

                //normal from object to world space.
                o.normal = UnityObjectToWorldNormal(v.normal);

                // Object to world space position.
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //calculaitons
                float3 normal = normalize(i.normal); 
                float3 toCameraVector = normalize(_WorldSpaceCameraPos - i.worldPos.xyz); //camera to surface vector
                float diffuseLight = saturate(dot(normal, normalize(_WorldSpaceLightPos0.xyz))); //diffuse lighting
                float NdotV = saturate(dot(normal, toCameraVector)); //grazing angle strength
                float rimLight = pow(1 - NdotV, _RimLightStrenght); //inverse so that edges glow and apply fallof
                float3 ambient = _Albedo.rgb * _AmbientColor.rgb;

                //combining
                float3 diffuse = _Albedo.rgb * _AlbedoStrength * diffuseLight * _LightColor.rgb * _LightColorStrength; //albedo and diffuse light
                float3 rim = rimLight * _RimLightColor.rgb; // rim lighting

                //finalized pizel
                float3 finalColor = ambient + diffuse + rim;
                return fixed4(finalColor, _Transperency);
            }
            ENDCG
        }
    }
}