#include "Normal3D.hlsli"
#include "commonlight.hlsli"

Texture2D g_diffuseTexture : register(t0);
Texture2D g_specularTexture : register(t1);
Texture2D g_normalTexture : register(t2);
SamplerState g_SamLinear : register(s0);


// 像素着色器
float4 PS(VertexOut pIn) : SV_Target
{
    //return g_diffuseTexture.Sample(g_SamLinear, pIn.texCoords);
    //return float4(pointLightCount,0,0,1);
    //return float4(pIn.normal,1.0);
    //return ambientLightColor;
    if (lightBlend)
    {
        float4 ambient = CalcAmbientLight();
        float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
        float4 specular = float4(0.0f, 0.0f, 0.0f, 0.0f);
        float shadow = 1.0;

        float3 norm = pIn.normal;
        if (haveNormalTexture)
        {
            norm = normalize(mul(g_normalTexture.Sample(g_SamLinear, pIn.texCoords).rgb, pIn.tbnMat3) * 2.0 - 1.0);
        }

       // return ambientLightColor;
        //return float4(0, directionLightCount, 0, 1);

        for (int i = 0; i < pointLightCount; i++)
        {
            diffuse += CalcPointLight(i, norm, pIn.fragPos);
            specular += CalcPointLightSpecular(i, norm, pIn.fragPos);
        }

        for (int i = 0; i < directionLightCount; i++)
        {            
            diffuse += CalcDirectionLight(i, norm);
            if (haveSpecularTexture)
            {
                specular += CalcDirectionLightSpecular(i, norm, pIn.fragPos);
            }
        }
        
        shadow -= CalcDirectionLightShadow2(norm, pIn.fragPos);
        //shadow -= CalcDirectionLightShadow(0, norm, pIn.fragPos);
        //return CalcDirectionLightShadow(0,norm, pIn.fragPos);

        float4 res = float4(0.0f, 0.0f, 0.0f, 0.0f);
        if (haveDiffuseTexture)
        {
            //return diffuse;
            res = g_diffuseTexture.Sample(g_SamLinear, pIn.texCoords) * (ambient + diffuse * shadow);
        }
        else
        {
            res = colorRGB * (ambient + diffuse * shadow);
        }
        
        if (haveSpecularTexture)
        {
            res += g_specularTexture.Sample(g_SamLinear, pIn.texCoords) * (ambient + (specular + diffuse) * shadow);
        }

        return res;
    }

    if (haveDiffuseTexture)
    {
        return g_diffuseTexture.Sample(g_SamLinear, pIn.texCoords);
    }

    return colorRGB;
}
