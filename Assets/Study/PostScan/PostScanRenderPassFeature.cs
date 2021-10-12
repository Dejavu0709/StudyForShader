using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostScanRenderPassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent RenderEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public LayerMask LayerMask = -1;
        public Material ProcessMat;
        public string TextureName = "";
        public string CmdName = "";
        //public string PassName = "";
        public RenderTexture RT = null;
    }
    PostScanRenderPass _scriptablePass;
    private RenderTargetHandle dest;
    public Settings settings;
    /// <inheritdoc/>
    public override void Create()
    {
        _scriptablePass = new PostScanRenderPass(settings);
        _scriptablePass.renderPassEvent = settings.RenderEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var src = renderer.cameraColorTarget;
        dest = RenderTargetHandle.CameraTarget;
        _scriptablePass.Setup(src, this.dest);
        renderer.EnqueuePass(_scriptablePass);
    }
}


public class PostScanRenderPass : ScriptableRenderPass
{
    private CommandBuffer _cmd;
    private string _cmdName;
    private RenderTargetHandle _dest;
    private static Material _processMat;

    public static Material ProcessMat
    {
        get { return _processMat; }
    }

    private RenderTexture _rt;
    private LayerMask _layerMask = -1;
    private RenderTargetIdentifier Source { get; set; }
    RenderTargetHandle _temporaryColorTexture;
    RenderTargetHandle _rtID;
    RenderTargetHandle _rtWhiteHole;
    //RenderTargetHandle blurredID2;
    public PostScanRenderPass(PostScanRenderPassFeature.Settings param)
    {
        renderPassEvent = param.RenderEvent;
        _cmdName = param.CmdName;
        _processMat = param.ProcessMat;
        _rt = param.RT;
        _layerMask = param.LayerMask;
        _rtID.Init("RTID");
        _rtWhiteHole.Init("RtWhiteHole");
        //blurredID2.Init("blurredID2");
    }
    public void Setup(RenderTargetIdentifier src, RenderTargetHandle dest)
    {
        Source = src;
        _dest = dest;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //Debug.Log("custom post render:" + renderingData.cameraData.camera.name);
        //if (renderingData.cameraData.isSceneViewCamera) return;
        //如果cullingMask包含UI层的camera，返回
        // if ((renderingData.cameraData.camera.cullingMask & 1 << LayerMask.NameToLayer("UI")) > 0) 
        if ((renderingData.cameraData.camera.cullingMask & 1 << LayerMask.NameToLayer("RT")) > 0)
            return;
        if (!renderingData.cameraData.postProcessEnabled) return;
        var stack = VolumeManager.instance.stack;
        PostScanVolume ScanLineBlock = stack.GetComponent<PostScanVolume>();
        if (ScanLineBlock == null || !ScanLineBlock.IsActive()) { return; }
        // if (!CustomPostProMgr.Instance.TakeRT)
        //   return;
        _cmd = CommandBufferPool.Get(_cmdName);


        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;

        opaqueDesc.depthBufferBits = 0;
        _cmd.GetTemporaryRT(_temporaryColorTexture.id, opaqueDesc, FilterMode.Bilinear);
        _cmd.Blit(Source, _temporaryColorTexture.Identifier());

        _cmd.Blit(_temporaryColorTexture.Identifier(), Source, _processMat);

  
        //GlassCtrl.takeShot = false;
        //CustomPostProMgr.Instance.TakeRT = false;
        context.ExecuteCommandBuffer(_cmd);
        CommandBufferPool.Release(_cmd);
        //Debug.Log("custom post render:" + renderingData.cameraData.camera.name);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        if (_dest == RenderTargetHandle.CameraTarget)
        {
            cmd.ReleaseTemporaryRT(_temporaryColorTexture.id);
            cmd.ReleaseTemporaryRT(_rtID.id);
            cmd.ReleaseTemporaryRT(_rtWhiteHole.id);
            // cmd.ReleaseTemporaryRT(blurredID2.id);
        }
    }
}