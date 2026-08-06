#include "Normal3D.hlsli"

VertexOut VS(VertexInSkinned vIn)
{
	float4x4 BoneTransform = 
	{
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1
	};
	if (vIn.weights[0] > 0)
	{
		//BoneTransform = mul(vIn.weights[0],g_Bones[int(vIn.boneIDs[0])]);
		BoneTransform = g_Bones[int(vIn.boneIDs[0])] * vIn.weights[0];
	}
	if (vIn.weights[1] > 0)
	{
		BoneTransform += g_Bones[int(vIn.boneIDs[1])] * vIn.weights[1];
	}
	if (vIn.weights[2] > 0)
	{
		BoneTransform += g_Bones[int(vIn.boneIDs[2])] * vIn.weights[2];
	}
	if (vIn.weights[3] > 0)
	{
		BoneTransform = g_Bones[vIn.boneIDs[3]] * vIn.weights[3];
	}

    VertexOut vOut;
	vOut.fragPos = mul(float4(vIn.posL, 1.0f), BoneTransform);
    vOut.fragPos = mul(vOut.fragPos, g_World);  // mul 才是矩阵乘法, 运算符*要求操作对象为	
    vOut.posH = mul(vOut.fragPos, g_View);               // 行列数相等的两个矩阵，结果为
    vOut.posH = mul(vOut.posH, g_Proj);               // Cij = Aij * Bij
    
    vOut.texCoords = vIn.texCoords;

	float3x3 normalMatrix = (float3x3) mul(BoneTransform,g_World);
	vOut.normal = normalize(mul(vIn.normal, normalMatrix));

	if (g_haveNormalTexture)
	{
		float3 Tangent = normalize(mul(vIn.aTangent, normalMatrix));
		//normalize(normalMatrix * vIn.aTangent);
		float3 Bitangent = normalize(mul(vIn.aBitangent, normalMatrix));
		//normalize(normalMatrix * vIn.aBitangent);
		vOut.tbnMat3 = transpose(float3x3(Tangent, Bitangent, vOut.normal));
	}
    return vOut;
}
