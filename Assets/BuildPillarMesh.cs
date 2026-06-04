using UnityEngine;

public class BuildPillarMesh : MonoBehaviour
{
    MeshBuilder builder;
    
    
    [SerializeField] private float sectionHeight = 1;
    [SerializeField] private float sectionLength = 1;
    [SerializeField] private float sectionWidth = 1;
    [SerializeField] private float rowCount = 1;
    
    [SerializeField] private Vector3 rowOffstep = Vector3.right; 

    

    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        builder = new MeshBuilder();
        CreateCube1(transform.position.normalized);
        GetComponent<MeshFilter>().mesh = builder.CreateMesh(true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void CreatePillar()
    {
        float currentFloorHeight = transform.position.normalized.y;

    }

    void CreateCube1(Vector3 rootPosition)
    {
        builder.Clear();
        int length = 0;
        for (int i = 0; i <= rowCount; i++)
        {
            //-----------------------VERTECIES--------------------
            //bottom Vertecies
           
            int v1 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, sectionWidth), new Vector2(0, 0));
            int v1_2 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, sectionWidth), new Vector2(0, 0));
            int v1_3 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, sectionWidth), new Vector2(1, 0)); // _2 = duplicate

            int v2 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, -sectionWidth), new Vector2(1, 0));
            int v2_2 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, -sectionWidth), new Vector2(1, 0));
            int v2_3 = builder.AddVertex(rootPosition + new Vector3(sectionLength, 0, -sectionWidth), new Vector2(0, 0));


            int v3 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, sectionWidth), new Vector2(0, 1));
            int v3_2 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, sectionWidth), new Vector2(1, 0));
            int v3_3 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, sectionWidth), new Vector2(0, 0));
            int v3_4 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, sectionWidth), new Vector2(0, 0));

            int v4 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, -sectionWidth), new Vector2(1, 1));
            int v4_2 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, -sectionWidth), new Vector2(1, 1));
            int v4_3 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, -sectionWidth), new Vector2(0, 0));
            int v4_4 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, 0, -sectionWidth), new Vector2(1, 0));

            //front vertecies
            int v5 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, sectionWidth), new Vector2(1, 1));
            int v5_2 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, sectionWidth), new Vector2(1, 1));
            int v5_3 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, sectionWidth), new Vector2(0, 1));
            int v6 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, sectionWidth), new Vector2(0, 1));

            //back vertecies
            int v7 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, -sectionWidth), new Vector2(0, 1));
            int v7_2 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, -sectionWidth), new Vector2(0, 1));
            int v8 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, -sectionWidth), new Vector2(1, 1));
            int v8_2 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, -sectionWidth), new Vector2(1, 0));

            //right vertecies
            int v9 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, sectionWidth), new Vector2(1, 1));
            int v9_2 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, sectionWidth), new Vector2(1, 1));
            int v9_3 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, sectionWidth), new Vector2(1, 1));
            int v10 = builder.AddVertex(rootPosition + new Vector3(sectionLength, sectionHeight, -sectionWidth), new Vector2(0, 1));

            //left vertecies
            int v11 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, -sectionWidth), new Vector2(1, 1));
            int v11_2 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, -sectionWidth), new Vector2(1, 1));
            int v11_3 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, -sectionWidth), new Vector2(0, 0));
            int v12 = builder.AddVertex(rootPosition + new Vector3(-sectionLength, sectionHeight, sectionWidth), new Vector2(0, 1));

            //--------------------FACES-------------------------
            //bottom face
            builder.AddTriangle(v4, v2, v1);
            builder.AddTriangle(v1_2, v3, v4_2);

            //front face
            builder.AddTriangle(v1_2, v5_2, v3_2);
            builder.AddTriangle(v6, v5, v1);

            //back face
            builder.AddTriangle(v4_3, v7, v2);
            builder.AddTriangle(v2_2, v7_2, v8);

            //right face
            builder.AddTriangle(v2_3, v9, v1_3);
            builder.AddTriangle(v10, v9_2, v2_3);

            //left face
            builder.AddTriangle(v3_3, v11, v4_4);
            builder.AddTriangle(v12, v11_2, v3_4);

            //top face
            builder.AddTriangle(v9_3, v8_2, v11_3);
            builder.AddTriangle(v11_3, v5_3, v9_3);
            
            rootPosition += rowOffstep;
            length++;
        }
        
    }
}
  