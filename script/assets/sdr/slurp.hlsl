sampler sampler0_ : register(s0);

float2 rect_ = float2(1024, 1024);
float2 pos_ = float2(480, 360);
float radius_ = 1024;
float intn_ = 1;

static const float PI = 3.14159265f;

struct PS_INPUT {
    float4 diffuse : COLOR0;  
    float2 texCoord : TEXCOORD0; 
    float2 vPos : VPOS;
};
struct PS_OUTPUT {
    float4 color : COLOR0; 
};

PS_OUTPUT PsSlurp(PS_INPUT In) : COLOR0
{
    PS_OUTPUT Out;

    float2 texUV = In.texCoord;

    float2 scrUV = texUV * rect_;

    float dist = distance(scrUV, pos_);
    float close = saturate(radius_ - dist);
    float ang = atan2(scrUV.y - pos_.y, scrUV.x - pos_.x);

    scrUV += float2(cos(ang), sin(ang)) * close * intn_;
    
    texUV = saturate(scrUV / rect_);
    float4 color = tex2D(sampler0_, texUV);

    bool bShow = texUV.x == 0 || texUV.y == 0 || texUV.x == 1 || texUV.y == 1; 
    color.rgb = lerp(color.rgb, 0, bShow);
	
    Out.color = color * In.diffuse;
    return Out;
}

technique TecSlurp
{
    pass P0
    {
        PixelShader = compile ps_3_0 PsSlurp();
    }
}