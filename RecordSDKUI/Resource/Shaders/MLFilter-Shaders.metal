//
//  Shaders.metal
//  Pods
//
//  Created by Yu Ao on 30/11/2017.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"

using namespace metal;
using namespace metalpetal;

fragment float4 filterKitHorizontalSlidingShader(VertexOut vertexIn [[ stage_in ]],
                            texture2d<float, access::sample> aTexture [[ texture(0) ]],
                            sampler aSampler [[ sampler(0) ]],
                            texture2d<float, access::sample> bTexture [[ texture(1) ]],
                            sampler bSampler [[ sampler(1) ]],
                            constant float &offset [[buffer(0)]]
                            ) {
    float4 pic0 = aTexture.sample(aSampler, vertexIn.textureCoordinate);
    float4 pic1 = bTexture.sample(bSampler, vertexIn.textureCoordinate);
    
    float mixFactor = clamp(abs((vertexIn.textureCoordinate.x - offset)/0.01),0.0,1.0);
    
    if (vertexIn.textureCoordinate.x >= offset && vertexIn.textureCoordinate.x <= offset + 1.0) {
        return mix(pic0,pic1,mixFactor);
    } else {
        return pic0;
    }
}

fragment float4 filterKitVerticalSlidingShader(VertexOut vertexIn [[ stage_in ]],
                                                 texture2d<float, access::sample> aTexture [[ texture(0) ]],
                                                 sampler aSampler [[ sampler(0) ]],
                                                 texture2d<float, access::sample> bTexture [[ texture(1) ]],
                                                 sampler bSampler [[ sampler(1) ]],
                                                 constant float &offset [[buffer(0)]]
                                                 ) {
    float4 pic0 = aTexture.sample(aSampler, vertexIn.textureCoordinate);
    float4 pic1 = bTexture.sample(bSampler, vertexIn.textureCoordinate);
    
    float mixFactor = clamp(abs((vertexIn.textureCoordinate.y - offset)/0.01),0.0,1.0);
    
    if (vertexIn.textureCoordinate.y >= offset && vertexIn.textureCoordinate.y <= offset + 1.0) {
        return mix(pic0,pic1,mixFactor);
    } else {
        return pic0;
    }
    
}

fragment float4 videoGiftShader(
                                VertexOut vertexIn [[stage_in]],
                                texture2d<float, access::sample> textureInput [[texture(0)]],
                                sampler textureInputSampler [[sampler(0)]]
                                )
{
    float4 color1 = textureInput.sample(textureInputSampler, float2(vertexIn.textureCoordinate.x / 2.0, vertexIn.textureCoordinate.y));
    float4 color2 = textureInput.sample(textureInputSampler, float2(vertexIn.textureCoordinate.x / 2.0 + 0.5, vertexIn.textureCoordinate.y));
    color2.a = color1.r;
    return color2;
}

