///////////////////////////////////////////////////////////////
///////////////////////// Alpha Mask //////////////////////////
///////////////////////////////////////////////////////////////

// The mask shader used to cut the center out of the frame graphic and make it partially transparent, as well as for the spell background spawning and despawning effects and the pause menu mask effects


sampler sampler0_ : register(s0);

// Screen dimensions
float screenWidth_;
float screenHeight_;

// Overrides
float overrideAlpha_;
float alphaMult_;

// Color filter
float4 filter_;

// Texture
texture textureMask_;

sampler samplerMask_ = sampler_state
{ 
	Texture = <textureMask_>;
};


// Pixel shader input value
struct PS_INPUT
{
	float4 diffuse  : COLOR0;    // Diffuse color
	float2 texCoord : TEXCOORD0; // Texture coordinates
	float2 vPos     : VPOS;      // Destination coordinate
};

// Pixel shader output value
struct PS_OUTPUT
{
    float4 color : COLOR0; // Output color
};


PS_OUTPUT PsMaskMult(PS_INPUT inPs) : COLOR0
{
    PS_OUTPUT outPs;
    
    float4 color = tex2D(sampler0_, inPs.texCoord);
    outPs.color = color;

    float2 maskUV = float2(inPs.vPos.x / screenWidth_, inPs.vPos.y / screenHeight_);
	
    float4 colorMask = tex2D(samplerMask_, maskUV);

    outPs.color.a = lerp(
      outPs.color.a,
      colorMask.a * color.a,
      color.a > 0
    );

    outPs.color.a *= colorMask.a * alphaMult_;
	
	outPs.color *= filter_;
	
    return outPs;
}

PS_OUTPUT PsMaskConst(PS_INPUT inPs) : COLOR0
{
    PS_OUTPUT outPs;
    
    float4 color = tex2D(sampler0_, inPs.texCoord);
    outPs.color = color;

    float2 maskUV = float2(inPs.vPos.x / screenWidth_, inPs.vPos.y / screenHeight_);
	
    float4 colorMask = tex2D(samplerMask_, maskUV);

    outPs.color.a = lerp(
      outPs.color.a,
      colorMask.a * color.a,
      color.a > 0
    );

    outPs.color.a = lerp(
		outPs.color.a,
		overrideAlpha_,
		colorMask.a > 0
	);
	
	outPs.color *= filter_;
	
    return outPs;
}


technique TecMaskMult
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsMaskMult();
	}
}

technique TecMaskConst
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsMaskConst();
	}
}