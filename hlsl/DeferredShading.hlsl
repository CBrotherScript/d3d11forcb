#include "Basic_2D.hlsli"

cbuffer PSBuffer : register(b3)
{
    float4 colorRGB;
    bool haveDiffuseTexture;
    bool haveSpecularTexture;
    bool haveNormalTexture;
    bool lightBlend;
    float specularStrength;
    float shininessStrength;
}

#include "commonlight.hlsli"

Texture2D gPosition : register(t0);
Texture2D gNormal : register(t1);
Texture2D gColor : register(t2);
Texture2D gSpecular : register(t3);
SamplerState g_SamLinear : register(s0);

float4 PS(VertexOut pIn) : SV_Target
{
    /*float2 gbufferDim;
    uint dummy;
    gPosition.GetDimensions(gbufferDim.x, gbufferDim.y, dummy);

    // retrieve data from gbuffer
    float4 FragPos = float4(gPosition.Load(uint2(pIn.texCoords),1).rgb,1.0);
    float3 norm = gNormal.Load(pIn.texCoords,1).rgb;
    float4 Diffuse = gColor.Load(pIn.texCoords,1);
    float4 Specular = float4(gSpecular.Load(pIn.texCoords,1).rgb,1.0);
    bool lightBlendThis = gSpecular.Load(pIn.texCoords,1).a > 0.0;
    float shStrength = gNormal.Load(pIn.texCoords,1).a;*/
    
    float4 FragPos = float4(gPosition.Sample(g_SamLinear, pIn.texCoords).rgb, 1.0);
    float3 norm = gNormal.Sample(g_SamLinear, pIn.texCoords).rgb;
    float4 Diffuse = gColor.Sample(g_SamLinear, pIn.texCoords);
    float4 Specular = float4(gSpecular.Sample(g_SamLinear, pIn.texCoords).rgb, 1.0);
    bool lightBlendThis = gSpecular.Sample(g_SamLinear, pIn.texCoords).a > 0.0;
    float shStrength = gNormal.Sample(g_SamLinear, pIn.texCoords).a;
    float dflag = gPosition.Sample(g_SamLinear, pIn.texCoords).w;

    //return Diffuse;
    //return float4(lightBlendThis,0,0,1);

    /*return FragPos;

    if(pIn.texCoords.x < 0.5)
        return float4(1, 1, 0, 1);
    
    return float4(1, 0, 0, 1);
    //return Diffuse;
    return float4(lightBlendThis,0,0,1.0);*/
    //return float4(ccc,0,0,1);

    //return float4(norm,1);

    if (dflag == 0)
        discard;

    if (!lightBlendThis)
    {
        return Diffuse;
    }

    float4 ambient = CalcAmbientLight();
    float4 diffuse = float4(0,0,0,0);
    float4 specular = float4(0,0,0,0);
    float shadow = 1.0;
    bool haveSpecularTexture = Specular.rgb != float3(0,0,0);

    for (int i = 0; i < pointLightCount; i++)
    {
        diffuse += CalcPointLight(i, norm, FragPos);
        //specular += CalcPointLightSpecular(i, norm, FragPos,viewPos);
    }

    for (int i = 0; i < directionLightCount; i++)
    {
        diffuse += CalcDirectionLight(i, norm);
        if (haveSpecularTexture)
        {
            specular += CalcDirectionLightSpecular2(i, norm, FragPos, shStrength);
        }
    }

    //return diffuse;

    shadow -= CalcDirectionLightShadow2(norm, FragPos);

    float4 res = Diffuse * (ambient + diffuse * shadow);

    if (haveSpecularTexture)
    {
        res += Specular * (ambient + (specular + diffuse) * shadow);
    }

    return res;
}
