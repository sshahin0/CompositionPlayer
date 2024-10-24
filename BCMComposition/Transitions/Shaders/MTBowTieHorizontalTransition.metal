// Author: huynx
// License: MIT

#include <metal_stdlib>
#include "MTTransitionLib.h"

using namespace metalpetal;

float horizontal_check(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool PointInTriangle (float2 pt, float2 p1, float2 p2, float2 p3) {
    bool b1, b2, b3;
    b1 = horizontal_check(pt, p1, p2) < 0.0;
    b2 = horizontal_check(pt, p2, p3) < 0.0;
    b3 = horizontal_check(pt, p3, p1) < 0.0;
    return ((b1 == b2) && (b2 == b3));
}

bool in_left_triangle(float2 p, float progress){
    float2 vertex1, vertex2, vertex3;
    vertex1 = float2(progress, 0.5);
    vertex2 = float2(0.0, 0.5-progress);
    vertex3 = float2(0.0, 0.5+progress);
    if (PointInTriangle(p, vertex1, vertex2, vertex3)) {
        return true;
    }
    return false;
}

bool in_right_triangle(float2 p, float progress){
    float2 vertex1, vertex2, vertex3;
    vertex1 = float2(1.0-progress, 0.5);
    vertex2 = float2(1.0, 0.5-progress);
    vertex3 = float2(1.0, 0.5+progress);
    if (PointInTriangle(p, vertex1, vertex2, vertex3)) {
        return true;
    }
    return false;
}

float horizontal_blur_edge(float2 bot1, float2 bot2, float2 top, float2 testPt) {
    float2 lineDir = bot1 - top;
    float2 perpDir = float2(lineDir.y, -lineDir.x);
    float2 dirToPt1 = bot1 - testPt;
    float dist1 = abs(dot(normalize(perpDir), dirToPt1));

    lineDir = bot2 - top;
    perpDir = float2(lineDir.y, -lineDir.x);
    dirToPt1 = bot2 - testPt;
    float min_dist = min(abs(dot(normalize(perpDir), dirToPt1)), dist1);

    if (min_dist < 0.005) {
        return min_dist / 0.005;
    } else {
        return 1.0;
    }
}

fragment float4 BowTieHorizontalFragment(VertexOut vertexIn [[ stage_in ]],
                                         texture2d<float, access::sample> fromTexture [[ texture(0) ]],
                                         texture2d<float, access::sample> toTexture [[ texture(1) ]],
                                         constant float & ratio [[ buffer(0) ]],
                                         constant float & progress [[ buffer(1) ]],
                                         sampler textureSampler [[ sampler(0) ]])
{
    float2 uv = vertexIn.textureCoordinate;
    uv.y = 1.0 - uv.y;
    float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
    float _toR = float(toTexture.get_width())/float(toTexture.get_height());
    
    if (in_left_triangle(uv, progress)) {
        if (progress < 0.1) {
            return getFromColor(uv, fromTexture, ratio, _fromR);
        }
        if (uv.x < 0.5) {
            float2 vertex1 = float2(progress, 0.5);
            float2 vertex2 = float2(0.0, 0.5-progress);
            float2 vertex3 = float2(0.0, 0.5+progress);
            return mix(
                       getFromColor(uv, fromTexture, ratio, _fromR),
                       getToColor(uv, toTexture, ratio, _toR),
                       horizontal_blur_edge(vertex2, vertex3, vertex1, uv)
                       );
        } else {
            if (progress > 0.0) {
                return getToColor(uv, toTexture, ratio, _toR);
            } else {
                return getFromColor(uv, fromTexture, ratio, _fromR);
            }
        }
    } else if (in_right_triangle(uv, progress)) {
        if (uv.x >= 0.5) {
            float2 vertex1 = float2(1.0-progress, 0.5);
            float2 vertex2 = float2(1.0, 0.5-progress);
            float2 vertex3 = float2(1.0, 0.5+progress);
            return mix(
                       getFromColor(uv, fromTexture, ratio, _fromR),
                       getToColor(uv, toTexture, ratio, _toR),
                       horizontal_blur_edge(vertex2, vertex3, vertex1, uv)
                       );
        } else {
            return getFromColor(uv, fromTexture, ratio, _fromR);
        }
    } else {
        return getFromColor(uv, fromTexture, ratio, _fromR);
    }
}
