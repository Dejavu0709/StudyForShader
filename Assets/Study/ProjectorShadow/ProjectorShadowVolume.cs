using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ProjectorShadow")]
public class ProjectorShadowVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter EnableEffect = new BoolParameter(false);

  
    [Range(0, 1), Tooltip("模糊范围")]
    public FloatParameter BlurSize = new FloatParameter(1.0f);

    [Range(0, 1), Tooltip("模糊迭代次数")]
    public IntParameter BlurNum = new IntParameter(1);

    public bool IsActive() => EnableEffect == true;

    public bool IsTileCompatible() => false;

}