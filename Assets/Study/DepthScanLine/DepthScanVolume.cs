using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/DepthScan")]
public class DepthScanVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter enableEffect = new BoolParameter(false);
    [Tooltip("开启CircleLine效果 或者 DepthLine效果")]
    public BoolParameter enableScanCircleEffect = new BoolParameter(false);
    [Range(0f, 1f), Tooltip("宽度")]
    public FloatParameter ScanLineWidth = new FloatParameter(0.2f);
    [Range(0f, 1f), Tooltip("强度")]
    public FloatParameter ScanLightStrength = new FloatParameter(1f);
    [Tooltip("颜色")]
    public  ColorParameter ScanLineColor = new ColorParameter(Color.green);
    [Range(0f, 1f), Tooltip("移动速度")]
    public FloatParameter ScanSpeed = new FloatParameter(1.0f);
    [Range(0f, 1f), Tooltip("扭曲强度")]
    public FloatParameter DistortFactor = new FloatParameter(1.0f);
    [Tooltip("圆圈扫描中心")]
    public Vector3Parameter Center = new Vector3Parameter(Vector3.zero);
    [Tooltip("圆圈扫描半径")]
    public FloatParameter Radius = new FloatParameter(20.0f);
    public bool IsActive() => enableEffect == true;

    public bool IsTileCompatible() => false;
}