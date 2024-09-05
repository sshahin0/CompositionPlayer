//
//  MTFadeInWipeLeftTransition.metal
//  MTTransitions
//
//  Created by Nazmul on 04/08/2022.
//

#include <metal_stdlib>
#include "MTTransitionLib.h"

using namespace metalpetal;

fragment float4 FadeInWipeLeftFragment(VertexOut vertexIn [[ stage_in ]],
                            texture2d<float, access::sample> fromTexture [[ texture(0) ]],
                            texture2d<float, access::sample> toTexture [[ texture(1) ]],
                            constant float & ratio [[ buffer(0) ]],
                            constant float & progress [[ buffer(1) ]],
                           
                                         sampler textureSampler [[ sampler(0) ]])
{
    float2 uv = vertexIn.textureCoordinate;
    uv.y = 1.0 - uv.y;
    float2 _uv = uv;
    float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
    float _toR = float(toTexture.get_width())/float(toTexture.get_height());
    
    _uv.x -= progress;
    
    if(uv.x >= progress)
    {
        return getFromColor(_uv, fromTexture, ratio, _fromR);
    }
    
    float4 a = getFromColor(uv, fromTexture, ratio, _fromR);
    float4 b = getToColor(uv, toTexture, ratio, _toR);
    return mix(a, b, progress);
}





