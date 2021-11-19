using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowReceiver : MonoBehaviour
{
    private MeshRenderer renderer;
    public Camera shadowCamera;
    // Start is called before the first frame update
    void Start()
    {
        renderer = this.gameObject.GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        var vpMatrix = shadowCamera.projectionMatrix * shadowCamera.worldToCameraMatrix;
        //Debug.Log(vpMatrix);
        renderer.material.SetMatrix("_ShadowVPMatrix", vpMatrix);
    }
}
