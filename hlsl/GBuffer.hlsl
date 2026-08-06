#include "Normal3D.hlsli"
#include "commonlight.hlsli"

Texture2D g_diffuseTexture : register(t0);
Texture2D g_specularTexture : register(t1);
Texture2D g_normalTexture : register(t2);
SamplerState g_SamLinear : register(s0);

struct GBuffer
{
    float4 gPosition : SV_Target0;
    float4 gNormal : SV_Target1;
    float4 gColor : SV_Target2;
    float4 gSpecular : SV_Target3;
};

// 像素着色器
void PS(VertexOut pIn, out GBuffer outputGBuffer)
{
    outputGBuffer.gPosition.xyz = pIn.fragPos.xyz;
    outputGBuffer.gPosition.w = 1;

    float3 norm = pIn.normal;
    if (haveNormalTexture)
    {
        norm = normalize(mul(g_normalTexture.Sample(g_SamLinear, pIn.texCoords).rgb, pIn.tbnMat3) * 2.0 - 1.0);
    }

    outputGBuffer.gNormal = float4(norm, shininessStrength);

    /*if (haveNormalTexture)
    {
        outputGBuffer.gNormal = float4(normalize(mul(g_normalTexture.Sample(g_SamLinear, pIn.texCoords).rgb, pIn.tbnMat3) * 2.0 - 1.0), shininessStrength);
    }
    else
    {
        outputGBuffer.gNormal = float4(normalize(pIn.normal), shininessStrength);
    }*/

    if (haveDiffuseTexture)
    {
        outputGBuffer.gColor = g_diffuseTexture.Sample(g_SamLinear, pIn.texCoords);
    }
    else
    {
        outputGBuffer.gColor = colorRGB;
    }

    if (haveSpecularTexture)
    {
        outputGBuffer.gSpecular = float4(g_specularTexture.Sample(g_SamLinear, pIn.texCoords).rgb * specularStrength, lightBlend ? 1.0 : 0.0);
    }
    else
    {
        outputGBuffer.gSpecular = float4(0.0, 0.0, 0.0, lightBlend ? 1.0 : 0.0);
    }
}
