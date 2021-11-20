using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ProjectorShadowRenderFeature : ScriptableRendererFeature
{
    ProjectorShadowPass pass;

    public override void Create()
    {
        pass = new ProjectorShadowPass(RenderPassEvent.AfterRenderingOpaques);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer);
        renderer.EnqueuePass(pass);
    }
}

public class ProjectorShadowPass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "ProjectorShadowPass Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");
    static readonly int BlurSizeId = Shader.PropertyToID("_BlurSize");


    ProjectorShadowVolume volume;
    Material material;
    RenderTargetIdentifier currentTarget;

    public ProjectorShadowPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("Universal Render Pipeline/Dejavu/ProjectorShadow/Blur");
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
        // DrawingSettings drawingSettings = new DrawingSettings();
        // drawingSettings.SetShaderPassName(0, new ShaderTagId("ProjectorShadowCaster"));
        // drawingSettings.SetShaderPassName(1, new ShaderTagId("ProjectorShadowCaster"));
        // FilteringSettings filteringSettings = new FilteringSettings();

        // context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
        //  context.Submit();
        var stack = VolumeManager.instance.stack;
        volume = stack.GetComponent<ProjectorShadowVolume>();
        var cmd = CommandBufferPool.Get(k_RenderTag);
        Render(cmd, ref renderingData);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public void Setup(ScriptableRenderer renderer)
    {
        this.currentTarget = renderer.cameraColorTarget;
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;
        var source = currentTarget;
        int destination = TempTargetId;
        var w = cameraData.camera.scaledPixelWidth;
        var h = cameraData.camera.scaledPixelHeight;
        material.SetFloat(BlurSizeId, volume.BlurSize.value);
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);

        for(int i = 0; i < volume.BlurNum.value; i++)
        {
            int shaderPass = 0;
            cmd.Blit(source, destination);
            cmd.Blit(destination, source, material, shaderPass);
            shaderPass = 1;
            cmd.Blit(source, destination);
            cmd.Blit(destination, source, material, shaderPass);
        }

    }
}