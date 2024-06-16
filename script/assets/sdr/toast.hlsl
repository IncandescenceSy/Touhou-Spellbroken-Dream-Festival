///////////////////////////////////////////////////////////////
//////////////////// Toast Distortion Aura ////////////////////
///////////////////////////////////////////////////////////////

// The shader used for the distortion effects upon the spawning and despawning of effects such as major toasts


sampler sampler0_ : register(s0);

float frame_; // Current frame count
float intn_;  // Current strength of the effect


struct PS_INPUT
{
	float4 diffuse  : COLOR0;
	float2 texCoord : TEXCOORD0;
	float2 vPos     : VPOS;
};

struct PS_OUTPUT
{
	float4 color : COLOR0;
};


PS_OUTPUT PsDistort(PS_INPUT inPs) : COLOR0
{
	PS_OUTPUT outPs;
	
	float2 texUV = inPs.texCoord;
	
	float minFrame = frame_ * 0.08;
	
	// Warps the texture
	texUV.x += ((cos((texUV.y * 8) + minFrame) * 0.03) + (cos((texUV.y * 32) + minFrame) * 0.06)) * intn_;
	texUV.y += (sin((texUV.x * 128) + minFrame) * 0.1) * intn_;
	
	float4 color = tex2D(sampler0_, texUV);
	
	outPs.color = color * inPs.diffuse;
	
	return outPs;
}


technique TecDistort
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsDistort();
	}
}