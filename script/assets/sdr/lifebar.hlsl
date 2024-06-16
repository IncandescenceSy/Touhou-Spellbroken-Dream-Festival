///////////////////////////////////////////////////////////////
////////////////// Lifebar Distortion Aura ////////////////////
///////////////////////////////////////////////////////////////

// The shader used to create the second warped copy of the boss lifebar / position-indicating lines


sampler sampler0_ : register(s0);

float frame_; // Current frame count
float life_;  // Current boss life ratio


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
	
	float minFrame = frame_ * 0.015625;
	
	// Warps the texture
	texUV.x += ((cos((texUV.y * 8) + minFrame) * 0.015625) + (cos((texUV.y * 32) + minFrame) * 0.03125)) * life_;
	texUV.y += (sin((texUV.x * 128) + minFrame) * 0.0625) * life_;
	
	float4 color = tex2D(sampler0_, texUV);
	
	color.a = lerp(color.a, inPs.diffuse * 0.5, color.a);
	
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