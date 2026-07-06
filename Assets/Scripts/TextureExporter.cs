using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class TextureExporter : MonoBehaviour
{
	public string filename;

	public void ExportTexture(Texture2D texture) {
		byte[] data = texture.EncodeToPNG();
		string fullFilename = Application.streamingAssetsPath + "/" + filename + ".png";
		File.WriteAllBytes(fullFilename, data);
		Debug.Log("Texture successfully saved to " + fullFilename);
	}
}
