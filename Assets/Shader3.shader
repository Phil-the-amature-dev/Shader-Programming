Shader "Unlit/Shader3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}          // not sampled yet, just kept for later use
        _Albedo ("Albedo", Color) = (1,0,0,1)          // surface's base "reflectance" color
        _AlbedoStrength ("Albedo Strength", Float) = 1  // multiplier to tweak how strong the diffuse reflection is

        _AmbientColor ("Ambient Color", Color) = (0.1,0.1,0.15,1) // fake global illumination / indirect light
                                                                     // always added, regardless of light direction

        _LightColor ("Light Color", Color) = (1,1,1,1)         // color of the main directional light
        _LightColorStrength ("Light Color Strength", Float) = 1 // multiplier for diffuse light intensity

        _RimLightColor ("Rim Light Color", Color) = (0.6,0.85,1,1) // color of the glow at grazing angles (Fresnel effect)
        _RimLightStrenght ("Rim Light Strength", Float) = 3         // used as the pow() exponent -> controls how tight/sharp the rim is

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

            // input data coming from the mesh, per vertex
            struct appdata
            {
                float4 vertex : POSITION;   // object space position, w = 1 (this is a POINT, homogeneous coords)
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;     // object space direction, no w needed - normals are NOT points
            };

            // data passed from vertex shader to fragment shader (interpolated across the triangle)
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION; // clip space position, required output of vert()
                float3 normal : TEXCOORD3;   // world space normal, passed along for lighting calculations
                float4 worldPos : TEXCOORD2; // world space position, needed for both diffuse (light dir) and rim (view dir)
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

                // Object space -> clip space, using the combined Model/View/Projection matrix (UNITY_MATRIX_MVP under the hood)
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                // Transform the normal from object space to world space.
                //UnityObjectToWorldNormal works according to google
                o.normal = UnityObjectToWorldNormal(v.normal);

                // Object space -> world space position.
                // matrix * vector (not vector * matrix!) - order matters for correct transformation.
                // v.vertex has w=1 here, so translation is correctly applied (this is a point, not a direction).
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Renormalize: interpolating normals across a triangle can shrink their length slightly
                float3 normal = normalize(i.normal);

                // Vector from the surface point to the camera - needed for rim/specular-style calculations
                float3 toCameraVector = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);

                // --- Diffuse lighting ---
                // dot(normal, toLight) gives cos(angle) between the surface normal and the light direction.
                // This is exactly the "how much light hits the surface" derivation from the lecture:
                // full brightness when facing the light directly, fading to 0 at 90 degrees, negative (clamped to 0) when facing away.
                float diffuseLight = saturate(dot(normal, normalize(_WorldSpaceLightPos0.xyz)));

                // --- Rim / Fresnel lighting ---
                // dot(normal, toCamera) is high when the surface faces the camera directly (like the center of a sphere),
                // and low near the silhouette edges (grazing angles).
                float NdotV = saturate(dot(normal, toCameraVector));

                // We want the OPPOSITE - bright at the edges, dark facing the camera - so invert it with (1 - NdotV).
                // pow() sharpens the falloff, just like the cos(x)^n comparison from the "Smoothness" slide:
                // higher exponent = tighter, thinner rim; lower exponent = thicker glow creeping toward the center.
                float rimLight = pow(1 - NdotV, _RimLightStrenght);

                // --- Combine everything ---
                // Ambient: flat light that hits the surface regardless of angle (fakes global illumination/bounced light).
                // Without this, the side of the object facing away from the light would be pure black.
                float3 ambient = _Albedo.rgb * _AmbientColor.rgb;

                // Diffuse: albedo reflecting the direct light, scaled by how much light actually reaches this point.
                float3 diffuse = _Albedo.rgb * _AlbedoStrength * diffuseLight * _LightColor.rgb * _LightColorStrength;

                // Rim: extra glow added at grazing angles, independent of the main light direction.
                float3 rim = rimLight * _RimLightColor.rgb;

                float3 finalColor = ambient + diffuse + rim;

                return fixed4(finalColor, _Transperency);
            }
            ENDCG
        }
    }
}