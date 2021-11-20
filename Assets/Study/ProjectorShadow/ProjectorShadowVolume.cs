using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ProjectorShadow")]
public class ProjectorShadowVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("�Ƿ���Ч��")]
    public BoolParameter EnableEffect = new BoolParameter(false);

  
    [Range(0, 1), Tooltip("ģ����Χ")]
    public FloatParameter BlurSize = new FloatParameter(1.0f);

    [Range(0, 1), Tooltip("ģ����������")]
    public IntParameter BlurNum = new IntParameter(1);

    public bool IsActive() => EnableEffect == true;

    public bool IsTileCompatible() => false;

}