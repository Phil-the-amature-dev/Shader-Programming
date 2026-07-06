using UnityEngine;

public class SimpleMove : MonoBehaviour
{
	public float moveSpeedPerSecond = 5;

    void Update()
    {
		float multiplier = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift) ? 3 : 1;
		transform.position += multiplier * Time.deltaTime * moveSpeedPerSecond * 
			new Vector3(Input.GetAxis("Horizontal"),0,Input.GetAxis("Vertical"));
    }
}
