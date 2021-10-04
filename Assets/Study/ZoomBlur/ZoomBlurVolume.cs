using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ZoomBlur")]
public class ZoomBlurVolume : VolumeComponent, IPostProcessComponent
{
    [Range(0f, 100f), Tooltip("强度")]
    public FloatParameter focusPower = new FloatParameter(0f);

    [Range(0, 10), Tooltip("模糊层数")]
    public IntParameter focusDetail = new IntParameter(5);

    [Tooltip("聚焦焦点")]
    public Vector2Parameter focusScreenPosition = new Vector2Parameter(Vector2.zero);


    public bool IsActive() => focusPower.value > 0f;

    public bool IsTileCompatible() => false;
}