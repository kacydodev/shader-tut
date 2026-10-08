using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BoxBlurPostEffects : ScriptableRendererFeature
{
  [System.Serializable]
  public class Settings
  {
    public Material blurMaterial;
    public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
  }

  public Settings settings = new Settings();
  private BoxBlurPass _pass;

  public override void Create()
  {
    _pass = new BoxBlurPass(settings.blurMaterial)
    {
      renderPassEvent = settings.renderPassEvent
    };
  }

  public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
  {
    if (settings.blurMaterial == null) return;
    _pass.ConfigureInput(ScriptableRenderPassInput.Color);
    renderer.EnqueuePass(_pass);
  }

  class BoxBlurPass : ScriptableRenderPass
  {
    private readonly Material _material;
    private RTHandle _tempTexture;

    public BoxBlurPass(Material material) => _material = material;

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
      var desc = renderingData.cameraData.cameraTargetDescriptor;
      desc.depthBufferBits = 0;
      RenderingUtils.ReAllocateIfNeeded(ref _tempTexture, desc, name: "_BoxBlurTemp");
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
      if (_material == null) return;

      CommandBuffer cmd = CommandBufferPool.Get("BoxBlurPost");
      var cameraTarget = renderingData.cameraData.renderer.cameraColorTargetHandle;

      Blit(cmd, cameraTarget, _tempTexture, _material, 0);
      Blit(cmd, _tempTexture, cameraTarget);

      context.ExecuteCommandBuffer(cmd);
      CommandBufferPool.Release(cmd);
    }
  }
}