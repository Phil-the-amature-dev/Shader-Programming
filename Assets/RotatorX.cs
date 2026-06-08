using UnityEngine;

public class RotatorX : MonoBehaviour
{
    [SerializeField] private Vector3 rotateBy;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(rotateBy);
    }
}
