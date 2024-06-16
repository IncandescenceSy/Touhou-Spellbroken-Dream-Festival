///////////////////////////////////////////////////////////////
//////////////////// Boss Distortion Aura /////////////////////
///////////////////////////////////////////////////////////////

// The shader used to warp the background behind the boss


sampler sampler0_ : register(s0);

float frame_;  // Current frame count
float enmX_;   // Enemy X position
float enmY_;   // Enemy Y position
float radius_; // Effect radius


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
	
	// Distance from the center of the distortion 
	float dist = (inPs.vPos.x - enmX_) * (inPs.vPos.x - enmX_) + (inPs.vPos.y - enmY_) * (inPs.vPos.y - enmY_);
	
	// Intensity of the distortion from zero to one; one is the center
	float intn = max(0, (radius_ * radius_ - (dist * 0.5)) / (radius_ * radius_));
	float intnW = max(0, intn - 0.5);
	
	float2 texUV = inPs.texCoord;
	
	float minFrame = frame_ * 0.08;
	
	// Warps the texture
	texUV.x += (intnW * cos((texUV.y * 8) + minFrame) * 0.03) + (intnW * cos((texUV.y * 32) + minFrame) * 0.06);
	texUV.y += intnW * sin((texUV.x * 128) + minFrame) * 0.1;
	
	outPs.color = tex2D(sampler0_, texUV) * inPs.diffuse;
	
	return outPs;
}


technique TecDistort
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsDistort();
	}
}