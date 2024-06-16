///////////////////////////////////////////////////////////////
///////////////////// Monochrome Filter ///////////////////////
///////////////////////////////////////////////////////////////


sampler sampler0_ : register(s0);


// Pixel shader input value
struct PS_INPUT
{
	float4 diffuse  : COLOR0;    // Diffuse color
	float2 texCoord : TEXCOORD0; // Texture coordinates
	float2 vPos     : VPOS;      // Draw destination coordinates
};


// Pixel shader output value
struct PS_OUTPUT
{
    float4 color : COLOR0; // Output color
};


PS_OUTPUT PsMonochrome(PS_INPUT inPs) : COLOR0
{
	PS_OUTPUT outPs;

	// Color of the input texture
	float4 colorTexture = tex2D(sampler0_, inPs.texCoord);

	// Vertex diffuse color
	float4 colorDiffuse = inPs.diffuse;

	// Composition
	float4 color = colorTexture * colorDiffuse;

	// Calculate the colors
	outPs.color.rgb = ((color.r * 0.2126) + (color.g * 0.7152) + (color.b * 0.0722));
	outPs.color.a = color.a;

	return outPs;
}

// Technique
technique TecMonochrome
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsMonochrome();
	}
}