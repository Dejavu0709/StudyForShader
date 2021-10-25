using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HeightFogRenderFeature : ScriptableRendererFeature
{
    HeightFogPass pass;

    public override void Create()
    {
        pass = new HeightFogPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

public class HeightFogPass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "HeightFogPass Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");
    static readonly int FogStartHeightId = Shader.PropertyToID("_FogStartHeight");
    static readonly int FogHeightId = Shader.PropertyToID("_FogHeight");
    static readonly int FogIntensity = Shader.PropertyToID("_FogIntensity");
    static readonly int FogColorId = Shader.PropertyToID("_FogColor");

    HeightFogVolume volume;
    Material material;
    RenderTargetIdentifier currentTarget;

    public HeightFogPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("Universal Render Pipeline/Dejavu/HeightFog");
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
        volume = stack.GetComponent<HeightFogVolume>();
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
        material.SetFloat(FogStartHeightId, volume.FogStartHeight.value);
        material.SetFloat(FogHeightId, volume.FogHeight.value);
        material.SetFloat(FogIntensity, volume.FogIntensity.value);
        material.SetColor(FogColorId, volume.FogColor.value);
        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, material, shaderPass);
    }
}