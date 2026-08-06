
struct VertexIn
{
    float3 posL : POSITION;
    float2 texCoords : TEXCOORDS;
};

struct VertexOut
{
    float4 posH : SV_POSITION;
    float2 texCoords : TEXCOORDS;
};
