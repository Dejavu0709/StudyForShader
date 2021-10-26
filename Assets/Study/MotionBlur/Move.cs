using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    public float Period;
    public float Speed;
    public float Distance;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Camera.main.transform.position = new Vector3(Distance * Mathf.Sin(Time.time * Period), Camera.main.transform.position.y, Camera.main.transform.position.z);
    }
}
