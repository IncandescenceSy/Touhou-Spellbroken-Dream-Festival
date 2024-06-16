///////////////////////////////////////////////////////////////
////////////////////// Pause Background ///////////////////////
///////////////////////////////////////////////////////////////

// A shader that forces things to have 100% opacity, and blurs them. Used for the pause menu background


sampler sampler0_ : register(s0);

float intn_;
float lightness_;
float sdrMisc_;

static const float _RENDER_BASE   = 32;
static const float _EFFECT        = 1 / _RENDER_BASE;
static const float _RENDER_WIDTH  = 1024;
static const float _RENDER_HEIGHT = 512;
static const float _RENDER_X      = 1 / _RENDER_WIDTH;
static const float _RENDER_Y      = 1 / _RENDER_HEIGHT;

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


PS_OUTPUT PsPause(PS_INPUT inPs) : COLOR0
{
    PS_OUTPUT outPs;
	
	float2 texUV = inPs.texCoord;
	
	float4 colorTexture;
	
	if(sdrMisc_)
	{
		colorTexture = _EFFECT * tex2D(sampler0_, texUV);
		
		// Blur effect
		for(int i = 0; i < 300; i += 30)
		{
			float2 ang = float2(cos(radians(i)), sin(radians(i))) * intn_;
			for(int j = 1; j < 4; ++j)
			{
				colorTexture += _EFFECT * (tex2D(sampler0_, texUV + float2(_RENDER_X * i * ang)));
			}
		}
	}
	else
	{
		colorTexture = tex2D(sampler0_, texUV);
	}
	
	colorTexture.a = 1;
	colorTexture = saturate(colorTexture);
	
	float4 color = colorTexture * inPs.diffuse;
	
	// Darkens the image
	outPs.color.rgb = color.rgb * lightness_;
	
	// Makes the image completely opaque
	outPs.color.a = 1;

    return outPs;
}


technique TecPause
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsPause();
	}
}