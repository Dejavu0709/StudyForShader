using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


[System.Serializable, VolumeComponentMenu("Dejavu/ReconstructPositionWithDepth")]
public class ReconstructPositionWithDepthVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter enableEffect = new BoolParameter(false);

    public bool IsActive() => enableEffect == true;

    public bool IsTileCompatible() => false;
}