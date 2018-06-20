#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"
#include "ScreenPos.hlsl"

uniform float cLevel;

void VS(float4 iPos : POSITION,
        float2 iTexCoord : TEXCOORD0,
    out float2 oTexCoord : TEXCOORD0,
    out float4 oWorldPos : TEXCOORD2,
    out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;
    float3 worldPos = GetWorldPos(modelMatrix);
    oPos = GetClipPos(worldPos);
    oTexCoord = GetTexCoord(iTexCoord);
    oWorldPos = float4(worldPos, GetDepth(oPos));
}

void PS(float2 iTexCoord : TEXCOORD0,
        float4 iWorldPos: TEXCOORD2,
        out float4 oColor : OUTCOLOR0)
{
    float level=1.0-cLevel;
    float2 newuv=Sample2D(EmissiveMap, iTexCoord).xy;
    float clip=Sample2D(NormalMap, iTexCoord).x;
    if (clip < 0.5)
        discard;

    float maskval=iTexCoord.y+Sample2D(SpecMap, iTexCoord+float2(0.1,0.3)*cElapsedTimePS).x * 0.05;
    float mask=smoothstep(level-0.01, level+0.01, maskval);
    float glowline=min(smoothstep(level-0.05, level, maskval), smoothstep(level+0.05, level, maskval))*clip*5.0+1.0;

    oColor = clip * mask * Sample2D(EnvMap, newuv + float2(0.1,0.0)*cElapsedTimePS) *
        Sample2D(EnvMap, newuv + float2(0.0107,0.0313)*cElapsedTimePS) * 
        Sample2D(EnvMap, newuv + float2(-0.0132,-0.021)*cElapsedTimePS) * 4.0 * glowline + Sample2D(DiffMap, iTexCoord);
}