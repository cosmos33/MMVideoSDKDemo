//
//  MDRecordShaders.metal
//  MDRecordSDK
//
//  Created by sunfei on 2021/2/24.
//  Copyright © 2021 sunfei. All rights reserved.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"

using namespace metal;
using namespace metalpetal;

namespace mmvideosdk {
    fragment float4 graffitiComposeFrag(VertexOut in [[ stage_in ]],
                                        texture2d<float, access::sample> graffitiComposeTexture [[ texture(0) ]],
                                        sampler graffitiComposeSampler [[ sampler(0) ]],
                                        texture2d<float, access::sample> pixellateTexture [[ texture(1) ]],
                                        sampler pixellateSampler [[ sampler(1) ]],
                                        texture2d<float, access::sample> mosaicTexture [[ texture(2) ]],
                                        sampler mosaicSampler [[ sampler(2) ]] ) {
        float4 graffitiComposeColor = graffitiComposeTexture.sample(graffitiComposeSampler, in.textureCoordinate);
        float4 pixellateColor = pixellateTexture.sample(pixellateSampler, in.textureCoordinate);
        float4 mosaicColor = mosaicTexture.sample(mosaicSampler, in.textureCoordinate);
        
        if (mosaicColor.r == 0.0) {
            return mix(graffitiComposeColor, pixellateColor, mosaicColor.a);
        } else {
            return graffitiComposeColor;
        }
    }
    
    METAL_FUNC float rng2(float2 seed, float time) {
        return fract(sin(dot(seed * floor(time * 12.0), float2(127.1,311.7))) * 43758.5453123);
    }
    
    METAL_FUNC float rng(float seed, float time) {
        return rng2(float2(seed, 1.0), time);
    }
    
    fragment float4 artifact(VertexOut in [[ stage_in ]],
                      texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                      sampler inputSampler [[ sampler(0) ]],
                      constant float &colorization [[ buffer(0) ]],
                      constant float &noise [[ buffer(1) ]],
                      constant float &parasite [[ buffer(2) ]],
                      constant float &fade [[ buffer(3) ]],
                      constant float &time [[ buffer(4) ]]
                      ) {
        float2 uv = in.textureCoordinate;
        float2 blockS = floor(uv * float2(24.0,9.0));
        float2 blockL = floor(uv * float2(8.0,4.0));
        float r = rng2(uv,time);
        float3 noise_ = (float3(r, 1. - r * colorization, r / 2.0 + 0.5) * 1.0 * noise - 2.0) * 0.08;
        float lineNoise = pow(rng2(blockS, time), 8.0) * parasite * pow(rng2(blockL, time), 3.0) - pow(rng(7.2341, time), 17.0) * 2.0;
        
        float4 col1 = inputTexture.sample(inputSampler, uv);
        float4 col2 = inputTexture.sample(inputSampler, uv + float2(lineNoise * 0.05 * rng(5.0, time), 0));
        float4 col3 = inputTexture.sample(inputSampler, uv - float2(lineNoise * 0.05 * rng(31.0, time), 0));
        float4 result = float4(float3(col1.x, col2.y, col3.z) + noise_, 1.0);
        return mix(col1, result, fade);
    }
    
    fragment float4 waterReflection(VertexOut in [[ stage_in ]],
                                    texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                    sampler inputSampler [[ sampler(0) ]],
                                    constant float &time [[ buffer(0) ]]) {
        float2 uv = in.textureCoordinate;
        float4 waterColor = float4(1.0);
        float reflactionY = 0.5;
        if (1.0 - uv.y <= reflactionY) {
            float oy = uv.y;
            uv.y = 2.0 * reflactionY - uv.y;
            uv.y = uv.y + sin(1./(oy-reflactionY)+time*10.0)*0.005;
            waterColor = float4(0.75, 0.85, 0.95, 1.0);
        }
        return inputTexture.sample(inputSampler, uv) * waterColor;
    }
    
    fragment float4 flipV(VertexOut in [[ stage_in ]],
                         texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                         sampler inputSampler [[ sampler(0) ]]) {
        float2 uv = in.textureCoordinate;
        uv.y = uv.y > 0.5 ? 1.0 - uv.y : uv.y;
        return inputTexture.sample(inputSampler, uv);
    }
    
    fragment float4 flipH(VertexOut in [[ stage_in ]],
                          texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                          sampler inputSampler [[ sampler(0) ]]) {
        float2 uv = in.textureCoordinate;
        uv.x = uv.x > 0.5 ? 1.0 - uv.x : uv.x;
        return inputTexture.sample(inputSampler, uv);
    }
    
    METAL_FUNC float2 scaleFromCenter(float2 coordinate, float scale, float2 center) {
        if (scale > 1.0 || scale < 0.0) { return coordinate; }
        return (coordinate - center) * scale + center;
    }
    
    fragment float4 soulout(VertexOut in [[ stage_in ]],
                            texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                            sampler inputSampler [[ sampler(0) ]],
                            constant float &time [[ buffer(0) ]]) {
        float2 st = in.textureCoordinate;
        float scale = 1.0 - mod(time * 1.3, 0.8) + 0.1;
        if (scale < 0.0) {
             return inputTexture.sample(inputSampler, st);
        } else {
            float2 newCoord = scaleFromCenter(st, scale, float2(0.5, 0.5));
            float colorScale = scale * 0.5;
            float4 resultColor = inputTexture.sample(inputSampler, st) * (1.0 - colorScale + 0.2);
            float4 newCoordColor = inputTexture.sample(inputSampler, newCoord) * (colorScale - 0.2);
            return (resultColor + newCoordColor);
        }
    }
    
    fragment float4 shake(VertexOut in [[ stage_in ]],
                          texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                          sampler inputSampler [[ sampler(0) ]],
                          constant float &time [[ buffer(0) ]]) {
        float2 st = in.textureCoordinate;
        float scale = 1.0 - mod(time * 1.0, 0.8) + 0.5;
        if (scale < 0.0) {
            return inputTexture.sample(inputSampler, st);
        } else {
            float2 newCoord = scaleFromCenter(st, scale, float2(0.55, 0.45));
            float4 result = inputTexture.sample(inputSampler, newCoord);
            float2 newCoord2 = scaleFromCenter(st, scale, float2(0.5, 0.5));
            float4 result2 = inputTexture.sample(inputSampler, newCoord2);
            float2 newCoord3 = scaleFromCenter(st, scale, float2(0.45, 0.45));
            float4 result3 = inputTexture.sample(inputSampler, newCoord3);
            float4 xx = result * float4(0.0, 0.0, 1.0, 1.0) + result2 * float4(0.0, 1.0, 0.0, 1.0) + result3 * float4(1.0, 0.0, 0.0, 1.0);
            return float4(xx.rgb, 1.0);
        }
    }
    
    float3 N13(float p) {
        float3 p3 = fract(float3(p) * float3(.1031,.11369,.13787));
        p3 += dot(p3, p3.yzx + 19.19);
        return fract(float3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
    }
    
    float4 N14(float t) {
        return fract(sin(t*float4(123., 1024., 1456., 264.))*float4(6547., 345., 8799., 1564.));
    }
    
    float N(float t) {
        return fract(sin(t*12345.564)*7658.76);
    }
    
    float Saw(float b, float t) {
        return smoothstep(0., b, t)*smoothstep(1., b, t);
    }
    
    float StaticDrops(float2 uv, float t) {
        uv *= 40.;
        float2 id = floor(uv);
        uv = fract(uv)-.5;
        float3 n = N13(id.x*107.45+id.y*3543.654);
        float2 p = (n.xy-.5)*.7;
        float d = length(uv-p);
        float fade = Saw(.025, fract(t+n.z));
        float c = smoothstep(.3, 0., d)*fract(n.z*20.)*fade;
        return c;
    }
    
    float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
        float s = StaticDrops(uv, t)*l0;
        float2 m1 = float2(0.0,0.0);
        float2 m2 = float2(0.0,0.0);
        
        float c = s+m1.x+m2.x;
        c = smoothstep(.3, 1.0, c);
        
        return float2(c, max(m1.y*l0, m2.y*l1));
    }
    
    fragment float4 rainwindow(VertexOut in [[ stage_in ]],
                               texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                               sampler inputSampler [[ sampler(0) ]],
                               constant float &time [[ buffer(0) ]]) {
        float2 uv = in.textureCoordinate - float2(0.5, 0.5);
        float2 UV = in.textureCoordinate;
        float T = time;
        float t = T * 0.5;
        float rainAmount = sin(T * 0.05) * .3 + 1.5;
        float staticDrops = smoothstep(.1, 1., rainAmount) * 2.;
        float layer1 = smoothstep(.25, .75, rainAmount);
        float layer2 = smoothstep(.0, .5, rainAmount);
        float2 c = Drops(uv, t, staticDrops, layer1, layer2);
        float2 e = float2(0.001, 0.);
        float cx = Drops(uv+e, t, staticDrops, layer1, layer2).x;
        float cy = Drops(uv+e.yx, t, staticDrops, layer1, layer2).x;
        float2 n = float2(cx-c.x, cy-c.x);
        float3 col = inputTexture.sample(inputSampler, UV - n).rgb;
        return float4(col, 1.);
    }
}


