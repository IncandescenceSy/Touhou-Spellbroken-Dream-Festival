texture textureMask_;

float frame_;
float charge_;

sampler sampler0_ : register(s0);
sampler samplerMask_ = sampler_state {
	Texture = <textureMask_>;
};

struct PS_INPUT {
	float4 diffuse : COLOR0;
	float2 texCoord : TEXCOORD0;
	float2 vPos : VPOS;
};

struct PS_OUTPUT {
    float4 color : COLOR0;
};

PS_OUTPUT PsFire(PS_INPUT In) : COLOR0
{
	PS_OUTPUT Out;

    float scale = 512.0f;

    float4 color = tex2D(sampler0_, In.texCoord) * In.diffuse;
    float2 posToCoord;

	posToCoord = (In.vPos + float2(-0.6f, 1.1f) * frame_) / scale;
	//posToCoord = (In.texCoord / 4) + (float2(-0.6f, 1.1f) * frame_) / scale;
    float mask1 = tex2D(samplerMask_, posToCoord).g;

	posToCoord = (In.vPos + float2(-0.5f, 1.0f) * frame_) / scale;
	//posToCoord = (In.texCoord / 4) + (float2(-0.5f, 1.1f) * frame_) / scale;
	float mask2 = tex2D(samplerMask_, posToCoord).g;

    float maskedAlpha = color.a * (mask1 + mask2);

	// Red
    if(charge_)
	{
		color.bgr = float3(0, maskedAlpha * 0.75f, 1);
		color.b += 0.13;
	}
	
	// Blue
	else
	{
		color.rgb = float3(0, maskedAlpha * 0.75f, 1);
		color.r += 0.13;
	}


    // color.r = max(0.5f, color.a * (maskB + maskG) > 0.75f);

	color.a = (maskedAlpha - 0.3f);
	
	Out.color = saturate(color);

	return Out;
}

PS_OUTPUT PsExpl(PS_INPUT In) : COLOR0
{
    PS_OUTPUT Out;

    float scale = 512.0f;
    float2 middle = float2(0.5f, 0.5f);

    float alpha = (1 - distance(In.texCoord, middle) * 2) * In.diffuse.a;
    float2 posToCoord;

    posToCoord = (In.vPos - float2(-0.6f, 1.1f) * frame_) / scale;
    float maskG = tex2D(sampler0_, posToCoord).g;

    posToCoord = (In.vPos - float2(0.5f, -1.0f) * frame_) / scale;
    float maskB = tex2D(sampler0_, posToCoord).g;

    float maskedAlpha = alpha * (maskB + maskG);

    float4 color = float4(1, 1, 1, 1);

	color.rgb = float3(0, maskedAlpha * 0.75f, 1);
	color.r += 0.13;
	
    color.a = (maskedAlpha - 0.3f);
    
    Out.color = saturate(color);

    return Out;
}

technique TecFire {
	pass P0 {
		PixelShader = compile ps_3_0 PsFire();
	}
}

technique TecExpl {
	pass P0 {
		PixelShader = compile ps_3_0 PsExpl();
	}
}