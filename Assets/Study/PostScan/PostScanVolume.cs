using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
 
namespace UnityEngine.Rendering.Universal
{
    [System.Serializable, VolumeComponentMenu("Dejavu/PostScanVolume")]
    public sealed class PostScanVolume : VolumeComponent, IPostProcessComponent
    {
        [Tooltip("�Ƿ���Ч��")]
        public BoolParameter enableEffect = new BoolParameter(true);

        public bool IsActive() => enableEffect == true;

        public bool IsTileCompatible() => false;
    }
}