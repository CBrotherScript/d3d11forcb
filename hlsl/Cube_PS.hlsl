
struct VertexOut
{
    float4 posH : SV_POSITION;
    float4 color : COLOR;
    float2 texCoords : TEXCOORDS;
};

Texture2D g_Tex : register(t0);
SamplerState g_SamLinear : register(s0);

// 像素着色器
float4 PS(VertexOut pIn) : SV_Target
{
    //return pIn.color;
    return g_Tex.Sample(g_SamLinear, pIn.texCoords);
}
