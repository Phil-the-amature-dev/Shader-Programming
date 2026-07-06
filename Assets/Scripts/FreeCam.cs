using UnityEngine;

public class FreeCam : MonoBehaviour
{
    public float speed = 10f;
    public float sensitivity = 2f;

    float rotX, rotY;

    void Update()
    {
        // Rotation
        if (Input.GetMouseButton(1))
        {
            rotX -= Input.GetAxis("Mouse Y") * sensitivity;
            rotY += Input.GetAxis("Mouse X") * sensitivity;
            transform.rotation = Quaternion.Euler(rotX, rotY, 0);
        }

        // Movement
        float x = Input.GetKey(KeyCode.A) ? -1 : Input.GetKey(KeyCode.D) ? 1 : 0;
        float z = Input.GetKey(KeyCode.W) ? 1 : Input.GetKey(KeyCode.S) ? -1 : 0;
        float y = Input.GetKey(KeyCode.E) ? 1 : Input.GetKey(KeyCode.Q) ? -1 : 0;

        transform.position += transform.forward * z * speed * Time.deltaTime;
        transform.position += transform.right * x * speed * Time.deltaTime;
        transform.position += Vector3.up * y * speed * Time.deltaTime;
    }
}