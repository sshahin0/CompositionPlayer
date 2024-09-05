// License: MIT
// Author: gre

#include <metal_stdlib>
#include "MTTransitionLib.h"

using namespace metalpetal;

fragment float4 BurnFragment(VertexOut vertexIn [[ stage_in ]],
                             texture2d<float, access::sample> fromTexture [[ texture(0) ]],
                             texture2d<float, access::sample> toTexture [[ texture(1) ]],
                             constant float3 & color [[ buffer(0) ]],
                             constant float & ratio [[ buffer(1) ]],
                             constant float & progress [[ buffer(2) ]],
                             sampler textureSampler [[ sampler(0) ]])
{
    float2 uv = vertexIn.textureCoordinate;
    uv.y = 1.0 - uv.y;
    float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
    float _toR = float(toTexture.get_width())/float(toTexture.get_height());
    
    return mix(getFromColor(uv, fromTexture, ratio, _fromR) + float4(progress*color, 1.0),
               getToColor(uv, toTexture, ratio, _toR) + float4((1.0-progress)*color, 1.0),
               progress
               );
}

