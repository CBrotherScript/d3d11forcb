
cbuffer VSGlobeBuffer : register(b0)
{
    matrix g_View;
    matrix g_Proj;
}

cbuffer VSBuffer : register(b2)
{
    float4x4 g_World;
    bool g_haveNormalTexture;
}

cbuffer PSBuffer : register(b3)
{
    float4 colorRGB;
    /*bool lightBlend;
    bool haveDiffuseTexture;
    bool haveSpecularTexture;
    bool haveNormalTexture;*/    
    bool haveDiffuseTexture;
    bool haveSpecularTexture;
    bool haveNormalTexture;
    bool lightBlend;
    float specularStrength;
    float shininessStrength;
}

#define MAX_BONES 200
cbuffer VSSkinnedBuffer : register(b4)
{
    float4x4 g_Bones[MAX_BONES];
}

struct VertexIn
{
    float3 posL : POSITION;
    float2 texCoords : TEXCOORDS;
    float3 normal : NORMAL;
    float3 aTangent : TANGENT;
    float3 aBitangent : BITANGENT;
};

struct VertexInSkinned
{
    float3 posL : POSITION;
    float2 texCoords : TEXCOORDS;
    float3 normal : NORMAL;
    float3 aTangent : TANGENT;
    float3 aBitangent : BITANGENT;
    float4 boneIDs : BONEIDS;
    float4 weights : WEIGHTS;
};

struct VertexOut
{
    float4 posH : SV_POSITION;
    float4 fragPos : POSITION;
    float2 texCoords : TEXCOORDS;
    float3 normal : NORMAL;
    float3x3 tbnMat3 : TBNMAT3;
};
