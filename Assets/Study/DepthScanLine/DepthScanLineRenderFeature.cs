using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DepthScanLineRenderFeature : ScriptableRendererFeature
{
    DepthScanLinePass pass;

    public override void Create()
    {
        pass = new DepthScanLinePass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

public class DepthScanLinePass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "Render DepthScanLine Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget2");
    static readonly int ScanLineColorId = Shader.PropertyToID("_ScanLineColor");
    static readonly int ScanLineWidthId = Shader.PropertyToID("_ScanLineWidth");
    static readonly int ScanLightStrengthId = Shader.PropertyToID("_ScanLightStrength");
    static readonly int ScanValueId = Shader.PropertyToID("_ScanValue");
    static readonly int DistortFactorId = Shader.PropertyToID("_DistortFactor");
    static float scanValue = 0.5f;

    DepthScanLineVolume depthScanLineVolume;
    Material material;
    RenderTargetIdentifier currentTarget;

    public DepthScanLinePass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("Universal Render Pipeline/Dejavu/DepthScanLine");
        if (shader == null)
        {
            Debug.LogError("Shader not found.");
            return;
        }
        material = CoreUtils.CreateEngineMaterial(shader);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (material == null)
        {
            Debug.LogError("Material not created.");
            return;
        }

        if (!renderingData.cameraData.postProcessEnabled) return;

        var stack = VolumeManager.instance.stack;
        depthScanLineVolume = stack.GetComponent<DepthScanLineVolume>();
        if (depthScanLineVolume == null) { return; }
        if (!depthScanLineVolume.IsActive()) { return; }
        var cmd = CommandBufferPool.Get(k_RenderTag);
        Render(cmd, ref renderingData);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public void Setup(in RenderTargetIdentifier currentTarget)
    {
        this.currentTarget = currentTarget;
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;
        var source = currentTarget;
        int destination = TempTargetId;

        var w = cameraData.camera.scaledPixelWidth;
        var h = cameraData.camera.scaledPixelHeight;
        material.SetFloat(ScanLightStrengthId, depthScanLineVolume.ScanLightStrength.value);
        material.SetFloat(ScanLineWidthId, depthScanLineVolume.ScanLineWidth.value);
        material.SetVector(ScanLineColorId, depthScanLineVolume.ScanLineColor.value);

        scanValue += 0.01f * depthScanLineVolume.ScanSpeed.value;
        //限制一下最大值，最小值
        //scanValue = Mathf.Min(0.95f, 1 - scanValue);
        if (scanValue > 1.0f)
            scanValue = 0.5f;
        //Debug.Log("scanValue:" + scanValue);
        material.SetFloat(DistortFactorId, depthScanLineVolume.DistortFactor.value * scanValue);
        material.SetFloat(ScanValueId, 1 - scanValue);
        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, material, shaderPass);
    }
}