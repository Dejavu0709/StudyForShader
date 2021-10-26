using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MotionBlurRenderFeature : ScriptableRendererFeature
{
    MotionBlurPass pass;

    public override void Create()
    {
        pass = new MotionBlurPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

public class MotionBlurPass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "MotionBlurPass Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");
    static readonly int BlurWeightId = Shader.PropertyToID("_BlurWeight");
    static readonly int BlurStrengthId = Shader.PropertyToID("_BlurStrength");
    static readonly int InverseVPMatrixId = Shader.PropertyToID("_InverseVPMatrix");
    static readonly int PreInverseVPMatrixId = Shader.PropertyToID("_PreInverseVPMatrix");
    MotionBlurVolume volume;
    Material material;
    RenderTargetIdentifier currentTarget;

    public MotionBlurPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("Universal Render Pipeline/Dejavu/MotionBlur");
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
        volume = stack.GetComponent<MotionBlurVolume>();
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

    Matrix4x4 _curMatrix = Matrix4x4.identity;
    Matrix4x4 _preMatrix = Matrix4x4.identity;

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;
        var source = currentTarget;
        int destination = TempTargetId;

        var w = cameraData.camera.scaledPixelWidth;
        var h = cameraData.camera.scaledPixelHeight;
        //material.SetFloat(FogStartHeightId, volume.FogStartHeight.value);
        //material.SetFloat(FogHeightId, volume.FogHeight.value);
        //material.SetFloat(FogIntensity, volume.FogIntensity.value);
        //material.SetColor(FogColorId, volume.FogColor.value);
        var vpMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        _curMatrix = vpMatrix.inverse;
        //Debug.Log(vpMatrix.inverse);
        cmd.SetGlobalMatrix(InverseVPMatrixId, _curMatrix);
        cmd.SetGlobalMatrix(PreInverseVPMatrixId, _preMatrix);
        material.SetFloat(BlurStrengthId, volume.BlurStrength.value);
        material.SetVector(BlurWeightId, volume.BlurWeight.value);
        _preMatrix = _curMatrix;
        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, material, shaderPass);
    }
}