using UnityEngine;
using System.Collections.Generic;

public class MeshBuilder
{

    private List<Vector3> _vertices;
    private List<Vector2> _uvs;
    private List<List<int>> _triangles;

    /// <summary>
    /// Initializes a new instance of the <see cref="MeshBuilder"/> class.
    /// </summary>
    public MeshBuilder()
    {
        _vertices = new List<Vector3>();
        _uvs = new List<Vector2>();
        _triangles = new List<List<int>>();
    }

    /// <summary>
    /// Clear all internal lists. You can create a new mesh definition after this.
    /// </summary>
    public void Clear()
    {
        _vertices.Clear();
        _uvs.Clear();
        _triangles.Clear();
    }

    /// <summary>
    /// Adds a vertex to the list, based on a Vector3f position and an optional Vector2f uv set
    /// </summary>
    /// <returns>The vertex index.</returns>
    /// <param name="x">The x coordinate.</param>
    /// <param name="y">The y coordinate.</param>
    /// <param name="z">The z coordinate.</param>
    /// <param name="u">The u coordinate</param>
    /// <param name="v">The v coordinate</param>
    public int AddVertex(Vector3 position, Vector2 uv = new Vector2())
    {
        int newVertexIndex = _vertices.Count;
        _vertices.Add(new Vector3(position.x, position.y, position.z));
        _uvs.Add(new Vector2(uv.x, uv.y));
        return newVertexIndex;
    }

    /// <summary>
    /// Adds a triangle to the list, based on three vertex indices.
    /// </summary>
    /// <param name="vertexIndex1">Vertex 1 index.</param>
    /// <param name="vertexIndex2">Vertex 2 index.</param>
    /// <param name="vertexIndex3">Vertex 3 index.</param>
    public void AddTriangle(int vertexIndex1, int vertexIndex2, int vertexIndex3, int subMeshNumber = 0)
    {
        while (subMeshNumber >= _triangles.Count)
        {
            _triangles.Add(new List<int>());
        }
        _triangles[subMeshNumber].Add(vertexIndex1);
        _triangles[subMeshNumber].Add(vertexIndex2);
        _triangles[subMeshNumber].Add(vertexIndex3);
    }

    public Vector3 GetVertex(int vertexIndex)
    {
        return _vertices[vertexIndex];
    }

    public void UpdateUV(int vertexIndex, Vector2 uv)
    {
        _uvs[vertexIndex] = uv;
    }

    /// <summary>
    /// Creates the mesh. Note: this will not reset any of the internal lists. (Use Clear to do that)
    /// </summary>
    /// <returns>The mesh.</returns>
    /// <param name="shouldRecalculateNormals">If set to <c>true</c> should recalculate normals.</param>
    public Mesh CreateMesh(bool shouldRecalculateNormals = true, bool shouldRecalculateTangents = true)
    {
        Mesh mesh = new Mesh();
        mesh.vertices = _vertices.ToArray();
        mesh.uv = _uvs.ToArray();
        mesh.subMeshCount = _triangles.Count;
        for (int i = 0; i < _triangles.Count; i++)
        {
            mesh.SetTriangles(_triangles[i].ToArray(), i);
        }
        if (shouldRecalculateNormals == true)
        {
            mesh.RecalculateNormals();
        }
        if (shouldRecalculateTangents == true)
        {
            mesh.RecalculateTangents();
        }
        mesh.RecalculateBounds();
        return mesh;
    }
}
