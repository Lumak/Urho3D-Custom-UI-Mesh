#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"
#include "ScreenPos.hlsl"

uniform float2 cSpeedA;
uniform float cTiling;
uniform float cScaleParam;

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
    float2 deltaTexCoord = iTexCoord * cTiling + cSpeedA * cElapsedTimePS;
    float4 diffNoise = Sample2D(NormalMap, deltaTexCoord); // noise
    float4 areaMask1 = Sample2D(SpecMap, iTexCoord);       // fire area mask
    float4 vertMask2 = Sample2D(EmissiveMap, iTexCoord);   // vertical gradient mask

    // distortion
    float dist1 = (diffNoise.r + diffNoise.g) * 0.333 * cScaleParam ;
    dist1 *= areaMask1.r * vertMask2.r;
    float2 newTexCoord = iTexCoord + float2(0.0, dist1);

    // final
    float4 diffColor = cMatDiffColor * Sample2D(DiffMap, newTexCoord);

    #ifdef ALPHAMASK // not used
        if (diffColor.a < 0.5)
            discard;
    #endif

    oColor = diffColor;
}
