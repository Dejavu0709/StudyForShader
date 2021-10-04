using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ZoomBlur")]
public class ZoomBlurVolume : VolumeComponent, IPostProcessComponent
{
    [Range(0f, 100f), Tooltip("ǿ��")]
    public FloatParameter focusPower = new FloatParameter(0f);

    [Range(0, 10), Tooltip("ģ������")]
    public IntParameter focusDetail = new IntParameter(5);

    [Tooltip("�۽�����")]
    public Vector2Parameter focusScreenPosition = new Vector2Parameter(Vector2.zero);


    public bool IsActive() => focusPower.value > 0f;

    public bool IsTileCompatible() => false;
}