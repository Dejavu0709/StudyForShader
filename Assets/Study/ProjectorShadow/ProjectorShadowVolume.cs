using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ProjectorShadow")]
public class ProjectorShadowVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("�Ƿ���Ч��")]
    public BoolParameter EnableEffect = new BoolParameter(false);

    [Tooltip("����ʼ�߶�")]
    public FloatParameter FogStartHeight = new FloatParameter(0f);

    [Tooltip("��߶�")]
    public FloatParameter FogHeight = new FloatParameter(10f);

    [Range(0, 1), Tooltip("��ǿ��")]
    public FloatParameter FogIntensity = new FloatParameter(0.5f);

    [Range(0, 1), Tooltip("����ɫ")]
    public ColorParameter FogColor = new ColorParameter(Color.white);

    public bool IsActive() => EnableEffect == true;

    public bool IsTileCompatible() => false;

}