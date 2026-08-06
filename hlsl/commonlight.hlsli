
#define D_POINT_LIGHTS 4
#define D_DIRECTION_LIGHTS 4

struct PointLight
{
	float3 lightPos;
	float4 diffuseColor;
	float4 specularColor;

	float constant;
	float lightLinear;
	float quadratic;
};

struct DirectionLight
{
	float3 direction;
	float4 diffuseColor;
	float4 specularColor;	

	matrix lightProjection;
	matrix lightView;
	int castShadows;
};

cbuffer CBLight : register(b1)
{
	float4 ambientLightColor;
	float3 viewPos;
	int pointLightCount;
	int directionLightCount;
	//int pointLightCount2;
	//float3 lightPos;
	PointLight pointLights[D_POINT_LIGHTS];
	DirectionLight directionLights[D_DIRECTION_LIGHTS];
}

Texture2D g_lightShadowMap1 : register(t5);
Texture2D g_lightShadowMap2 : register(t6);
Texture2D g_lightShadowMap3 : register(t7);
Texture2D g_lightShadowMap4 : register(t8);
SamplerComparisonState g_lightSamLinear : register(s5);

float4 CalcAmbientLight()
{
	return float4((ambientLightColor).xyz, 1.0);
	//return float4(0.1,0.1,0.1,1.0);
}

float4 CalcPointLight(int lightIdx, float3 normal, float4 fragPos)
{
	PointLight light = pointLights[lightIdx];
	float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);

	float3 lightDir = normalize(light.lightPos - fragPos.xyz);
	float diff = max(dot(normal, lightDir), 0.0);
	diffuse += diff * light.diffuseColor;

	//return float4(light.lightPos.x / 2.0f, light.lightPos.y / 2.0f, light.lightPos.z / 2.0f,1.0f);
	//return float4(light.lightPos / 12.0f,1.0f);
	//return diffuse;
	//return float4(1.0f,1.0f,1.0f,1.0f);

	if (light.constant > 0)
	{
		// attenuation
		float distance = length(light.lightPos - fragPos.xyz);
		float attenuation = 1.0 / (light.constant + light.lightLinear * distance + light.quadratic * (distance * distance));
		diffuse *= attenuation;
		diffuse.w = 1.0;
	}

	return diffuse;
}

float4 CalcPointLightSpecular(int lightIdx, float3 normal, float4 fragPos)
{
	PointLight light = pointLights[lightIdx];

	float3 lightDir = normalize(light.lightPos - fragPos.xyz);
	float3 viewDir = normalize(viewPos - fragPos.xyz);

	float3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininessStrength);
	return specularStrength * spec * light.specularColor;
}

float4 CalcDirectionLight(int lightIdx, float3 normal)
{
	DirectionLight light = directionLights[lightIdx];
	float3 lightDir = normalize(-light.direction);
	float diff = max(dot(normal, lightDir), 0.0);
	float4 diffuse = light.diffuseColor * diff;
	return diffuse;
}

float4 CalcDirectionLightSpecular(int lightIdx, float3 normal, float4 fragPos)
{
	DirectionLight light = directionLights[lightIdx];
	float3 lightDir = normalize(-light.direction);
	float3 viewDir = normalize(viewPos - fragPos.xyz);
	float3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininessStrength);
	float4 specular = light.specularColor * spec * specularStrength;
	return specular;
}

float4 CalcDirectionLightSpecular2(int lightIdx, float3 normal, float4 fragPos, float shStrength)
{
	DirectionLight light = directionLights[lightIdx];
	float3 lightDir = normalize(-light.direction);
	float3 viewDir = normalize(viewPos - fragPos.xyz);
	float3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), shStrength);
	float4 specular = light.specularColor * spec * specularStrength;
	return specular;
}

float GetLightShadowMapDepth(int castShadows, float2 projCoords, float depth, int2 pos)
{
	switch (castShadows)
	{
	case 1:return g_lightShadowMap1.SampleCmpLevelZero(g_lightSamLinear, projCoords, depth, pos).r;
	case 2:return g_lightShadowMap2.SampleCmpLevelZero(g_lightSamLinear, projCoords, depth, pos).r;
	case 3:return g_lightShadowMap3.SampleCmpLevelZero(g_lightSamLinear, projCoords, depth, pos).r;
	case 4:return g_lightShadowMap4.SampleCmpLevelZero(g_lightSamLinear, projCoords, depth, pos).r;
	}

	return 0.0;
}

float4 CalcDirectionLightShadow(int lightIdx, float3 normal, float4 fragPos)
{	
	DirectionLight light = directionLights[lightIdx];
	if (light.castShadows == 0)
	{
		return 0.0;
	}

	// CB 版矩阵按列主序直传（未转置），需用 mul(M, v) 列向量约定，
	// 与 Normal3D_VS.hlsl 中 mul(g_View, ...) 保持一致
	float4 fragPosLightSpace = mul(light.lightView, fragPos);
	fragPosLightSpace = mul(light.lightProjection, fragPosLightSpace);
	float3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	float currentDepth = projCoords.z;
	//return float4(fragPosLightSpace.x, projCoords.y, 0, 1);	
	
	projCoords = projCoords * 0.5 + 0.5;
	projCoords.y = 1.0 - projCoords.y;
	//projCoords.x = 1.0 - projCoords.x;
	//return float4(projCoords.x, projCoords.y, 0, 1);
	if (currentDepth > 1.0)
	{
		return 0.0;
	}

	normal = normalize(normal);
	float dotv = dot(normal, light.direction);
	if (dotv == 0)
	{
		//discard;
		return -1.0;
	}

	float bias = max(0.0005 * (1.0 - dotv), 0.002);

	//float closestDepth = g_lightShadowMap1.Sample(g_SamLinear, projCoords.xy).r;
	/*if (closestDepth >= 0.0 && closestDepth < 0.4)
		return float4(0, 1, 0, 1);
	else if(closestDepth >= 0.4 && closestDepth < 0.9)
		return float4(0, 0, 1, 1);*/
	/*if (closestDepth <= 0.0)
		return 0.0;*/
	
	//float shadow = currentDepth > closestDepth ? 1.0 : 0.0;
	//closestDepth += 1.0;
	//closestDepth /= 2.0;
	//return shadow;
	//return float4(projCoords.x, projCoords.y, 0, 1);
	/*if (projCoords.x < 0.5)
		return float4(0, 1, 0, 1);*/
	//return float4(closestDepth, 0, 0, 1);
	//return shadow;

	//float bias = max(0.000005 * (1.0 - dotv), 0.0000005);
	//float bias = 0.000002;

	//currentDepth -= bias;

	//return currentDepth;
	
	//float closestDepth = GetLightShadowMapDepth(light.castShadows, projCoords.xy);
	//float shadow = currentDepth - bias > closestDepth  ? 1.0 : 0.0;

	//float shadow = g_lightShadowMap1.SampleCmpLevelZero(g_lightSamLinear, projCoords.xy, currentDepth - bias, float2(0, 0)).r;

	//return shadow;

	float shadow = 0.0;
	for (float x = -1; x <= 1; x += 1)
	{
		for (float y = -1; y <= 1; y += 1)
		{
			float pcfDepth = GetLightShadowMapDepth(light.castShadows, projCoords.xy, currentDepth - bias,int2(x,y));
			shadow += pcfDepth;
		}
	}
	shadow /= 9.0;
	shadow *= light.diffuseColor.r;

	/*if (projCoords.z > 1.0)
		shadow = 0.0;*/
	/*else if(shadowsLightCount > 1)
		shadow = shadow / shadowsLightCount;*/

	return shadow;
}

float CalcDirectionLightShadow2(float3 normal, float4 fragPos)
{
	int cnt = 0;
	float allshadow = 0.0;
	for (int i = 0; i < directionLightCount; i++)
	{
		float shadow = CalcDirectionLightShadow(i, normal, fragPos);
		//if (shadow >= 0.0)
		{
			cnt++;
			allshadow += shadow;
		}
	}

	if (cnt > 0)
	{
		allshadow /= cnt;
	}

	return allshadow;
}

