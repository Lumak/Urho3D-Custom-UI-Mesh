#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Fog.glsl"

varying vec2 vTexCoord;
varying vec4 vWorldPos;

//#ifdef COMPILEPS
uniform vec2 cSpeedA;
uniform float cTiling;
uniform float cScaleParam;
//#endif

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
    vec2 deltaTexCoord = vTexCoord * cTiling + cSpeedA * cElapsedTimePS;
    vec4 diffNoise = texture2D(sNormalMap, deltaTexCoord); // noise
    vec4 areaMask1 = texture2D(sSpecMap, vTexCoord);       // fire area mask
    vec4 vertMask2 = texture2D(sEmissiveMap, vTexCoord);   // vertical gradient mask

    // distortion
    float dist1 = (diffNoise.r + diffNoise.g) * 0.333 * cScaleParam;
    dist1 *= areaMask1.r * vertMask2.r;
    vec2 newTexCoord = vTexCoord + vec2(0, dist1);

    // final
    vec4 diffColor = cMatDiffColor * texture2D(sDiffMap, newTexCoord);

    #ifdef ALPHAMASK // not used
        if (diffColor.a < 0.5)
            discard;
    #endif

    gl_FragColor = diffColor;
}
