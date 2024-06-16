///////////////////////////////////////////////////////////////
/////////////////// Particle List Rect Shift //////////////////
///////////////////////////////////////////////////////////////

// Uses particle list extra data 1 and 2 to shift the x and y coordinates of the source rect respectively; uses extra data 3 and the z scale to determine the x and y scale of the source rect respectively


sampler sampler0_ : register(s0);

// The 4-by-4 matrix linked to WORLDVIEWPROJ semantic is provided by the engine.
// It is used to transform world coordinates to device coordinates.
float4x4 g_mWorldViewProj : WORLDVIEWPROJ : register(c0);

float stepX_; // width / maxWidth
float stepY_; // height / maxHeight


struct VS_INPUT
{
	//Vertex data
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
	
	//Instance data
	float4 i_color	            : COLOR1;
	float4 i_xyz_pos_x_scale 	: TEXCOORD1;	// Pack: (x pos, y pos, z pos, x scale)
	float4 i_yz_scale_xy_ang 	: TEXCOORD2;	// Pack: (y scale, z scale, x angle, y angle)
	float4 i_z_ang_extra		: TEXCOORD3;	// Pack: (z angle, extra 1, extra 2, extra 3)
};

struct PS_INPUT
{
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
};


PS_INPUT VsMain(VS_INPUT inVs)
{
	PS_INPUT outVs;
	
	float2 scaleMul = float2(inVs.i_yz_scale_xy_ang.y, inVs.i_z_ang_extra.w);
	
	float3 t_scale = float3(inVs.i_xyz_pos_x_scale.w, inVs.i_yz_scale_xy_ang.xy);
	t_scale.xy *= scaleMul;
	
	float2 ax = float2(sin(inVs.i_yz_scale_xy_ang.z), cos(inVs.i_yz_scale_xy_ang.z));
	float2 ay = float2(sin(inVs.i_yz_scale_xy_ang.w), cos(inVs.i_yz_scale_xy_ang.w));
	float2 az = float2(sin(inVs.i_z_ang_extra.x), cos(inVs.i_z_ang_extra.x));
	
	// Creates the transformation matrix
	float4x4 matInstance = float4x4(
		float4(
			t_scale.x * ay.y * az.y - ax.x * ay.x * az.x,
			t_scale.x * -ax.y * az.x,
			t_scale.x * ay.x * az.y + ax.x * ay.y * az.x,
			0
		),
		float4(
			t_scale.y * ay.y * az.x + ax.x * ay.x * az.y,
			t_scale.y * ax.y * az.y,
			t_scale.y * ay.x * az.x - ax.x * ay.y * az.y,
			0
		),
		float4(
			t_scale.z * -ax.y * ay.x,
			t_scale.z * ax.x,
			t_scale.z * ax.y * ay.y,
			0
		),
		float4(inVs.i_xyz_pos_x_scale.xyz, 1)
	);

	outVs.diffuse = inVs.diffuse * inVs.i_color;
	outVs.texCoord = inVs.texCoord + float2(stepX_ * inVs.i_z_ang_extra.y, stepY_ * inVs.i_z_ang_extra.z);
	outVs.texCoord *= scaleMul;
	outVs.position = mul(inVs.position, matInstance);
	outVs.position = mul(outVs.position, g_mWorldViewProj);
	outVs.position.z = 1.0f;

	return outVs;
}

float4 PsMain(PS_INPUT inPs) : COLOR0
{
	float4 color = tex2D(sampler0_, inPs.texCoord) * inPs.diffuse;
	return color;
}


technique TecRender
{
	pass P0
	{
		VertexShader = compile vs_3_0 VsMain();
		PixelShader  = compile ps_3_0 PsMain();
	}
}