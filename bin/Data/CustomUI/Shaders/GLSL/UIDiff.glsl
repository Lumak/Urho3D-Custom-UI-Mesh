#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Fog.glsl"

varying vec2 vTexCoord;
varying vec4 vWorldPos;
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
    vec4 diffColor = cMatDiffColor * texture2D(sDiffMap, vTexCoord);

    #ifdef ALPHAMASK // not used
        if (diffColor.a < 0.5)
            discard;
    #endif

    #ifdef VERTEXCOLOR
        diffColor *= vColor;
    #endif

    gl_FragColor = diffColor;
}
