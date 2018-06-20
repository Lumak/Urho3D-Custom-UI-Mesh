#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"
#include "ScreenPos.hlsl"

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
    float4 diffColor = cMatDiffColor * Sample2D(DiffMap, iTexCoord);

    #ifdef ALPHAMASK // not used
        if (diffColor.a < 0.5)
            discard;
    #endif

    #ifdef VERTEXCOLOR
        diffColor *= iColor;
    #endif

    oColor = diffColor;
}
