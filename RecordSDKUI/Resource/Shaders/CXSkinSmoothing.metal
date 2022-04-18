//
//  CXSkinSmoothing.metal
//  Pods
//
//  Created by Yu Ao on 26/02/2018.
//
#include "MTIShaderLib.h"
#include "CXShaderTypes.h"

using namespace metalpetal;

namespace cx {

    constant int cxSkinSmoothingWinSize [[function_constant(0)]];
    constant bool cxSkinSmoothingConsidersSkinRelation [[function_constant(2)]];
    constant bool cxSkinSmoothingUsesMask [[function_constant(3)]];
    fragment float4 cxSkinSmoothingEdgePassGuided(CXVertexOut vertexIn [[ stage_in ]],
                                                 texture2d<half, access::sample> colorTexture [[ texture(0) ]],
                                                 sampler colorSampler [[ sampler(0) ]],
                                                 texture2d<half, access::sample> maskTexture [[ texture(1), function_constant(cxSkinSmoothingUsesMask) ]],
                                                 sampler maskSampler [[ sampler(1), function_constant(cxSkinSmoothingUsesMask) ]],
                                                 constant float3 & epslone [[buffer(0)]],
                                                 constant float3 & skinDefaultRGB [[buffer(1)]],
                                                 constant float2 & sampleStep [[buffer(2)]]) {
        half4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        
        float eps = epslone.r;
        
        if (cxSkinSmoothingUsesMask) {
            half4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
            eps = dot(float3(epslone), float3(mask.rgb));
        }
        
        if (cxSkinSmoothingConsidersSkinRelation) {
            half3 relation = 1.0h + min((sourceColor.xyz - half3(skinDefaultRGB)), 0.0h);
            half meanrelation = dot(relation, 1.0h/3.0h);
            float r = 1.0 / (1.0 + exp(24.0 - 30.0 * meanrelation));
            eps = eps * r;
        }
        
        if (eps < 0.000001) {
            return float4(sourceColor);
        }
        
        float x = vertexIn.textureCoordinate.x + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.x);
        float y = vertexIn.textureCoordinate.y + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.y);
        
        half3 meanI = half3(0.);
        half3 meanII = half3(0.);
        half3 temp = half3(0.);
        half sumW = 0.0h;
        half weightFloat;

        for(short i = 0; i < cxSkinSmoothingWinSize; i++) {
            float px = x + i * sampleStep.x;
            for(short j = 0; j < cxSkinSmoothingWinSize; j++) {
                temp = colorTexture.sample(colorSampler, float2(px, y + j * sampleStep.y)).rgb;
                weightFloat = dot(saturate(half3(1.0) - 5.0h * abs(temp - sourceColor.rgb)), 1.0h/3.0h);
                sumW += weightFloat;
                meanI += weightFloat * temp;
                meanII += weightFloat * temp * temp;
            }
        }
        meanI /= sumW;
        meanII /= sumW;
        temp = meanII - meanI * meanI;
        
        float3 a = saturate(float3(temp) / (float3(temp) + float3(eps)));
        float3 b = float3(meanI) - a * float3(meanI);
        return float4(a * float3(sourceColor.rgb) + b, sourceColor.a);
    }
    
    fragment float4 cxSkinSmoothingEdgePassGuidedV2(CXVertexOut vertexIn [[ stage_in ]],
                                                    texture2d<half, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<half, access::sample> maskTexture [[ texture(1), function_constant(cxSkinSmoothingUsesMask) ]],
                                                    sampler maskSampler [[ sampler(1), function_constant(cxSkinSmoothingUsesMask) ]],
                                                    constant float3 & epslone [[buffer(0)]],
                                                    constant float3 & skinDefaultRGB [[buffer(1)]],
                                                    constant float2 & sampleStep [[buffer(2)]]) {
        half4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        
        float eps = epslone.r;
        
        if (cxSkinSmoothingUsesMask) {
            half4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
            eps = dot(float3(epslone), float3(mask.rgb));
        }
        
        if (cxSkinSmoothingConsidersSkinRelation) {
            half3 relation = 1.0h + min((sourceColor.xyz - half3(skinDefaultRGB)), 0.0h);
            half meanrelation = dot(relation, 1.0h/3.0h);
            float r = 1.0 / (1.0 + exp(22.0 - 30.0 * meanrelation));
            eps = eps * r;
        }
        
        if (eps < 0.000001) {
            return float4(sourceColor);
        }
        
        float x = vertexIn.textureCoordinate.x + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.x);
        float y = vertexIn.textureCoordinate.y + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.y);
        
        half3 meanI = half3(0.);
        half3 meanII = half3(0.);
        half3 temp = half3(0.);
        half sumW = 0.0h;
        half weightFloat;
        
        for(short i = 0; i < cxSkinSmoothingWinSize; i++) {
            float px = x + i * sampleStep.x;
            for(short j = 0; j < cxSkinSmoothingWinSize; j++) {
                temp = colorTexture.sample(colorSampler, float2(px, y + j * sampleStep.y)).rgb;
                weightFloat = dot(saturate(half3(1.0) - 5.0h * abs(temp - sourceColor.rgb)), 1.0h/3.0h);
                sumW += weightFloat;
                meanI += weightFloat * temp;
                meanII += weightFloat * temp * temp;
            }
        }
        meanI /= sumW;
        meanII /= sumW;
        temp = meanII - meanI * meanI;
        
        float3 a = saturate(float3(temp) / (float3(temp) + float3(eps)));
        float3 b = float3(meanI) - a * float3(meanI);
        float4 resultColor = float4(a * float3(sourceColor.rgb) + b, sourceColor.a);
        
        float widthOffset = 1.0/colorTexture.get_width();
        float heightOffset = 1.0/colorTexture.get_height();
        
        float sum = 0.25 * sourceColor.g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, 0.0)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, 0.0)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(0, -heightOffset)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(0, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, -heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, -heightOffset)).g;
        
        float hPass = sourceColor.g - sum + 0.5;
        float flag = step(0.5, hPass);
        float3 r = 2.0 * hPass + resultColor.rgb - 1.0;
        float3 color = mix(max(float3(0.0), r), min(float3(1.0), r), flag);
        return float4(mix(resultColor.rgb, color.rgb, 0.5).rgb, 1.0);
    }
    
    fragment float4 cxSkinSmoothingAnalyze(CXVertexOut vertexIn [[ stage_in ]],
                                           texture2d<half, access::sample> colorTexture [[ texture(0) ]],
                                           sampler colorSampler [[ sampler(0) ]],
                                           texture2d<half, access::sample> maskTexture [[ texture(1) ]],
                                           sampler maskSampler [[ sampler(1) ]],
                                           constant float3 & epslone [[buffer(0)]],
                                           constant float3 & skinDefaultRGB [[buffer(1)]],
                                           constant float2 & sampleStep [[buffer(2)]]) {
        half4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        
        float eps = epslone.r;
        
        half4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        eps = eps * mask.r;
        
        half3 relation = 1.0h + min((sourceColor.xyz - half3(skinDefaultRGB)), 0.0h);
        half meanrelation = dot(relation, 1.0h/3.0h);
        float r = 1.0 / (1.0 + exp(24.0 - 30.0 * meanrelation));
        eps = eps * r;
        
        if (eps < 0.000001) {
            return float4(float3(0.5), 1.0);
        }
        
        float x = vertexIn.textureCoordinate.x + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.x);
        float y = vertexIn.textureCoordinate.y + (-cxSkinSmoothingWinSize / 2.0 * sampleStep.y);
        
        half3 meanI = half3(0.);
        half3 meanII = half3(0.);
        half3 temp = half3(0.);
        half sumW = 0.0h;
        half weightFloat;
        
        for(short i = 0; i < cxSkinSmoothingWinSize; i++) {
            float px = x + i * sampleStep.x;
            for(short j = 0; j < cxSkinSmoothingWinSize; j++) {
                temp = colorTexture.sample(colorSampler, float2(px, y + j * sampleStep.y)).rgb;
                weightFloat = dot(saturate(half3(1.0) - 5.0h * abs(temp - sourceColor.rgb)), 1.0h/3.0h);
                sumW += weightFloat;
                meanI += weightFloat * temp;
                meanII += weightFloat * temp * temp;
            }
        }
        meanI /= sumW;
        meanII /= sumW;
        temp = meanII - meanI * meanI;
        
        float3 a = saturate(float3(temp) / (float3(temp) + float3(eps)));
        float3 b = float3(meanI) - a * float3(meanI);
        float3 rColor = a * float3(sourceColor.rgb) + b;
        rColor = rColor - float3(sourceColor.rgb) + float3(0.5,0.5,0.5);
        return float4(float3(dot(rColor, float3(1.0/3.0))), 1.0);
    }
    
    fragment half4 cxAutoSkinSpotRemove(VertexOut vertexIn [[ stage_in ]],
                                                 texture2d<half, access::sample> colorTexture [[ texture(0) ]],
                                                 sampler colorSampler [[ sampler(0) ]],
                                                 texture2d<half, access::sample> edgeTexture [[ texture(1) ]],
                                                 sampler edgeSampler [[ sampler(1) ]]) {
        half4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
//        half4 color = edgeTexture.sample(edgeSampler, vertexIn.textureCoordinate);
//        half3 relation = 1.0h + min((sourceColor.xyz - half3(0.62,0.47,0.43)), 0.0h);
//        half meanrelation = dot(relation, 1.0/3.0);
//        half r = 1.0h / (1.0h + exp(24.0h - 30.0h * meanrelation));
//        return half4(half3(r), 1.0);
//        return color.r > 0.3 ? 1.0 : 0.0;
        return sourceColor;
    }
    
    fragment half4 cxSkinSpotRemoveMask(CXVertexOut vertexIn [[ stage_in ]],
                                                 texture2d<half, access::sample> maskTexture [[ texture(0) ]],
                                                 sampler maskSampler [[ sampler(0) ]],
                                                 texture2d<half, access::sample> edgeTexture [[ texture(1) ]],
                                                 sampler edgeSampler [[ sampler(1) ]],
                                                 constant float & amount [[ buffer(0) ]]) {
        half4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        half4 sourceColor = edgeTexture.sample(edgeSampler, vertexIn.textureCoordinate);
        if (sourceColor.r > 0.3) {
            float d = (1.0 - vertexIn.maskTextureCoordinate.y) < mix(0.2, 0.7, amount) ? 1.0 : 0.0;
            sourceColor.rgb = mask.r  * d;
            return sourceColor;
        } else {
            return half4(0.0,0.0,0.0,1.0);
        }
    }
    
    fragment float4 cxFaceColorEnhancement(VertexOut vertexIn [[ stage_in ]],
                                           texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                           sampler colorSampler [[ sampler(0) ]],
                                           texture2d<float, access::sample> lookupGrayTexture [[ texture(1) ]],
                                           sampler lookupGraySampler [[ sampler(1) ]],
                                           texture2d<float, access::sample> lookupTexture [[ texture(2) ]],
                                           sampler lookupSampler [[ sampler(2) ]],
                                           texture2d<float, access::sample> lookupXTexture [[ texture(3) ]],
                                           sampler lookupXSampler [[ sampler(3) ]],
                                           constant float & levelBlack [[ buffer(0) ]],
                                           constant float & levelRangeInv [[ buffer(1) ]],
                                           constant float & alpha [[ buffer(2) ]]) {
        float3 colorOrigin = colorTexture.sample(colorSampler, vertexIn.textureCoordinate).rgb;
        float3 color = saturate((colorOrigin - float3(levelBlack)) * levelRangeInv);
        float3 texel;
        texel.r = lookupGrayTexture.sample(lookupGraySampler, float2((color.r * 255.0 + 0.5)/256.0, 0.5)).r;
        texel.g = lookupGrayTexture.sample(lookupGraySampler, float2((color.g * 255.0 + 0.5)/256.0, 0.5)).g;
        texel.b = lookupGrayTexture.sample(lookupGraySampler, float2((color.b * 255.0 + 0.5)/256.0, 0.5)).b;
        texel = mix(color, texel, 0.5);
        texel = mix(colorOrigin, texel, alpha);
        
        float blueColor = texel.b * 15.0;
        float2 quad1, quad2;
        quad1.y = floor(floor(blueColor) * 0.25);
        quad1.x = floor(blueColor) - (quad1.y * 4.0);
        quad2.y = floor(ceil(blueColor) * 0.25);
        quad2.x = ceil(blueColor) - (quad2.y * 4.0);
        float2 texPos2, texPos1;
        texPos2 = texel.rg * 0.234375 + 0.0078125;
        texPos1 = quad1 * 0.25 + texPos2;
        texPos2 = quad2 * 0.25 + texPos2;
        float4 newColor1 = lookupTexture.sample(lookupSampler, texPos1);
        float4 newColor2 = lookupTexture.sample(lookupSampler, texPos2);
        color = mix(newColor1.rgb, newColor2.rgb, fract(blueColor));
        
        float4 newColor1Origin = lookupXTexture.sample(lookupXSampler, texPos1);
        float4 newColor2Origin = lookupXTexture.sample(lookupXSampler, texPos2);
        float3 newColorOrigin = mix(newColor1Origin.rgb, newColor2Origin.rgb, fract(blueColor));
        
        float3 outputColor = mix(newColorOrigin, color, alpha);
        
        return float4(mix(colorOrigin, outputColor, alpha), 1.0);
    }
    
    fragment half4 cxFaceColorEnhancementV2(VertexOut vertexIn [[ stage_in ]],
                                          texture2d<half, access::sample> colorTexture [[ texture(0) ]],
                                          sampler colorSampler [[ sampler(0) ]],
                                          texture2d<half, access::sample> lookupGrayTexture [[ texture(1) ]],
                                          sampler lookupGraySampler [[ sampler(1) ]],
                                          texture2d<half, access::sample> lookupTexture [[ texture(2) ]],
                                          sampler lookupSampler [[ sampler(2) ]],
                                          texture2d<half, access::sample> lookupOriginTexture [[ texture(3) ]],
                                          sampler lookupOriginSampler [[ sampler(3) ]],
                                          texture2d<half, access::sample> lookupSkinTexture [[ texture(4) ]],
                                          sampler lookupSkinSampler [[ sampler(4) ]],
                                          constant float & levelBlack [[ buffer(0) ]],
                                          constant float & levelRangeInv [[ buffer(1) ]],
                                          constant float & alpha [[ buffer(2) ]]) {
        half3 colorOrigin = colorTexture.sample(colorSampler, vertexIn.textureCoordinate).rgb;
        half3 color = saturate((colorOrigin - half3(levelBlack)) * half(levelRangeInv));
        half3 texel;
        texel.r = lookupGrayTexture.sample(lookupGraySampler, float2((color.r * 255.0 + 0.5)/256.0, 0.5)).r;
        texel.g = lookupGrayTexture.sample(lookupGraySampler, float2((color.g * 255.0 + 0.5)/256.0, 0.5)).g;
        texel.b = lookupGrayTexture.sample(lookupGraySampler, float2((color.b * 255.0 + 0.5)/256.0, 0.5)).b;
        texel.r = texel.r + 0.03;
        texel.g = texel.g - 0.03;
        texel.b = texel.b - 0.01;
        texel = clamp(texel, 0.0, 1.0);
        texel = mix(color, texel, 0.5h);
        texel = mix(colorOrigin, texel, half(alpha));
        
        half blueColor = texel.b * 15.0;
        half2 quad1, quad2;
        quad1.y = floor(floor(blueColor) * 0.25);
        quad1.x = floor(blueColor) - (quad1.y * 4.0);
        quad2.y = floor(ceil(blueColor) * 0.25);
        quad2.x = ceil(blueColor) - (quad2.y * 4.0);
        half2 texPos2, texPos1;
        texPos2 = texel.rg * 0.234375 + 0.0078125;
        texPos1 = quad1 * 0.25 + texPos2;
        texPos2 = quad2 * 0.25 + texPos2;
        half4 newColor1 = lookupTexture.sample(lookupSampler, float2(texPos1));
        half4 newColor2 = lookupTexture.sample(lookupSampler, float2(texPos2));
        color = mix(newColor1.rgb, newColor2.rgb, fract(blueColor));
        
        half4 newColor1Origin = lookupOriginTexture.sample(lookupOriginSampler, float2(texPos1));
        half4 newColor2Origin = lookupOriginTexture.sample(lookupOriginSampler, float2(texPos2));
        half3 newColorOrigin = mix(newColor1Origin.rgb, newColor2Origin.rgb, fract(blueColor));
        
        texel = mix(newColorOrigin, color, half(alpha)*0.7);
        
        blueColor = texel.b * 15.0;
        quad1.y = floor(floor(blueColor) * 0.25);
        quad1.x = floor(blueColor) - (quad1.y * 4.0);
        quad2.y = floor(ceil(blueColor) * 0.25);
        quad2.x = ceil(blueColor) - (quad2.y * 4.0);
        texPos2 = texel.rg * 0.234375 + 0.0078125;
        texPos1 = quad1 * 0.25 + texPos2;
        texPos2 = quad2 * 0.25 + texPos2;
        newColor1 = lookupSkinTexture.sample(lookupSkinSampler, float2(texPos1));
        newColor2 = lookupSkinTexture.sample(lookupSkinSampler, float2(texPos2));
        color = mix(newColor1.rgb, newColor2.rgb, fract(blueColor));
        
        return half4(mix(colorOrigin, color, half(alpha)*0.7), 1.0h);
    }
    
    fragment float4 cxSkinSmoothingHighPass(VertexOut vertexIn [[ stage_in ]],
                                          texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                          sampler colorSampler [[ sampler(0) ]],
                                          texture2d<float, access::sample> blurTexture [[ texture(1) ]],
                                          sampler blurSampler [[ sampler(1) ]]) {
        float3 color = colorTexture.sample(colorSampler, vertexIn.textureCoordinate).rgb;
        float3 blur = blurTexture.sample(blurSampler, vertexIn.textureCoordinate).rgb;
        float3 diff = (color - blur) * 7.07;
        diff = min(diff * diff, 1.0);
        return float4(diff, 1.0);
    }
    
    
    fragment float4 cxSkinSmoothingFusion(VertexOut vertexIn [[ stage_in ]],
                                           texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                           sampler colorSampler [[ sampler(0) ]],
                                           texture2d<float, access::sample> blurredTexture [[ texture(1) ]],
                                           sampler blurredSampler [[ sampler(1) ]],
                                         texture2d<float, access::sample> blurredHighPassTexture [[ texture(2) ]],
                                         sampler blurredHighPassSampler [[ sampler(2) ]],
                                         constant float &amount [[ buffer(0) ]],
                                         constant float &sharpness [[ buffer(1) ]]
                                         ) {
        
        float3 iColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate).rgb;
        float3 meanColor = blurredTexture.sample(blurredSampler, vertexIn.textureCoordinate).rgb;
        float3 varColor = blurredHighPassTexture.sample(blurredHighPassSampler, vertexIn.textureCoordinate).rgb;
        constexpr float theta = 0.1;
        
        float p = clamp((min(iColor.r, meanColor.r - 0.1) - 0.2) * 4.0, 0.0, 1.0);
        float meanVar = (varColor.r + varColor.g + varColor.b) / 3.0;
        float kMin;
        
        float3 resultColor;
        kMin = (1.0 - meanVar / (meanVar + theta)) * p * amount;
        resultColor = mix(iColor.rgb, meanColor.rgb, kMin);
        
        float widthOffset = 1.0/colorTexture.get_width();
        float heightOffset = 1.0/colorTexture.get_height();
        
        float sum = 0.25 * iColor.g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, 0.0)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, 0.0)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(0, -heightOffset)).g;
        sum += 0.125*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(0, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, -heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(-widthOffset, heightOffset)).g;
        sum += 0.0625*colorTexture.sample(colorSampler, vertexIn.textureCoordinate + float2(widthOffset, -heightOffset)).g;
        
        float hPass = iColor.g - sum + 0.5;
        float flag = step(0.5, hPass);
        float3 r = 2.0 * hPass + resultColor - 1.0;
        float3 color = mix(max(float3(0.0), r), min(float3(1.0), r), flag);
        color = mix(resultColor.rgb, color.rgb, sharpness);
        
        return float4(color, 1.0);
    }
    
    
    struct CXBoxBlurVertexOut {
        float4 position [[ position ]];
        float2 textureCoordinate;
        float4 textureShift_1;
        float4 textureShift_2;
        float4 textureShift_3;
        float4 textureShift_4;
    };
    
    vertex CXBoxBlurVertexOut cxBoxBlurVertex(
                                       const device VertexIn * vertices [[ buffer(0) ]],
                                       uint vid [[ vertex_id ]],
                                       constant float2 &singleStepOffset [[buffer(1)]]
                                       ) {
        CXBoxBlurVertexOut outVertex;
        VertexIn inVertex = vertices[vid];
        outVertex.position = inVertex.position;
        outVertex.textureCoordinate = inVertex.textureCoordinate;
        
        float2 uv = inVertex.textureCoordinate;
        outVertex.textureShift_1 = float4(uv.xy - singleStepOffset, uv.xy + singleStepOffset);
        outVertex.textureShift_2 = float4(uv.xy - 2.0 * singleStepOffset, uv.xy + 2.0 * singleStepOffset);
        outVertex.textureShift_3 = float4(uv.xy - 3.0 * singleStepOffset, uv.xy + 3.0 * singleStepOffset);
        outVertex.textureShift_4 = float4(uv.xy - 4.0 * singleStepOffset, uv.xy + 4.0 * singleStepOffset);
        return outVertex;
    }
    
    fragment float4 cxBoxBlurFragment(CXBoxBlurVertexOut vertexIn [[ stage_in ]],
                                            texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                            sampler colorSampler [[ sampler(0) ]]) {
        float3 sum = colorTexture.sample(colorSampler, vertexIn.textureCoordinate).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_1.xy).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_1.zw).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_2.xy).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_2.zw).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_3.xy).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_3.zw).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_4.xy).rgb;
        sum += colorTexture.sample(colorSampler, vertexIn.textureShift_4.zw).rgb;
        return float4(sum * 0.1111, 1.0);
    }
    
}
