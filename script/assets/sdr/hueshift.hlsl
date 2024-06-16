///////////////////////////////////////////////////////////////
///////////////////////// Hue Shift ///////////////////////////
///////////////////////////////////////////////////////////////

sampler sampler0_ : register(s0);

static const float3 HUE_K = (float3)(rsqrt(3));

float hueValue_ = 0;
float brightness_ = 1;


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


float4 PsHueshift(PS_INPUT inPs_) : COLOR0
{
    float2 sc; sincos(hueValue_, sc.x, sc.y);

    float4 color = tex2D(sampler0_, inPs_.texCoord);
    color = float4(color.rgb * sc.y + cross(HUE_K, color.rgb) * sc.x + HUE_K * dot(HUE_K, color.rgb) * (1 - sc.y), color.a);
    color.rgb *= brightness_;

	return color * inPs_.diffuse;
}


// Technique
technique TecHueshift
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsHueshift();
	}
}