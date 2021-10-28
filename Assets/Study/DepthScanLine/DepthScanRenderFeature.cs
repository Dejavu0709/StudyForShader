using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DepthScanRenderFeature : ScriptableRendererFeature
{
    DepthScanPass pass;

    public override void Create()
    {
        pass = new DepthScanPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

public class DepthScanPass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "Render DepthScanLine Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget2");
    static readonly int ScanLineColorId = Shader.PropertyToID("_ScanLineColor");
    static readonly int ScanLineWidthId = Shader.PropertyToID("_ScanLineWidth");
    static readonly int ScanLightStrengthId = Shader.PropertyToID("_ScanLightStrength");
    static readonly int ScanValueId = Shader.PropertyToID("_ScanValue");
    static readonly int DistortFactorId = Shader.PropertyToID("_DistortFactor");
    static readonly int CenterId = Shader.PropertyToID("_Center");
    static readonly int RadiusId = Shader.PropertyToID("_Radius");
    static float scanValue = 0.5f;

    DepthScanVolume depthScanVolume;
    Material material1;
    Material material2;
    RenderTargetIdentifier currentTarget;

    public DepthScanPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        string shaderPath = "Universal Render Pipeline/Dejavu/DepthScanLine"; ;
        var shader1 = Shader.Find(shaderPath);
        if (shader1 == null)
        {
            Debug.LogError("Shader not found.");
            return;
        }
        material1 = CoreUtils.CreateEngineMaterial(shader1);

        shaderPath = "Universal Render Pipeline/Dejavu/WorldDepthScanCircle";
        var shader2 = Shader.Find(shaderPath);
        if (shader2 == null)
        {
            Debug.LogError("Shader not found.");
            return;
        }
        material2 = CoreUtils.CreateEngineMaterial(shader2);

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (material1 == null || material2 == null)
        {
            Debug.LogError("Material not created.");
            return;
        }

        if (!renderingData.cameraData.postProcessEnabled) return;

        var stack = VolumeManager.instance.stack;
        depthScanVolume = stack.GetComponent<DepthScanVolume>();
        if (depthScanVolume == null) { return; }
        if (!depthScanVolume.IsActive()) { return; }
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
        Material material;
        scanValue += 0.01f * depthScanVolume.ScanSpeed.value;
        if(depthScanVolume.enableScanCircleEffect.value)
        {
            material = material2;
            if (scanValue > 1.0f)
                scanValue = 0.0f;
            material2.SetVector(CenterId, depthScanVolume.Center.value);
            material2.SetFloat(RadiusId, depthScanVolume.Radius.value);
            material2.SetFloat(ScanValueId, scanValue);
        }
        else
        {
            material = material1;
            if (scanValue > 1.0f)
                scanValue = 0.5f;
            material1.SetFloat(ScanValueId, 1 - scanValue);
            material1.SetFloat(DistortFactorId, depthScanVolume.DistortFactor.value * scanValue);
        }
        material.SetFloat(ScanLightStrengthId, depthScanVolume.ScanLightStrength.value);
        material.SetFloat(ScanLineWidthId, depthScanVolume.ScanLineWidth.value);
        material.SetVector(ScanLineColorId, depthScanVolume.ScanLineColor.value);
        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, material, shaderPass);
    }
}