
cbuffer CBChangesEveryFrame : register(b1)
{
    matrix g_View;  // 可以在前面添加row_major表示行主矩阵
    matrix g_Proj;  // 该教程往后将使用默认的列主矩阵，但需要在C++代码端预先将矩阵进行转置。
}

struct VertexPos
{
    float3 posL : POSITION;
};

struct VertexPosHL
{
    float4 posH : SV_POSITION;
    float3 posL : POSITION;
};


