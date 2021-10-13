using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/DepthScanLine")]
public class DepthScanLineVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("�Ƿ���Ч��")]
    public BoolParameter enableEffect = new BoolParameter(false);
    [Range(0f, 1f), Tooltip("���")]
    public FloatParameter ScanLineWidth = new FloatParameter(0.2f);
    [Range(0f, 1f), Tooltip("ǿ��")]
    public FloatParameter ScanLightStrength = new FloatParameter(1f);
    [Tooltip("��ɫ")]
    public Vector4Parameter ScanLineColor = new Vector4Parameter(Vector4.one);
    [Range(0f, 1f), Tooltip("�ƶ��ٶ�")]
    public FloatParameter ScanSpeed = new FloatParameter(1.0f);
    [Range(0f, 1f), Tooltip("Ť��ǿ��")]
    public FloatParameter DistortFactor = new FloatParameter(1.0f);


    public bool IsActive() => enableEffect == true;

    public bool IsTileCompatible() => false;
}