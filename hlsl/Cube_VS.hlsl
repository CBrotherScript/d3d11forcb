
cbuffer ConstantBuffer : register(b0)
{
    matrix g_World; // matrix可以用float4x4替代。不加row_major的情况下，矩阵默认为列主矩阵，
    matrix g_View;  // 可以在前面添加row_major表示行主矩阵
    matrix g_Proj;  // 该教程往后将使用默认的列主矩阵，但需要在C++代码端预先将矩阵进行转置。
    bool g_haveTexture;
    float4 g_color;
}

struct VertexIn
{
    float3 posL : POSITION;
    float2 texCoords : TEXCOORDS;
};

struct VertexOut
{
    float4 posH : SV_POSITION;
    float4 color : COLOR;
    float2 texCoords : TEXCOORDS;
};

VertexOut VS(VertexIn vIn)
{
    VertexOut vOut;
    vOut.posH = mul(float4(vIn.posL, 1.0f), g_World);  // mul 才是矩阵乘法, 运算符*要求操作对象为
    vOut.posH = mul(vOut.posH, g_View);               // 行列数相等的两个矩阵，结果为
    vOut.posH = mul(vOut.posH, g_Proj);               // Cij = Aij * Bij
    vOut.color = g_color;
    vOut.texCoords = vIn.texCoords;
    
    return vOut;
}
