using UnityEngine;


public class TextureCreator : MonoBehaviour {
	[SerializeField] int squareCount;
	[SerializeField] float rotateBy;
    [SerializeField] Color colorA;
    [SerializeField] Color colorB;


    // Add your own pattern types here:
    public enum PatternType { Noise, None, Mandelbrot, CustomTexture };

	public PatternType patternType;

	const int SIZE = 1024;

	Texture2D texture = null;
	Color[] cols = null;

	void Start() {
		// Create a texture and pass it to the material of this game object's renderer:
		Renderer rend = GetComponent<Renderer>();
		texture = new Texture2D(SIZE, SIZE, TextureFormat.RGBA32, false);
		rend.material.mainTexture = texture;
		texture.wrapMode = TextureWrapMode.Clamp;

        Draw();
    }

	/// <summary>
	/// Returns the pixel color for texture coordinate (u,v), for a given pattern.
	/// </summary>
	Color CalculatePixelColor(float u, float v, PatternType pattern) {
		// TODO: insert your own pattern creation code here.
		//  See the slides for details.
		switch (pattern) {
			case PatternType.Noise: // white noise				
				return Random.value * Color.white;
			case PatternType.Mandelbrot:
				return Mandelbrot(3 * (u - 0.75f), 3 * (v - 0.5f));
			case PatternType.CustomTexture:
				return Checkerboard(u,v);
			default:
				return Color.blue;
		}
	}

	/// <summary>
	/// Draws a pattern given by the [pattern] number to the [cols] array, which
	/// should have size [width] * [height].
	/// </summary>
	void DrawPattern(Color[] cols, int width, int height, PatternType pattern) {
		for (int index = 0; index < width * height; index++) {
			// TODO: calculate UV coordinates and pass them to CalculatePixelColor:
			int x = index % width;
            int y = index / width;

			float u = (float)x / (width - 1);
            float v = (float)y / (height - 1);

			cols[index] = CalculatePixelColor(u, v, pattern); //calculates evry pixel on texture
		}
	}

	Color Checkerboard(float u, float v)
	{
		float squaresPerSide = this.squareCount;

		Color colorA = this.colorA;
        Color colorB = this.colorB;

        // Rotate (u,v) around the texture center (0.5, 0.5)
        float rad = rotateBy * Mathf.Deg2Rad;
        float cos = Mathf.Cos(rad);
        float sin = Mathf.Sin(rad);

        float x = u - 0.5f;
        float y = v - 0.5f;

        float xRot = x * cos - y * sin;
        float yRot = y * cos + x * sin;

        u = xRot + 0.5f;
        v = yRot + 0.5f;

        // Which cell (column, row) does this pixel fall into?
        int cellX = Mathf.FloorToInt(u * squaresPerSide);
        int cellY = Mathf.FloorToInt(v * squaresPerSide);

        // Even sum -> one color, odd sum -> the other.
        bool isEven = (cellX + cellY) % 2 == 0;

		return isEven ? colorA : colorB;
    }

	void Draw() {
		if (cols == null) {
			cols = texture.GetPixels();
		}
		DrawPattern(cols, SIZE, SIZE, patternType);

		texture.SetPixels(cols);
		texture.Apply();
	}

    // OnValidate is called whenever an inspector value is changed - even in edit mode!
    void OnValidate() {
		// To prevent calling Draw code in edit mode,
		// we check whether a texture has been created (in Start)
		if (texture == null) return;
		Draw();
	}

	private void Update() {
        // Control + S saves to file:
        if (Input.GetKeyDown(KeyCode.S) && (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))) {
			var exporter = GetComponent<TextureExporter>();
			if (exporter != null) {
				exporter.ExportTexture(texture);
			}
		}
	}


    #region Mandelbrot
    // Used for the Mandelbrot fractal:
    const int maxIterations = 30;
	const float escapeLengthSquared = 4;

	Color Mandelbrot(float cReal, float cImaginary) {
		int iteration = 0;

		float zReal = 0;
		float zImaginary = 0;

		while (zReal * zReal + zImaginary * zImaginary < escapeLengthSquared && iteration < maxIterations) {
			// Use Mandelbrot's magic iteration formula: z := z^2 + c 
			// (using complex number multiplication & addition - 
			//   see https://mathbitsnotebook.com/Algebra2/ComplexNumbers/CPArithmeticASM.html)
			float newZr = zReal * zReal - zImaginary * zImaginary + cReal;
			zImaginary = 2 * zReal * zImaginary + cImaginary;
			zReal = newZr;
			iteration++;
		}
		// Return a color value based on the number of iterations that were needed to "escape the circle":
		float grad = 1f * iteration / maxIterations; // between 0 and 1
													 // TODO: use a nicer gradient
		return new Color(grad, grad, grad);
	}
	#endregion
}
