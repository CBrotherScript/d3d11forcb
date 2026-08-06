#include "Skybox.hlsli"

VertexPosHL VS(VertexPos vIn)
{
    VertexPosHL vOut;
    
    // 设置z = w使得z/w = 1(天空盒保持在远平面)
    // 注意：本文件矩阵为 glm 列主序、上传时未转置（与正常网格一致），
    // 故用 mul(M, v)（矩阵在左），不能用 C++ 的 mul(v, M)（C++ 上传前做了转置）。
    float4 posH = mul(g_View, float4(vIn.posL, 1.0f));
    posH = mul(g_Proj, posH);

    vOut.posH = posH.xyww;
    vOut.posL = vIn.posL;
    return vOut;
}
