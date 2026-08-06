#include "Basic_2D.hlsli"

Texture2D g_Tex : register(t0);
SamplerState g_SamLinear : register(s0);

float4 PS(VertexOut pIn) : SV_Target
{
    // ===== 调试阴影深度图：R24 深度只在 .r 通道，扩成灰度显示 =====
    // 调试完成后恢复下面那行正常采样
    //float depth = g_Tex.Sample(g_SamLinear, pIn.texCoords).r;
    //return float4(depth.rrr, 1.0f);

    return g_Tex.Sample(g_SamLinear, pIn.texCoords);
//return float4(1.0, 0, 0, 1.0);
}
