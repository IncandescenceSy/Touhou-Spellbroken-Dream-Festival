sampler samp0_ : register(s0);

float4x4 g_mWorld : WORLD;
float4x4 g_mViewProj : VIEWPROJECTION;

float frameU_;
float frameMag_;
float4 filter_;


struct VS_INPUT 
{
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
};


struct PS_INPUT 
{
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
};


struct PS_OUTPUT 
{
    float4 color 	: COLOR0;
};


PS_INPUT VsSwirl(VS_INPUT inVs)
{
	PS_INPUT outVs;

	outVs.diffuse = inVs.diffuse;
	outVs.texCoord = inVs.texCoord;
	outVs.position = mul(inVs.position, g_mWorld);
	outVs.position = mul(outVs.position, g_mViewProj);
	outVs.position.z = 1.0f;

	return outVs;
}


PS_OUTPUT PsSwirl(PS_INPUT inPs)
{
	PS_OUTPUT outPs;

	outPs.color = (tex2D(samp0_, inPs.texCoord - float2(frameU_, frameMag_)) * inPs.diffuse) * filter_;

	return outPs;
}


technique TecSwirl
{
	pass P0
	{
		VertexShader = compile vs_3_0 VsSwirl();
		PixelShader = compile ps_3_0 PsSwirl();
	}
}