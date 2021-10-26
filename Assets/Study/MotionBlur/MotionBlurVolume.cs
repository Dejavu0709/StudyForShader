using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/MotionBlur")]
public class MotionBlurVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter EnableEffect = new BoolParameter(false);

    [Tooltip("模糊强度")]
    public FloatParameter BlurStrength = new FloatParameter(1.0f);

    [Tooltip("模糊权重")]
    public Vector3Parameter BlurWeight = new Vector3Parameter(Vector3.one);

    public bool IsActive() => EnableEffect == true;

    public bool IsTileCompatible() => false;

}