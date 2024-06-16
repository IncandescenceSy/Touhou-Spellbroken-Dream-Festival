///////////////////////////////////////////////////////////////
/////////////////// Angle-based coloring //////////////////////
///////////////////////////////////////////////////////////////


sampler sampler0_ : register(s0);

static const float PI = 3.1415926536f;

float enmX_;
float enmY_;

float colors_;


float NormalizeAngle(float ang)
{
    ang = fmod(ang, PI * 2.0f);
    return ang < 0.0f ? ang + (PI * 2.0f) : ang;
}

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


PS_OUTPUT PsAngcolor(PS_INPUT inPs) : COLOR0
{
	PS_OUTPUT outPs;

	// Color of the input texture
	float4 colorTexture = tex2D(sampler0_, inPs.texCoord);

	// Vertex diffuse color
	float4 colorDiffuse = inPs.diffuse;

	// Composition
	float4 color = colorTexture * colorDiffuse;

	// Calculate the colors
	float3 monotone = ((color.r * 0.2126) + (color.g * 0.7152) + (color.b * 0.0722)) * 1.5;
	
	float3 red    = float3(1, 0, 0) * monotone;
	float3 orange = float3(1, 0.5, 0) * monotone;
	float3 yellow = float3(1, 1, 0) * monotone;
	float3 green  = float3(0, 1, 0) * monotone;
	float3 aqua   = float3(0, 1, 1) * monotone;
	float3 azure  = float3(0, 0.5, 1) * monotone;
	float3 purple = float3(0.75, 0, 0.75) * monotone;
	float3 pink   = float3(1, 0.5, 0.75) * monotone;
	
	float2 texUV = inPs.vPos;
	
	outPs.color.rgb = azure;
	
	if(colors_ == 2)
	{
		outPs.color.rgb =
			lerp
			(
				outPs.color.rgb,
				red,
				texUV.x < enmX_
			);
	}
	else if(colors_ == 4)
	{
		float ang = NormalizeAngle(atan2(texUV.y - enmY_, texUV.x - enmX_) + (PI / 2));
		float3 colors[] = {pink, pink, azure, azure, green, green, red, red}; 
		outPs.color.rgb = colors[(int)(ang * (8.0f / (PI * 2.0f)))];
	}
	else if(colors_ == 8)
	{
		float ang = NormalizeAngle(atan2(texUV.y - enmY_, texUV.x - enmX_) + (PI / 2));
		float3 colors[] = {pink, purple, azure, aqua, green, yellow, orange, red}; 
		outPs.color.rgb = colors[(int)(ang * (8.0f / (PI * 2.0f)))];
	}
	
	
	outPs.color.a = color.a;

	return outPs;
}

// Technique
technique TecAngcolor
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsAngcolor();
	}
}