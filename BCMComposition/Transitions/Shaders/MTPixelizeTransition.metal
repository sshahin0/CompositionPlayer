// Author: gre
// License: MIT
// forked from https://gist.github.com/benraziel/c528607361d90a072e98

#include <metal_stdlib>
#include "MTTransitionLib.h"

using namespace metalpetal;

fragment float4 PixelizeFragment(VertexOut vertexIn [[ stage_in ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(1) ]],
                                 constant uint2 & squaresMin [[ buffer(0) ]],
                                 constant int & steps [[ buffer(1) ]],
                                 constant float & ratio [[ buffer(2) ]],
                                 constant float & progress [[ buffer(3) ]],
                                 sampler textureSampler [[ sampler(0) ]])
{
    float2 uv = vertexIn.textureCoordinate;
    uv.y = 1.0 - uv.y;
    float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
    float _toR = float(toTexture.get_width())/float(toTexture.get_height());
    
    float d = min(progress, 1.0 - progress);
    float dist = steps >0 ? ceil(d * float(steps)) / float(steps) : d;
    float2 squareSize = 2.0 * dist / float2(squaresMin);
    float2 p = dist>0.0 ? (floor(uv / squareSize) + 0.5) * squareSize : uv;
    return mix(getFromColor(p, fromTexture, ratio, _fromR),
               getToColor(p, toTexture, ratio, _toR),
               progress);
}
