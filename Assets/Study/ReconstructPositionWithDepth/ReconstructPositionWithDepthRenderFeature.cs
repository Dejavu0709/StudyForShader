using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReconstructPositionWithDepthRenderFeature : ScriptableRendererFeature
{
    ReconstructPositionWithDepthPass pass;

    public override void Create()
    {
        pass = new ReconstructPositionWithDepthPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

public class ReconstructPositionWithDepthPass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "ReconstructPositionWithDepthPass Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");
    static readonly int InverseVPMatrixId = Shader.PropertyToID("_InverseVPMatrix");
    //static readonly int ScanLineColorId = Shader.PropertyToID("_ScanLineColor");
    //static readonly int ScanLineWidthId = Shader.PropertyToID("_ScanLineWidth");
    //static readonly int ScanLightStrengthId = Shader.PropertyToID("_ScanLightStrength");
    //static readonly int ScanValueId = Shader.PropertyToID("_ScanValue");
    //static readonly int DistortFactorId = Shader.PropertyToID("_DistortFactor");

    ReconstructPositionWithDepthVolume volume;
    Material material;
    RenderTargetIdentifier currentTarget;

    public ReconstructPositionWithDepthPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        //var shader = Shader.Find("Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/ReconstructPositionByInvMatrix");
        var shader = Shader.Find("Universal Render Pipeline/Dejavu/ReconstructPositionWithDepth/ReconstructPositionByRay");
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
        volume = stack.GetComponent<ReconstructPositionWithDepthVolume>();
        if (volume == null) { return; }
        if (!volume.IsActive()) { return; }
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

        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);

        var vpMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        //Debug.Log(vpMatrix.inverse);
        cmd.SetGlobalMatrix(InverseVPMatrixId, vpMatrix.inverse);
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, material, shaderPass);
    }
}