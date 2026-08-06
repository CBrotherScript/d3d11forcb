#include "Normal3D.hlsli"

VertexOut VS(VertexIn vIn)
{
    VertexOut vOut;
    //vOut.fragPos = mul(float4(vIn.posL, 1.0f), g_World);  // mul 才是矩阵乘法, 运算符*要求操作对象为
    //vOut.posH = mul(vOut.fragPos, g_View);               // 行列数相等的两个矩阵，结果为
    //vOut.posH = mul(vOut.posH, g_Proj);               // Cij = Aij * Bij

    vOut.fragPos = mul(g_World, float4(vIn.posL, 1.0f));
    vOut.posH = mul(g_View, vOut.fragPos);
    vOut.posH = mul(g_Proj, vOut.posH);

    
    float3x3 normalMatrix = (float3x3) g_World;

    vOut.texCoords = vIn.texCoords;
    vOut.normal = normalize(mul(normalMatrix, vIn.normal));
    //vOut.normal = vIn.normal;

    if (g_haveNormalTexture)
    {
        float3 Tangent = normalize(mul(normalMatrix,vIn.aTangent));
            //normalize(normalMatrix * vIn.aTangent);
        float3 Bitangent = normalize(mul(normalMatrix,vIn.aBitangent));
            //normalize(normalMatrix * vIn.aBitangent);
        vOut.tbnMat3 = transpose(float3x3(Tangent, Bitangent, vOut.normal));
    }

    return vOut;
}
