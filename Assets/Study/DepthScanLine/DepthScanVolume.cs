using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/DepthScan")]
public class DepthScanVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("�Ƿ���Ч��")]
    public BoolParameter enableEffect = new BoolParameter(false);
    [Tooltip("����CircleLineЧ�� ���� DepthLineЧ��")]
    public BoolParameter enableScanCircleEffect = new BoolParameter(false);
    [Range(0f, 1f), Tooltip("���")]
    public FloatParameter ScanLineWidth = new FloatParameter(0.2f);
    [Range(0f, 1f), Tooltip("ǿ��")]
    public FloatParameter ScanLightStrength = new FloatParameter(1f);
    [Tooltip("��ɫ")]
    public  ColorParameter ScanLineColor = new ColorParameter(Color.green);
    [Range(0f, 1f), Tooltip("�ƶ��ٶ�")]
    public FloatParameter ScanSpeed = new FloatParameter(1.0f);
    [Range(0f, 1f), Tooltip("Ť��ǿ��")]
    public FloatParameter DistortFactor = new FloatParameter(1.0f);
    [Tooltip("ԲȦɨ������")]
    public Vector3Parameter Center = new Vector3Parameter(Vector3.zero);
    [Tooltip("ԲȦɨ��뾶")]
    public FloatParameter Radius = new FloatParameter(20.0f);
    public bool IsActive() => enableEffect == true;

    public bool IsTileCompatible() => false;
}