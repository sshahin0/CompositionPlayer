// Author: Paweł Płóciennik
// License: MIT

#include <metal_stdlib>
#include "MTTransitionLib.h"

using namespace metalpetal;

fragment float4 WaterDropFragment(VertexOut vertexIn [[ stage_in ]],
                                  texture2d<float, access::sample> fromTexture [[ texture(0) ]],
                                  texture2d<float, access::sample> toTexture [[ texture(1) ]],
                                  constant float & speed [[ buffer(0) ]],
                                  constant float & amplitude [[ buffer(1) ]],
                                  constant float & ratio [[ buffer(2) ]],
                                  constant float & progress [[ buffer(3) ]],
                                  sampler textureSampler [[ sampler(0) ]])
{
    float2 uv = vertexIn.textureCoordinate;
    uv.y = 1.0 - uv.y;
    float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
    float _toR = float(toTexture.get_width())/float(toTexture.get_height());
    
    float2 center = float2(0.5 * xRatio(ratio), 0.5 * yRatio(ratio));
    float2 dir = float2(uv.x * xRatio(ratio), uv.y * yRatio(ratio)) - center;
    float dist = length(dir);
    
    if (dist > progress) {
        return mix(
                   getFromColor(uv, fromTexture, ratio, _fromR),
                   getToColor(uv, fromTexture, ratio, _toR),
                   progress
                   );
    } else {
        float2 offset = dir * sin(dist * amplitude - progress * speed);
        return mix(
                   getFromColor(uv + offset, fromTexture, ratio, _fromR),
                   getToColor(uv, toTexture, ratio, _toR),
                   progress);
    }
}
