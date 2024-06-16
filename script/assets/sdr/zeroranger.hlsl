///////////////////////////////////////////////////////////////
///////////////////// ZeroRanger Filter ///////////////////////
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


PS_OUTPUT PsZeroranger(PS_INPUT inPs) : COLOR0
{
	PS_OUTPUT outPs;

	// Color of the input texture
	float4 colorTexture = tex2D(sampler0_, inPs.texCoord);

	// Vertex diffuse color
	float4 colorDiffuse = inPs.diffuse;

	// Composition
	float4 color = colorTexture * colorDiffuse;

	// Calculate the colors
	float3 monotone = ((color.r * 0.2126) + (color.g * 0.7152) + (color.b * 0.0722));
	
	float3 green  = float3(0, 0.7, 0.5) * monotone;
	float3 orange = float3(1, 0.5, 0) * (monotone * 1.5);
	
	outPs.color.rgb = 
		lerp
		(
			green,
			orange,
			color.r > 0.99
		);
	
	outPs.color.a = color.a;

	return outPs;
}

// Technique
technique TecZeroranger
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsZeroranger();
	}
}