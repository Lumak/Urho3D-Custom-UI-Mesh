#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Fog.glsl"

varying vec2 vTexCoord;
varying vec4 vWorldPos;

uniform vec2 cSpeedA;
uniform vec2 cSpeedB;

#ifdef VERTEXCOLOR
    varying vec4 vColor;
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetTexCoord(iTexCoord);
    vWorldPos = vec4(worldPos, GetDepth(gl_Position));

    #ifdef VERTEXCOLOR
        vColor = iColor;
    #endif
}

void PS()
{
    vec2 texCoordA = vTexCoord * 0.6 + cElapsedTimePS * cSpeedA;
    vec2 texCoordB = vTexCoord * 0.4 + cElapsedTimePS * cSpeedB;

    vec4 diffMask1 = texture2D(sSpecMap, texCoordA);
    vec4 diffMask2 = texture2D(sSpecMap, texCoordB + diffMask1.rg * 0.4);
    vec4 diffMask3 = texture2D(sEmissiveMap, vTexCoord);

    vec4 diffColor0 = texture2D(sDiffMap, texCoordA + diffMask1.rg * 0.4);
    vec4 diffColor1 = texture2D(sDiffMap, texCoordB + diffMask1.rg * 0.4);
    vec4 diffColor = cMatDiffColor * (diffColor0 + diffColor1);

    diffColor *= diffMask1.r * diffMask2.r * diffMask3.r * 4.0;

    gl_FragColor = diffColor;
}
