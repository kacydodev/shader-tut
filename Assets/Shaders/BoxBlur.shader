Shader "Custom/BoxBlur"
{
  Properties
  {
    [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
    BlurSize("Blur Size", Range(0, 10)) = 1
  }

  SubShader
  {
    Tags
    {
      "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
    }

    Pass
    {
      HLSLPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

      struct Attributes
      {
        float4 positionOS : POSITION;
        float2 uv : TEXCOORD0;
      };

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
        float4 _BaseMap_TexelSize;
        float _BlurSize;
      CBUFFER_END

      Varyings vert(Attributes IN)
      {
        Varyings OUT;
        OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
        OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
        return OUT;
      }

      half4 frag(Varyings IN) : SV_Target
      {
        half4 color = half4(0, 0, 0, 0);
        int samples = 0;
        for (int x = -1; x <= 1; x++)
        {
          for (int y = -1; y <= 1; y++)
          {
            float2 offset = float2(x, y) * _BaseMap_TexelSize.xy * _BlurSize;
            color += SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv + offset);
            samples++;
          }
        }

        color /= samples;
        color *= _BaseColor;

        return color;
      }
      ENDHLSL
    }
  }
}