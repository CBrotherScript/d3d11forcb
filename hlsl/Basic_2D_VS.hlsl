#include "Basic_2D.hlsli"

VertexOut VS(VertexIn vIn)
{
    VertexOut vOut;
    vOut.posH = float4(vIn.posL, 1.0f);
    vOut.texCoords = vIn.texCoords;
    return vOut;
}
