using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
 
namespace UnityEngine.Rendering.Universal
{
    [System.Serializable, VolumeComponentMenu("Dejavu/ScanLineBlock")]
    public sealed class ScanLineBlock : VolumeComponent, IPostProcessComponent
    {
        [Tooltip("是否开启效果")]
        public BoolParameter enableEffect = new BoolParameter(true);

        public bool IsActive() => enableEffect == true;

        public bool IsTileCompatible() => false;
    }
}