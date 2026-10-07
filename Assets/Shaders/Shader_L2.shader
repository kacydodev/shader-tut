Shader "Custom/Shader_L2"
{
  Properties
  {
    [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
  }

  SubShader
  {
    Tags
    {
      "RenderType" = "Opaque"
      "RenderPipeline" = "UniversalPipeline"
      "Queue" = "Geometry"
    }

    Pass
    {
      HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            // Previously `struct appdata`
            struct Attributes
            {
              float4 vertex: POSITION;
              float2 uv: TEXCOORD0;
            };
            
            // Previously `struct v2f`
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END
            
            // vertex?
            Varyings vert(Attributes IN)
            {
              Varyings OUT;
              // OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
              OUT.positionHCS = TransformObjectToHClip(IN.vertex.xyz);
              OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
              return OUT;
            }
            
            // Fragment
            half4 frag(Varyings IN) : SV_Target
            {
              half4 color = half4(IN.uv.x, IN.uv.y, 0, 1);
              half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
              return color;
            }
            ENDHLSL
    }
  }
}