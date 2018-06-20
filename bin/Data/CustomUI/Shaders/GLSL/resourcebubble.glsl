#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec4 vWorldPos;

uniform sampler2D sGlass0;
uniform sampler2D sClip1;
uniform sampler2D sNoise2;
uniform sampler2D sNormalTex3;
uniform sampler2D sStars4;

uniform float cLevel;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetTexCoord(iTexCoord);

    vWorldPos = vec4(worldPos, GetDepth(gl_Position));
}

void PS()
{
    float level=1.0-cLevel;
    vec2 newuv=texture(sNormalTex3, vTexCoord).xy;
    float clip=texture(sClip1, vTexCoord).x;
    if (clip < 0.5)
        discard;

    float maskval=vTexCoord.y+texture(sNoise2, vTexCoord+vec2(0.1,0.3)*cElapsedTimePS).x * 0.05;
    float mask=smoothstep(level-0.01, level+0.01, maskval);
    float glowline=min(smoothstep(level-0.05, level, maskval), smoothstep(level+0.05, level, maskval))*clip*5.0+1.0;

    gl_FragColor=clip * mask * texture(sStars4, newuv + vec2(0.1,0.0)*cElapsedTimePS) *
        texture(sStars4, newuv + vec2(0.0107,0.0313)*cElapsedTimePS) * 
        texture(sStars4, newuv + vec2(-0.0132,-0.021)*cElapsedTimePS) * 4.0 * glowline + texture(sGlass0, vTexCoord);
}