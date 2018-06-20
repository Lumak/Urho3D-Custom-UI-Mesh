#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"
#include "ScreenPos.hlsl"
#include "Fog.hlsl"

uniform float2 cSpeedA;
uniform float2 cSpeedB;

void VS(float4 iPos : POSITION,
        float2 iTexCoord : TEXCOORD0,
    #ifdef VERTEXCOLOR
        float4 iColor : COLOR0,
    #endif
    out float2 oTexCoord : TEXCOORD0,
    out float4 oWorldPos : TEXCOORD2,
    #ifdef VERTEXCOLOR
        out float4 oColor : COLOR0,
    #endif
    out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;
    float3 worldPos = GetWorldPos(modelMatrix);
    oPos = GetClipPos(worldPos);
    oTexCoord = GetTexCoord(iTexCoord);
    oWorldPos = float4(worldPos, GetDepth(oPos));

    #ifdef VERTEXCOLOR
        oColor = iColor;
    #endif
}

void PS(float2 iTexCoord : TEXCOORD0,
        float4 iWorldPos: TEXCOORD2,
    #ifdef VERTEXCOLOR
        float4 iColor : COLOR0,
    #endif
        out float4 oColor : OUTCOLOR0)
{
    float2 texCoordA = iTexCoord * 0.6 + cElapsedTimePS * cSpeedA;
    float2 texCoordB = iTexCoord * 0.4 + cElapsedTimePS * cSpeedB;

    float4 diffMask1 = Sample2D(SpecMap, texCoordA);
    float4 diffMask2 = Sample2D(SpecMap, texCoordB + diffMask1.rg * 0.4);
    float4 diffMask3 = Sample2D(EmissiveMap, iTexCoord);

    float4 diffColor0 = Sample2D(DiffMap, texCoordA + diffMask1.rg * 0.4);
    float4 diffColor1 = Sample2D(DiffMap, texCoordB + diffMask1.rg * 0.4);
    float4 diffColor = cMatDiffColor * (diffColor0 + diffColor1);

    diffColor *= diffMask1.r * diffMask2.r * diffMask3.r * 4.0;

    oColor = diffColor;
}
