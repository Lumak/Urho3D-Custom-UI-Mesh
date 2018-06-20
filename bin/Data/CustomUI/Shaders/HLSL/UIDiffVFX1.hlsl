#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"
#include "ScreenPos.hlsl"
#include "Fog.hlsl"

uniform float2 cSpeedA;
uniform float2 cSpeedB;
uniform float cUseCircularMask;

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
    float4 circMask = Sample2D(DiffMap, iTexCoord);
    if (cUseCircularMask > 0.0 && circMask.r < 0.5)
        discard;

    float2 texCoordA = iTexCoord * 0.5 + cElapsedTimePS * cSpeedA;
    float2 texCoordB = iTexCoord * 1.5 + cElapsedTimePS * cSpeedB;
    float noiseMask1 = Sample2D(EmissiveMap, texCoordA).r;
    float noiseMask2 = Sample2D(EmissiveMap, texCoordB).r;
    float combMask = noiseMask1 * noiseMask2 * 2.0;

    float4 specColor = cMatSpecColor * Sample2D(SpecMap, iTexCoord);
    specColor *= specColor.a;
    float4 diffColor = combMask * (cMatDiffColor + specColor);

    #ifdef ALPHAMASK // not used
        if (diffColor.a < 0.5)
            discard;
    #endif

    #ifdef VERTEXCOLOR
        diffColor *= vColor;
    #endif

    oColor = diffColor;
}
