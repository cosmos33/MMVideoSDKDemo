//
//  Shaders.metal
//  Pods
//
//  Created by Yu Ao on 29/01/2018.
//

#include "MTIShaderLib.h"
#include "CXShaderTypes.h"

using namespace metalpetal;

namespace cx {
    
    vertex CXVertexOut cxPassthroughVertex(
                                       const device CXVertex * vertices [[ buffer(0) ]],
                                       uint vid [[ vertex_id ]]
                                       ) {
        CXVertexOut outVertex;
        CXVertex inVertex = vertices[vid];
        outVertex.position = inVertex.position;
        outVertex.textureCoordinate = inVertex.textureCoordinate;
        outVertex.maskTextureCoordinate = inVertex.maskTextureCoordinate;
        return outVertex;
    }
    
    typedef struct {
        float4 position [[ position ]];
        float pointSize [[ point_size]];
    } CXPointsVertexOut;
    
    vertex CXPointsVertexOut cxPointsRenderingVertex(
                                           const device MTIVertex * vertices [[ buffer(0) ]],
                                           uint vid [[ vertex_id ]]
                                           ) {
        CXPointsVertexOut outVertex;
        MTIVertex inVertex = vertices[vid];
        outVertex.position = inVertex.position;
        outVertex.pointSize = 6.0;
        return outVertex;
    }
    
    fragment float4 cxPointsRenderingFragment(CXPointsVertexOut vertexIn [[ stage_in ]]) {
        return float4(1.0,0.0,0.0,1.0);
    }
    
    fragment float4 cxFaceMask(VertexOut vertexIn [[ stage_in ]],
                                                  texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                                  sampler inputSampler [[ sampler(0) ]],
                                                  float4 color [[color(0)]]
                                                  ) {
        float4 color1 = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        return mix(color, color1, 0.3);
    }
    
    fragment float4 cxFaceMaskOverlayBlend(VertexOut vertexIn [[ stage_in ]],
                               texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                               sampler inputSampler [[ sampler(0) ]],
                               float4 color [[color(0)]],
                               constant float &intensity [[buffer(0)]]
                               ) {
        float4 uCf = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 uCb = color;
        float4 blendedColor = overlayBlend(uCb, uCf);
        return mix(uCb,blendedColor,intensity);
    }
    
    fragment float4 cxFaceMaskMultiplyBlend(VertexOut vertexIn [[ stage_in ]],
                                           texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                           sampler inputSampler [[ sampler(0) ]],
                                           float4 color [[color(0)]],
                                           constant float &intensity [[buffer(0)]]
                                           ) {
        float4 uCf = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 uCb = color;
        float4 blendedColor = multiplyBlend(uCb, uCf);
        return mix(uCb,blendedColor,intensity);
    }
    
    fragment float4 cxFaceMaskSoftLightBlend(VertexOut vertexIn [[ stage_in ]],
                                            texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                            sampler inputSampler [[ sampler(0) ]],
                                            float4 color [[color(0)]],
                                            constant float &intensity [[buffer(0)]]
                                            ) {
        float4 uCf = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 uCb = color;
        float4 blendedColor = softLightBlend(uCb, uCf);
        return mix(uCb,blendedColor,intensity);
    }
    
    fragment float4 cxFaceMaskNormalBlend(VertexOut vertexIn [[ stage_in ]],
                                             texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                             sampler inputSampler [[ sampler(0) ]],
                                             float4 color [[color(0)]],
                                             constant float &intensity [[buffer(0)]]
                                             ) {
        float4 uCf = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 uCb = color;
        float4 blendedColor = normalBlend(uCb, uCf);
        return mix(uCb,blendedColor,intensity);
    }
    
    fragment float4 cxFaceMaskLightnessLookupBlend(VertexOut vertexIn [[ stage_in ]],
                                          texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                          sampler inputSampler [[ sampler(0) ]],
                                          texture2d<float, access::sample> lookupTexture [[ texture(1) ]],
                                          sampler lookupSampler [[ sampler(1) ]],
                                          float4 color [[color(0)]],
                                          constant float &intensity [[buffer(0)]]
                                          ) {
        float4 textureColor = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 sourceColor = color;
        float4 c;
        c.r = lookupTexture.sample(lookupSampler, float2((textureColor.r * 255.0 + 0.5)/256.0, (sourceColor.r * 255.0 + 0.5)/256.0)).r;
        c.g = lookupTexture.sample(lookupSampler, float2((textureColor.g * 255.0 + 0.5)/256.0, (sourceColor.g * 255.0 + 0.5)/256.0)).g;
        c.b = lookupTexture.sample(lookupSampler, float2((textureColor.b * 255.0 + 0.5)/256.0, (sourceColor.b * 255.0 + 0.5)/256.0)).b;
        c.a = textureColor.a;
        float4 blendedColor = normalBlend(sourceColor, c);
        return mix(sourceColor,blendedColor,intensity);
    }
    
    fragment float4 cxFaceMaskLipGlowMaskRenderKernel(VertexOut vertexIn [[ stage_in ]],
                                             texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                            sampler inputTextureSampler [[ sampler(0) ]],
                                             texture2d<float, access::sample> preValueTexture [[ texture(1) ]],
                                             sampler preValueSampler [[ sampler(1) ]],
                                             texture2d<float, access::sample> maxValueTexture [[ texture(2) ]],
                                             sampler maxValueSampler [[ sampler(2) ]],
                                             constant float &scope [[ buffer(0) ]],
                                             constant float &threshold [[ buffer(1) ]],
                                             constant float &maxIntensity [[ buffer(2) ]],
                                                      constant bool &preMaskAvailable [[ buffer(3) ]]
  
                                             ) {
        float4 color = inputTexture.sample(inputTextureSampler, vertexIn.textureCoordinate);
        float4 hsv = float4(rgb2hsl(color.rgb), color.a);
        float textureValue = (1.0 - hsv.g) * hsv.b;
        float minY = 0.05;
        float maxY = 1.0;
        float2 maxValueTextureCoordinate = float2(0.5/maxValueTexture.get_width(), 0.5/maxValueTexture.get_height() );
        float maxValue = maxValueTexture.sample(maxValueSampler, maxValueTextureCoordinate).r;
        maxValue = maxValue * scope;
        float value = pow(2.71828, log(minY / maxY) / (maxValue * (threshold - 1.0)) * textureValue + log(maxY) - log(minY / maxY)/ (threshold - 1.0) );
        value = clamp(value, 0.0, maxY);
        value = pow(value, 0.8)*maxIntensity;
        if (preMaskAvailable) {
            float4 preValue = preValueTexture.sample(preValueSampler, vertexIn.textureCoordinate);
            value = value*0.7+preValue.r*0.15+preValue.g*0.1+preValue.b*0.05;
            return float4(value, preValue.r, preValue.g, preValue.b);
        }
        return float4(value);
    }
    
    fragment float4 cxFaceMaskLipStickKernel(CXVertexOut vertexIn [[ stage_in ]],
                                           texture2d<float, access::sample> maskTexture [[ texture(1) ]],
                                           sampler maskSampler [[ sampler(1) ]],
                                           texture2d<float, access::sample> glowMaskTexture [[ texture(0) ]],
                                           sampler glowMaskSampler [[ sampler(0) ]],
                                           float4 color [[color(0)]]
                                           ) {
        float4 glowMask = glowMaskTexture.sample(glowMaskSampler, vertexIn.textureCoordinate);
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        float4 lipColor = color;
        return float4(mix(lipColor.rgb, float3(1.0), glowMask.r * mask.r * clamp(dot(lipColor.rgb,float3(0.299f, 0.587f, 0.114f)) * 1.6, 0.0, 1.0)), lipColor.a);
    }
    
    fragment float4 cxLipStickKernel(CXVertexOut vertexIn [[ stage_in ]],
                                     texture2d<float, access::sample> maskTexture [[ texture(0) ]],
                                     sampler maskSampler [[ sampler(0) ]],
                                     texture2d<float, access::sample> lookupTexture [[ texture(1) ]],
                                     sampler lookupSampler [[ sampler(1) ]],
                                     float4 color [[color(0)]],
                                     constant float &intensity [[buffer(0)]],
                                     constant int &LUTDimension) {
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        float4 lipColor = colorLookup2DSquareLUT(color,LUTDimension,intensity,lookupTexture,lookupSampler);
        float4 gbColorBurn = colorBurnBlend(float4(float3(color.g), 1.0), float4(float3(color.b), 1.0));
        gbColorBurn = colorBurnBlend(gbColorBurn, gbColorBurn);
        //constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        //float i = dot(color.rgb, lumCoeff);
        return mix(color, lipColor, saturate(mask.r * (1.0 - gbColorBurn.r)));
    }
    
    fragment float4 cxLipStickToothKernel(CXVertexOut vertexIn [[ stage_in ]],
                                     texture2d<float, access::sample> maskTexture [[ texture(0) ]],
                                     sampler maskSampler [[ sampler(0) ]],
                                     texture2d<float, access::sample> inputTexture [[ texture(1) ]],
                                     sampler inputSampler [[ sampler(1) ]],
                                     float4 color [[color(0)]]) {
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        float4 inputColor = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        return mix(color, inputColor, mask.r);
    }
    
    fragment float4 cxTeethWhiten(CXVertexOut vertexIn [[ stage_in ]],
                                        texture2d<float, access::sample> lutTexture [[ texture(0) ]],
                                        texture2d<float, access::sample> maskTexture [[ texture(1) ]],
                                        sampler lutSampler [[ sampler(0) ]],
                                        sampler maskSampler [[ sampler(1) ]],
                                        constant float &intensity [[buffer(0)]],
                                        constant int &LUTDimension,
                                        float4 color [[color(0)]]
                                        ) {
        float4 inputColor = colorLookup2DSquareLUT(color, LUTDimension, intensity, lutTexture, lutSampler);
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        return mix(color, inputColor, mask.r);
    }
    
    fragment float4 cxTeethWhitenWithLipsMask(CXVertexOut vertexIn [[ stage_in ]],
                                  texture2d<float, access::sample> lutTexture [[ texture(0) ]],
                                  texture2d<float, access::sample> maskTexture [[ texture(1) ]],
                                  sampler lutSampler [[ sampler(0) ]],
                                  sampler maskSampler [[ sampler(1) ]],
                                  texture2d<float, access::sample> lipsMaskTexture [[ texture(2) ]],
                                  sampler lipsMaskSampler [[ sampler(2) ]],
                                  constant float &intensity [[buffer(0)]],
                                  constant int &LUTDimension,
                                  float4 color [[color(0)]]
                                  ) {
        float4 inputColor = colorLookup2DSquareLUT(color, LUTDimension, intensity, lutTexture, lutSampler);
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        float lipsMaskColor = 1.0 - lipsMaskTexture.sample(lipsMaskSampler, vertexIn.textureCoordinate).r;
        return mix(color, inputColor, mask.r * lipsMaskColor);
    }
    
    kernel void sampleForHighlightValue(texture2d<float, access::sample> inTexture [[texture(0)]],
                                      texture2d<float, access::write> outTexture [[texture(1)]],
                                      constant uint & dimension [[ buffer(0) ]],
                                      constant uint & pointsCount [[buffer(1)]],
                                      const device float *samplePoints [[buffer(2)]],
                                      uint2 id [[ thread_position_in_grid ]]) {
        if (id.x != 0 || id.y != 0) {
            return;
        }
        constexpr sampler s(coord::normalized,
                            address::clamp_to_zero,
                            filter::linear);
        float maxValue = 0.0;
        for (uint i = 0; i < pointsCount; i++) {
            float2 samplePoint = float2(samplePoints[dimension*i], samplePoints[dimension*i+1]);
            float4 sampleColor = inTexture.sample(s, samplePoint);
            float4 sampleHSV = float4(rgb2hsl(sampleColor.rgb), sampleColor.a);
            float value = (1.0 - sampleHSV.g) * sampleHSV.b;
            maxValue = max(maxValue, value);
        }
        outTexture.write(maxValue, uint2(0,0));
    }
    
    kernel void sampleForPupilValue(texture2d<float, access::sample> inTexture [[texture(0)]],
                                    texture2d<float, access::write> outTexture [[texture(1)]],
                                    constant uint & dimension [[ buffer(0) ]],
                                    constant uint & pointsCount [[buffer(1)]],
                                    const device float *samplePoints [[buffer(2)]],
                                    uint2 id [[ thread_position_in_grid ]]) {
        if (id.x >= outTexture.get_width() || id.y >= outTexture.get_height()) {
            return;
        }
        constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
        uint pointsCountPerPass = pointsCount / outTexture.get_height();
        uint passIdx = id.y;
        uint indexOffset = passIdx * pointsCountPerPass;
        float minValues[3] = {1.1, 1.1, 1.1};
        for (uint i = indexOffset; i < pointsCountPerPass+indexOffset; i++) {
            float2 samplePoint = float2(samplePoints[dimension*i], samplePoints[dimension*i+1]);
            float4 sampleColor = inTexture.sample(s, samplePoint);
            constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
            float value = dot(sampleColor.rgb, lumCoeff);
            if (value < minValues[2]) {
                if (value < minValues[1]) {
                    if (value < minValues[0]) {
                        minValues[2] = minValues[1];
                        minValues[1] = minValues[0];
                        minValues[0] = value;
                    } else {
                        minValues[2] = minValues[1];
                        minValues[1] = value;
                    }
                } else {
                    minValues[2] = value;
                }
            }
        }
        outTexture.write(minValues[2], uint2(0, passIdx));
    }
    
    fragment float4 cxFaceEyeSharpenKernel(CXVertexOut vertexIn [[ stage_in ]],
                                           texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                           sampler inputSampler [[ sampler(0) ]],
                                           texture2d<float, access::sample> maskTexture [[ texture(1) ]],
                                           sampler maskSampler [[ sampler(1) ]],
                                           texture2d<float, access::sample> blurTexture [[ texture(2) ]],
                                           sampler blurSampler [[ sampler(2) ]],
                                           texture2d<float, access::sample> pupilValueTexture [[ texture(3) ]],
                                           sampler pupilValueSampler [[ sampler(3) ]],
                                           texture2d<float, access::sample> sharpenTexture [[ texture(4) ]],
                                           sampler sharpenSampler [[ sampler(4) ]],
                                           float4 color [[color(0)]]) {
        float4 mask = maskTexture.sample(maskSampler, vertexIn.maskTextureCoordinate);
        float4 inputColor = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 sharpenColor = sharpenTexture.sample(sharpenSampler, vertexIn.textureCoordinate);
        constexpr sampler s(coord::pixel, address::clamp_to_zero, filter::linear);
        float2 pupilValueCoordinate = vertexIn.maskTextureCoordinate.x < 0.5 ? float2(0.5, 0.5) : float2(0.5, 1.5);
        float pupilValue = pupilValueTexture.sample(s, pupilValueCoordinate).r;
        float4 blurColor = blurTexture.sample(blurSampler, vertexIn.textureCoordinate);
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float pupilMask = dot(blurColor.rgb, lumCoeff) - pupilValue;
        float maskS = mask.r * (pupilMask < 0.03 ? 1.0 : 0.0);
        float4 resultColor = float4(mix(color.rgb, sharpenColor.rgb,maskS), color.a);
        //pupilMask = clamp(1.0 - (pupilMask * 8.0), 0.0, 1.0);
        resultColor = float4(mix(resultColor.rgb, inputColor.rgb,maskS), color.a);
        return resultColor;
    }
    
    fragment float4 cxPupilRenderKernel(VertexOut vertexIn [[ stage_in ]],
                                        texture2d<float, access::sample> lutTexture [[ texture(0) ]],
                                        sampler lutSampler [[ sampler(0) ]],
                                        texture2d<float, access::sample> pupilValueTexture [[ texture(1) ]],
                                        sampler pupilValueSampler [[ sampler(1) ]],
                                        texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                        sampler maskSampler [[ sampler(2) ]],
                                        texture2d<float, access::sample> blurTexture [[ texture(3) ]],
                                        sampler blurSampler [[ sampler(3) ]],
                                        constant float &intensity [[buffer(0)]],
                                        constant bool &eyeClosed [[buffer(1)]],
                                        constant bool &leftEye [[buffer(2)]],
                                        float4 color [[color(0)]]
                                        ) {
        bool isLeftEye = leftEye;
        float4 mask = maskTexture.sample(maskSampler, vertexIn.textureCoordinate);
        constexpr sampler s(coord::pixel, address::clamp_to_zero, filter::linear);
        float2 pupilValueCoordinate = isLeftEye ? float2(0.5, 0.5) : float2(0.5, 1.5);
        float pupilValue = pupilValueTexture.sample(s, pupilValueCoordinate).r;
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float pupilMask = dot(color.rgb, lumCoeff) - pupilValue;
        float maskS = (pupilMask < 0.01 ? 1.0 : 0.0);
        float4 inputColor = colorLookup2DSquareLUT(all(color.rgb < float3(0.1)) ? float4(float3(0.1),1) : color, 64, intensity, lutTexture, lutSampler);
        float4 r = mix(color, inputColor, (1.0 - mask.r) * maskS);
        if (eyeClosed) {
            return color;
        } else {
            return r;
        }
    }
    
    fragment float4 cxPupilImageRenderMaskKernel(VertexOut vertexIn [[ stage_in ]],
                                                 texture2d<float, access::sample> maskTexture [[ texture(0) ]],
                                                 sampler maskSampler [[ sampler(0) ]],
                                                 float4 color [[color(0)]]) {
        float4 result = color;
        result.a = maskTexture.sample(maskSampler, vertexIn.textureCoordinate).r;
        return result;
    }
    
    fragment float4 cxPupilImageRenderRestoreKernel(VertexOut vertexIn [[ stage_in ]],
                                                   float4 color [[color(0)]]) {
        float4 result = color;
        result.a = 1.0;
        return result;
    }

    fragment float4 cxPupilImageRenderKernelNormalBlend(VertexOut vertexIn [[ stage_in ]],
                                                        texture2d<float, access::sample> pupilTexture [[ texture(0) ]],
                                                        sampler pupilSampler [[ sampler(0) ]],
                                                        float4 color [[color(0)]],
                                                        constant float &intensity [[buffer(0)]]
                                        ) {
        float4 pupilColor = pupilTexture.sample(pupilSampler, vertexIn.textureCoordinate);
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float lightness = dot(color.rgb, lumCoeff);
        pupilColor.a = pupilColor.a * (1.0 - saturate(pow(lightness + 0.6,20.0))) * intensity * color.a;
        return normalBlend(float4(color.rgb, 1.0), pupilColor);
    }
    
    fragment float4 cxPupilImageRenderKernelSoftLightBlend(VertexOut vertexIn [[ stage_in ]],
                                                           texture2d<float, access::sample> pupilTexture [[ texture(0) ]],
                                                           sampler pupilSampler [[ sampler(0) ]],
                                                           float4 color [[color(0)]],
                                                           constant float &intensity [[buffer(0)]]
                                                        ) {
        float4 pupilColor = pupilTexture.sample(pupilSampler, vertexIn.textureCoordinate);
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float lightness = dot(color.rgb, lumCoeff);
        pupilColor.a = pupilColor.a * (1.0 - saturate(pow(lightness + 0.6,20.0))) * intensity * color.a;
        return softLightBlend(float4(color.rgb, 1.0), pupilColor);
    }
    
    
    fragment float4 cxPupilImageRenderKernelOverlayBlend(VertexOut vertexIn [[ stage_in ]],
                                                           texture2d<float, access::sample> pupilTexture [[ texture(0) ]],
                                                           sampler pupilSampler [[ sampler(0) ]],
                                                           float4 color [[color(0)]],
                                                           constant float &intensity [[buffer(0)]]
                                                           ) {
        float4 pupilColor = pupilTexture.sample(pupilSampler, vertexIn.textureCoordinate);
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float lightness = dot(color.rgb, lumCoeff);
        pupilColor.a = pupilColor.a * (1.0 - saturate(pow(lightness + 0.6,20.0))) * intensity * color.a;
        return overlayBlend(float4(color.rgb, 1.0), pupilColor);
    }
    
    fragment float4 cxPupilImageRenderKernelLighterColorBlend(VertexOut vertexIn [[ stage_in ]],
                                                         texture2d<float, access::sample> pupilTexture [[ texture(0) ]],
                                                         sampler pupilSampler [[ sampler(0) ]],
                                                         float4 color [[color(0)]],
                                                         constant float &intensity [[buffer(0)]]
                                                         ) {
        float4 pupilColor = pupilTexture.sample(pupilSampler, vertexIn.textureCoordinate);
        constexpr float3 lumCoeff = float3(0.299f, 0.587f, 0.114f);
        float lightness = dot(color.rgb, lumCoeff);
        pupilColor.a = pupilColor.a * (1.0 - saturate(pow(lightness + 0.6,20.0))) * intensity * color.a;
        float Ls = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
        float Lb = 0.3 * pupilColor.r + 0.59 * pupilColor.g + 0.11 * pupilColor.b;
        float4 B  = Ls > Lb ? float4(color.rgb, 1.0) : pupilColor;
        return blendBaseAlpha(float4(color.rgb, 1.0), pupilColor, B);
    }
    
    vertex CXPointsVertexOut cx3DFaceVertex(
                                            const device VertexIn * vertices [[ buffer(0) ]],
                                            uint vid [[ vertex_id ]],
                                            constant float4x4 &projectionMatrix [[ buffer(1) ]],
                                            constant float4x4 &modelViewMatrix [[ buffer(2) ]]
                                       ) {
        CXPointsVertexOut outVertex;
        VertexIn inVertex = vertices[vid];
        outVertex.position = projectionMatrix * modelViewMatrix * inVertex.position;
        outVertex.pointSize = 10;
        return outVertex;
    }
    
    fragment float4 cx3DFaceFragment(CXPointsVertexOut vertexIn [[ stage_in ]],
                                     float4 color [[color(0)]]
                                     ) {
        return normalBlend(color,float4(1.0,0.0,0.0,0.1));
    }
    
    fragment float4 cxClarity(VertexOut vertexIn [[ stage_in ]],
                              texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                              sampler inputSampler [[ sampler(0) ]],
                              texture2d<float, access::sample> inputMeanTexture [[ texture(1) ]],
                              sampler inputMeanSampler [[ sampler(1) ]],
                              constant float &clarityAlpha [[buffer(0)]]
                              ) {
        float4 inputColor = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float3 iColor = inputColor.rgb;
        float3 meanColor = inputMeanTexture.sample(inputMeanSampler, vertexIn.textureCoordinate).rgb;
        float3 diffColor = iColor - meanColor;
        diffColor = min(diffColor, 0.0);
        iColor += (diffColor + 0.015) * clarityAlpha;
        iColor = max(iColor, 0.0);
        return float4(iColor, inputColor.a);
    }
    
    fragment float4 cxBigEye(VertexOut vertexIn [[ stage_in ]],
                             texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                             sampler inputSampler [[ sampler(0) ]],
                             constant float2 &centerLeft [[buffer(0)]],
                             constant float2 &centerRight [[buffer(1)]],
                             constant float &radiusLeft [[buffer(2)]],
                             constant float &radiusRight [[buffer(3)]],
                             constant float &scale [[buffer(4)]]
                              ) {
        const float2 textureSize = float2(inputTexture.get_width(),inputTexture.get_height());
        const float2 textureCoordinate = vertexIn.textureCoordinate * textureSize;
        float distanceLeft = distance(centerLeft, textureCoordinate);
        if (distanceLeft < radiusLeft) {
            float2 offset = textureCoordinate - centerLeft;
            float percent = 1.0 - ((radiusLeft - distanceLeft) / radiusLeft) * scale;
            percent = percent * percent;
            offset *= percent;
            return inputTexture.sample(inputSampler, (centerLeft + offset)/textureSize);
        }
        float distanceRight = distance(centerRight, textureCoordinate);
        if (distanceRight < radiusRight) {
            float2 offset = textureCoordinate - centerRight;
            float percent = 1.0 - ((radiusRight - distanceRight) / radiusRight) * scale;
            percent = percent * percent;
            offset *= percent;
            return inputTexture.sample(inputSampler, (centerRight + offset)/textureSize);
        }
        return inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
    }
    
    fragment float4 cxSoftEdgeFilterBlendKernel(VertexOut vertexIn [[ stage_in ]],
                                        texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                        sampler colorSampler [[ sampler(0) ]],
                                        texture2d<float, access::sample> overlayTexture [[ texture(1) ]],
                                        sampler overlaySampler [[ sampler(1) ]],
                                        constant float &intensity [[buffer(0)]]
                                        ) {
        float4 color = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        float4 foregroundColor = overlayTexture.sample(overlaySampler, vertexIn.textureCoordinate);
        float3 result = color.rgb + foregroundColor.rgb;
        return float4(mix(color.rgb, result.rgb, intensity),color.a);
    }
    
    fragment float4 cxFaceHighlightShadow(VertexOut vertexIn [[ stage_in ]],
                                          texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                          sampler inputSampler [[ sampler(0) ]],
                                          texture2d<float, access::sample> inputMaskTexture [[ texture(1) ]],
                                          sampler inputMaskSampler [[ sampler(1) ]],
                                          float4 color [[color(0)]],
                                          constant float &intensity [[buffer(0)]],
                                          constant float3 &angles [[buffer(1)]]
                                          ) {
        float4 uCf = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 uCb = color;
        float4 blendedColor = overlayBlend(uCb, uCf);
        float4 maskColor = inputMaskTexture.sample(inputMaskSampler, vertexIn.textureCoordinate);
        float i = (1.0 - maskColor.g * saturate((angles.g - 10.0)/10.0));
        float j = (1.0 - maskColor.r * saturate((-angles.g - 10.0)/10.0));
        return mix(uCb,blendedColor,intensity * min(i, j));
    }
    
    fragment float4 cxDefaultFaceBlush(VertexOut vertexIn [[ stage_in ]],
                                       texture2d<float, access::sample> maskTexture [[ texture(0) ]],
                                       sampler maskSampler [[ sampler(0) ]],
                                       texture2d<float, access::sample> lookupTexture [[ texture(1) ]],
                                       sampler lookupSampler [[ sampler(1) ]],
                                       float4 backgroundColor [[color(0)]],
                                       constant float &intensity [[buffer(0)]],
                                       constant float4 &color [[buffer(1)]]
                                       ) {
        float4 materialColor = maskTexture.sample(maskSampler, vertexIn.textureCoordinate);
        float4 srcColor = backgroundColor;
        float factor = materialColor.r * color.a * intensity;
        float4 lutColor;
        lutColor.r = lookupTexture.sample(lookupSampler, float2((color.r * 255.0 + 0.5)/256.0, (srcColor.r * 255.0 + 0.5)/256.0)).r;
        lutColor.g = lookupTexture.sample(lookupSampler, float2((color.g * 255.0 + 0.5)/256.0, (srcColor.g * 255.0 + 0.5)/256.0)).g;
        lutColor.b = lookupTexture.sample(lookupSampler, float2((color.b * 255.0 + 0.5)/256.0, (srcColor.b * 255.0 + 0.5)/256.0)).b;
        lutColor.a = srcColor.a;
        return float4(mix(srcColor.rgb,lutColor.rgb,factor), srcColor.a);
    }
}
