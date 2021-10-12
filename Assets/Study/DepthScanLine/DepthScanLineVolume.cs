using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/DepthScanLine")]
public class DepthScanLineVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter enableEffect = new BoolParameter(true);
    [Range(0f, 1f), Tooltip("宽度")]
    public FloatParameter ScanLineWidth = new FloatParameter(0.2f);
    [Range(0f, 1f), Tooltip("强度")]
    public FloatParameter ScanLightStrength = new FloatParameter(1f);
    [Tooltip("颜色")]
    public Vector4Parameter ScanLineColor = new Vector4Parameter(Vector4.one);
    [Range(0f, 1f), Tooltip("动态高亮区域")]
    public FloatParameter ScanValueId = new FloatParameter(0.2f);
    public bool IsActive() => enableEffect == true;

    public bool IsTileCompatible() => false;
}