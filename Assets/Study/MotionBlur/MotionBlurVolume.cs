using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/MotionBlur")]
public class MotionBlurVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("�Ƿ���Ч��")]
    public BoolParameter EnableEffect = new BoolParameter(false);

    [Tooltip("ģ��ǿ��")]
    public FloatParameter BlurStrength = new FloatParameter(1.0f);

    [Tooltip("ģ��Ȩ��")]
    public Vector3Parameter BlurWeight = new Vector3Parameter(Vector3.one);

    public bool IsActive() => EnableEffect == true;

    public bool IsTileCompatible() => false;

}