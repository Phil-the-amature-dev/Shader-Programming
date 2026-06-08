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
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");
        float y = Input.GetKey(KeyCode.E) ? 1 : Input.GetKey(KeyCode.Q) ? -1 : 0;

        transform.position += transform.forward * z * speed * Time.deltaTime;
        transform.position += transform.right * x * speed * Time.deltaTime;
        transform.position += Vector3.up * y * speed * Time.deltaTime;
    }
}
