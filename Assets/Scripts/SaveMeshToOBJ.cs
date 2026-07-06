// Version 2023
//  (Updates: no getters in loop for efficiency)
using UnityEngine;
using System.IO;	// For file I/O
using System;		// For String formatting

public class SaveMeshToOBJ : MonoBehaviour
{
    public string filename;

    public void SaveMesh()
    {
        var filter = GetComponent<MeshFilter>();
        if (filter != null)
        {
            int index = 1;
            while (File.Exists(filename + index + ".obj"))
            {
                index++;
            }
            string fullName = "Assets/" + filename + index + ".obj";
            SaveMeshToObj(GetComponent<MeshFilter>().mesh, fullName);
            Debug.Log("Saved mesh to " + fullName);
        }
    }

    /// <summary>
    /// Saves the mesh as an OBJ file.
    /// </summary>
    /// <param name="mesh">Mesh.</param>
    /// <param name="filename">Filename. Does not automatically set the extension.</param>
    static public void SaveMeshToObj(Mesh mesh, string filename)
    {
        StreamWriter writer = new StreamWriter(filename);

        //object name
        writer.WriteLine("#Mesh\n");
        writer.WriteLine("g mesh\n");

        //vertices
        Vector3[] verts = mesh.vertices;
        for (int i = 0; i < verts.Length; i++)
        {
            float x = verts[i].x;
            float y = verts[i].y;
            float z = verts[i].z;
            writer.WriteLine(String.Format("v {0:F3} {1:F3} {2:F3}", x, y, z));
        }
        writer.WriteLine("");

        //uv-set
        Vector2[] uvs = mesh.uv;
        for (int i = 0; i < uvs.Length; i++)
        {
            float u = uvs[i].x;
            float v = uvs[i].y;
            writer.WriteLine(String.Format("vt {0:F3} {1:F3}", u, v));
        }
        writer.WriteLine("");

        //normals
        Vector3[] normals = mesh.normals;
        for (int i = 0; i < normals.Length; i++)
        {
            float x = normals[i].x;
            float y = normals[i].y;
            float z = normals[i].z;
            writer.WriteLine(String.Format("vn {0:F3} {1:F3} {2:F3}", x, y, z));
        }
        writer.WriteLine("");

        //triangles
        int[] tris = mesh.triangles;
        for (int i = 0; i < tris.Length / 3; i++)
        {
            int v0 = tris[i * 3 + 0] + 1;
            int v1 = tris[i * 3 + 1] + 1;
            int v2 = tris[i * 3 + 2] + 1;
            writer.WriteLine(String.Format("f {0}/{0}/{0} {1}/{1}/{1} {2}/{2}/{2}", v0, v1, v2));
        }

        writer.Close();
    }
}
