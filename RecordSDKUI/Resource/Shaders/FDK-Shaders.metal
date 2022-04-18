//
//  Shaders.metal
//  Pods
//
//  Created by Yu Ao on 15/11/2017.
//

#include "MTIShaderLib.h"

#include <metal_stdlib>
using namespace metal;

using namespace metalpetal;

namespace fdk {
    
#define SST 0.888
#define SSQ 0.288
#define MIN_S 4.0
#define MAX_S 4.0
#define ORIGIN float2(0.5, 0.5)
#define DOTSIZE 1.48
    typedef struct {
        float4 position [[ position ]];
        float2 texcoordL;
        float2 texcoordR;
        float2 texcoordT;
        float2 texcoordB;
        float2 texcoordTL;
        float2 texcoordTR;
        float2 texcoordBL;
        float2 texcoordBR;
    } Varyings;
    
    inline float4 rgb2cmyk(float3 c)
    {
        float k = max(max(c.r, c.g), c.b);
        return min(float4(c.rgb / k, k), float4(1.0));
    }
    
    inline float3 cmyk2rgb(float4 c)
    {
        return c.rgb * c.a;
    }
    
    inline float4 ss(float4 v)
    {
        return smoothstep(SST-SSQ, SST+SSQ, v);
    }
    
    inline float3 rgb2hsv(float3 c)
    {
        float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
        float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
        float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
        float d = q.x - min(q.w, q.y);
        float e = 1.0e-10;
        return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }
    
    float2 grid(float2 px, float S){
        return float2(px.x - mod(px.x , S), px.y - mod(px.y , S));
    }
    
    float4 halftone(float2 fc, float2x2 m, float S, texture2d<float, access::sample> inputImageTexture, sampler inputImageSampler) {
        float2 smp = (grid(m*fc, S) + 0.5*S) * m;
        float s = min(length(fc-smp) / (DOTSIZE*0.5*S), 1.0);
        float3 texc = inputImageTexture.sample(inputImageSampler, smp+ORIGIN).rgb;
        texc = pow(texc, float3(2.2));
        float4 c = rgb2cmyk(texc);
        return c+s;
    }
    
    float2x2 rotm(float r) {
        float cr = cos(r);
        float sr = sin(r);
        return float2x2(float2(cr,-sr),
                        float2(sr,cr));
    }
    
    float radians(float degree) {
        return 3.1415926 * degree / 180.0;
    }
    
    float4 halftone(float2 textureCoordinate, float2 textureSize, texture2d<float, access::sample> inputImageTexture, sampler inputImageSampler)
    {
        float4 fragColor = float4(1.0);
        float R = 0.;
        float S = MIN_S/textureSize.x;
        
        float2 fc = textureCoordinate.xy - ORIGIN;
        
        float2x2 mc = rotm(R + radians(15.0));
        float2x2 mm = rotm(R + radians(75.0));
        float2x2 my = rotm(R);
        float2x2 mk = rotm(R + radians(45.0));
        
        //        float k = halftone(fc, mk, S, inputImageTexture, inputImageSampler).a;
        float3 c = cmyk2rgb(ss(float4(
                                      halftone(fc, mc, S, inputImageTexture, inputImageSampler).r,
                                      halftone(fc, mm, S, inputImageTexture, inputImageSampler).g,
                                      halftone(fc, my, S, inputImageTexture, inputImageSampler).b,
                                      halftone(fc, mk, S, inputImageTexture, inputImageSampler).a
                                      )));
        
        c = pow(c, float3(1.0/2.2));
        fragColor = float4(c, 1.0);
        return fragColor;
    }
    
    // Sobel
    
    
    
    
    float3 YCoCr(float3 color_in) {
        
        const float3x3 YCoCr_mat = float3x3(
                                            float3(0.25, 0.5, 0.25),
                                            float3(-0.25, 0.5, -0.25),
                                            float3(0.5, 0, -0.5));
        
        return YCoCr_mat * color_in;
    }
    
    float calc_sobel_res(float3x3 I) {
        
        const float3x3 sx = float3x3(
                                     float3(1.0, 2.0, 1.0),
                                     float3(0.0, 0.0, 0.0),
                                     float3(-1.0, -2.0, -1.0));
        
        const float3x3 sy = float3x3(
                                     float3(1.0, 0.0, -1.0),
                                     float3(2.0, 0.0, -2.0),
                                     float3(1.0, 0.0, -1.0));
        
        
        float gx = dot(sx[0], I[0]) + dot(sx[1], I[1]) + dot(sx[2], I[2]);
        float gy = dot(sy[0], I[0]) + dot(sy[1], I[1]) + dot(sy[2], I[2]);
        
        return sqrt(pow(gx, 2.0)+pow(gy, 2.0));
    }
    
    float3 comic_sobel(float2 fragCoord, float2 textureSize, texture2d<float, access::sample> inputImageTexture, sampler inputImageSampler) {
        float3x3 Y;
        float3x3 Co;
        float3x3 Cr;
        float3 temp;
        for (int i=0; i<3; i++) {
            for (int j=0; j<3; j++) {
                float2 pos = (fragCoord + float2(i-1.0, j-1.0)) / textureSize;
                temp = YCoCr(inputImageTexture.sample(inputImageSampler, pos).rgb);
                Y[i][j] = temp.r;
                Co[i][j] = temp.g;
                Cr[i][j] = temp.b;
            }
        }
        return float3(calc_sobel_res(Y), calc_sobel_res(Co), calc_sobel_res(Cr));
    }
    
#define SIGMA 10.0
#define BSIGMA 0.1
#define MSIZE 15
    
    constant bool GAMMA_CORRECTION = false;
    
    
    inline float normpdf(float x, float sigma) {
        return 0.39894 * exp(-0.5 * x * x/ (sigma * sigma)) / sigma;
    }
    
    inline  float normpdf3(float3 v, float sigma) {
        return 0.39894 * exp(-0.5 * dot(v,v) / (sigma * sigma)) / sigma;
    }
    
    
    
    inline float4 bilateral(float2 textureCoord,
                            float2 textureSize,
                            texture2d<float, access::sample> inputImageTexture,
                            sampler inputImageSampler) {
        float compute[MSIZE];
        float4 fragColor = float4(1.0);
        float3 c = inputImageTexture.sample(inputImageSampler, textureCoord).rgb;
        const int kSize = (MSIZE - 1) / 2;
        float3 finalColor = float3(0.0);
        float Z = 0.0;
        float2 fragCoord = textureCoord * textureSize;
        
        // unfortunately, WebGL 1.0 does not support constant arrays...
        compute[0] = compute[14] = 0.031225216;
        compute[1] = compute[13] = 0.033322271;
        compute[2] = compute[12] = 0.035206333;
        compute[3] = compute[11] = 0.036826804;
        compute[4] = compute[10] = 0.038138565;
        compute[5] = compute[9]  = 0.039104044;
        compute[6] = compute[8]  = 0.039695028;
        compute[7] = 0.039894000;
        float bZ = 0.2506642602897679;
        
        
        float3 cc;
        float factor;
        //read out the texels
        for (int i=-kSize; i <= kSize; ++i) {
            for (int j=-kSize; j <= kSize; ++j) {
                cc = inputImageTexture.sample(inputImageSampler, (fragCoord + float2(float(i),float(j))) / textureSize).rgb;
                factor = normpdf3(cc-c, BSIGMA) * bZ * compute[kSize+j] * compute[kSize+i];
                Z += factor;
                if (GAMMA_CORRECTION) {
                    finalColor += factor * pow(cc, float3(2.2));
                } else {
                    finalColor += factor * cc;
                }
            }
        }
        
        if (GAMMA_CORRECTION) {
            fragColor = float4(pow(finalColor / Z, float3(1.0/2.2)), 1.0);
        } else {
            fragColor = float4(finalColor / Z, 1.0);
        }
        
        return fragColor;
    }
    
    
    
    inline float3 hsv2rgb(float3 c)
    {
        float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }
    
    float3 rgb2yuv(float3 c){
        return clamp(float3(0.299 * c.r + 0.587 * c.g + 0.114 * c.b, -0.169 * c.r - 0.331 * c.g + 0.499 * c.b + 0.5, 0.499 * c.r - 0.418 * c.g - 0.0813* c.b + 0.5), 0., 1.);
    }
    
    float3 yuv2rgb(float3 c){
        return clamp(float3(c.r + 1.402 * (c.b - 0.5), c.r - 0.344 * (c.g - 0.5) - 0.714 * (c.b - 0.5), c.r + 1.772 * (c.g - 0.5)), 0., 1.);
    }
    
    fragment float4 skinWhitenV0(VertexOut vertexIn [[ stage_in ]],
                                 texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                 sampler colorSampler [[ sampler(0) ]],
                                 constant float & skinLightingScaleValue [[buffer(0)]]
                                 ) {
        float4 textureColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        float skinLightingScale = skinLightingScaleValue*0.9+1.;
        
        if(abs(skinLightingScale - 1.) < 0.01) {
            return textureColor;
        } else {
            return float4(log(textureColor.rgb * (skinLightingScale - 1.) + float3(1., 1., 1.)) / log(skinLightingScale), textureColor.a);
        }
    }
    
    fragment float4 skinWhitenV1(VertexOut vertexIn [[ stage_in ]],
                                 texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                 sampler colorSampler [[ sampler(0) ]],
                                 constant float & skinLightingScaleValue [[buffer(0)]],
                                 constant float4 & skinDefaultRGB [[buffer(2)]]
                                 ) {
        float4 textureColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        float4 rColor = float4(0);
        float epslone = 0.006*skinLightingScaleValue*skinLightingScaleValue;
        float4 source = textureColor;
        rColor = source;
        
        if(skinLightingScaleValue < 0.05){
            return rColor;
        }
        
        //         float3 faceYUV = rgb2yuv(skinDefaultRGB);
        //0.6 -> 1.0
        //    float lightScale = clamp((faceYUV.r - 0.32) * 2.55, 0.6, 1.);
        //         float lightScale = clamp((faceYUV.r - 0.23) * 2.55, 0.45, 1.);         float3 relation = float3(1.0) - abs(skinDefaultRGB - source.xyz);
        float3 relation = float3(1.0) - abs(skinDefaultRGB.rbg - source.xyz);
        relation = 1./(1. + exp(39. - 60. * relation));
        float4 eps = float4(epslone * relation, epslone);
        if(any(eps < float4(0.000001))){
            rColor = source;
            return rColor;
        }
        //relation=1./(1.+exp(24.-30.*relation));
        float param = 1.05 + relation.x * relation.y * relation.z * relation.x * relation.y * relation.z * relation.x * relation.y * relation.z * skinLightingScaleValue;
        
        float3 paramVec = float3(param*1.4, param*1.1, param*1.3);
        //gl_FragColor.rgb = log(gl_FragColor.rgb * (skinLightingScale - 1.) + float3(1., 1., 1.)) / log(skinLightingScale);
        float3 a = log(rColor.rgb*(paramVec - float3(1.)) + float3(1.));
        rColor.rgb = clamp(a/log(paramVec),0.,1.);
        return rColor;
    }
    
    fragment float4 horizontalGaussian(VertexOut vertexIn [[ stage_in ]],
                                       texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                       sampler colorSampler [[ sampler(0) ]],
                                       constant float4 & floatParameter [[buffer(0)]]
                                       ) {
        
        float4 result = float4(0.);
        const int w = 4;
        const float minStep = 0.8;
        const float xInc = minStep / 480.;
        float4 temp;
        
        for (int i = 0;i<w;i++){
            temp = colorTexture.sample(colorSampler, float2(vertexIn.textureCoordinate.x+(float(i) - 2.) * xInc, vertexIn.textureCoordinate.y));
            result += floatParameter[i] * temp;
        }
        return result;
    }
    
    fragment float4 verticalGaussian(VertexOut vertexIn [[ stage_in ]],
                                     texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                     sampler colorSampler [[ sampler(0) ]],
                                     constant float4 & floatParameter [[buffer(0)]]
                                     ) {
        
        float4 result = float4(0.);
        const int w = 4;
        const float minStep = 0.8;
        const float yInc = minStep / 640.;
        float4 tmp;
        
        for (int j = 0;j<w;j++){
            tmp = colorTexture.sample(colorSampler, float2(vertexIn.textureCoordinate.x, vertexIn.textureCoordinate.y+(float(j) - 2.) * yInc));
            result += floatParameter[j] * tmp;
        }
        return result;
    }
    
    // edgePass ---
    fragment float4 edgePassGuided(VertexOut vertexIn [[ stage_in ]],
                                   texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                   sampler colorSampler [[ sampler(0) ]],
                                   constant float & skinLightingScaleValue [[buffer(0)]],
                                   constant float & widthOffset [[buffer(1)]],
                                   constant float & heightOffset [[buffer(2)]],
                                   constant float & minStep [[buffer(3)]],
                                   constant int & winSize [[buffer(4)]],
                                   constant float3 & lowSkinThreshold [[buffer(5)]],
                                   constant float3 & highSkinThreshold [[buffer(6)]],
                                   constant float3 & skinDefaultRGB [[buffer(7)]]
                                   ) {
        
        float epslone = 0.006 * skinLightingScaleValue * skinLightingScaleValue;
        float xInc = minStep * widthOffset;
        float yInc = minStep * heightOffset;
        
        float4 rColor = float4(0.);
        float4 b = float4(0.);
        float4 a = float4(0.);
        float4 meanI = float4(0.);
        float4 meanII = float4(0.);
        float4 temp = float4(0.);
        
        float4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        float3 relation = float3(1.0) + min((sourceColor.xyz - skinDefaultRGB), float3(0.0));
        float meanrelation = (relation.x+relation.y+relation.z)/3.0;
        relation = float3(meanrelation);
        relation = 1./(1. + exp(24. - 30. * relation));
        float4 eps = float4(epslone * relation, epslone);
        
        //this one can be judged outside shader
        if (any(eps < float4(0.000001))) {
            rColor = sourceColor;
            return rColor;
        }
        
        for(int i = 0; i < winSize; i++) {
            for(int j = 0; j < winSize; j++) {
                temp = colorTexture.sample(colorSampler, float2( vertexIn.textureCoordinate.x + (-float(winSize / 2) * xInc) + float(i) * xInc, vertexIn.textureCoordinate.y + (-float(winSize / 2) * yInc) + float(j) * yInc));
                meanI += temp;
                meanII += temp * temp;
            }
        }
        meanI /= float(winSize * winSize);
        meanII /= float(winSize * winSize);
        temp = meanII - meanI * meanI;
        a = temp / (temp + eps);
        b = meanI - a * meanI;
        rColor = a * sourceColor + b;
        return rColor;
    }
    
    fragment float4 edgePassSurface(VertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]],
                                    constant float & skinLightingScaleValue [[buffer(0)]],
                                    constant float & widthOffset [[buffer(1)]],
                                    constant float & heightOffset [[buffer(2)]],
                                    constant float & minStep [[buffer(3)]],
                                    constant int & winSize [[buffer(4)]],
                                    constant float3 & lowSkinThreshold [[buffer(5)]],
                                    constant float3 & highSkinThreshold [[buffer(6)]],
                                    constant float3 & skinDefaultRGB [[buffer(7)]]
                                    ) {
        float4 rColor = float4(0.);
        float xInc = minStep * widthOffset;
        float yInc = minStep * heightOffset;
        float T = skinLightingScaleValue * 20./255.;
        float4 temp;
        float4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        if (skinLightingScaleValue < 0.001 ) {
            rColor = sourceColor;
            return rColor;
        }
        if(all (lowSkinThreshold <= sourceColor.xyz))
        {
            float3 sum = float3(0.);
            float3 sumW = float3(0.);
            for(int i = 0; i < winSize; i++) {
                for(int j = 0; j < winSize; j++) {
                    temp = colorTexture.sample(colorSampler, float2( vertexIn.textureCoordinate.x + (-float(winSize / 2) * xInc) + float(i) * xInc, vertexIn.textureCoordinate.y + (-float(winSize / 2) * yInc) + float(j) * yInc));
                    float3 w = 1. - abs(temp.xyz - sourceColor.xyz)/(2.5*T);
                    if (w.x < 0.) {
                        w.x = 0.;
                    }
                    if (w.y < 0.) {
                        w.y = 0.;
                    }
                    if (w.z < 0.) {
                        w.z = 0.;
                    }
                    sumW = sumW + w;
                    sum = sum + w * temp.xyz;
                }
            }
            rColor.xyz = sum / sumW;
        } else {
            rColor = sourceColor;
        }
        return rColor;
    }
    
    fragment float4 edgePassGuidedMSQRD(VertexOut vertexIn [[ stage_in ]],
                                        texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                        sampler colorSampler [[ sampler(0) ]],
                                        constant float & skinLightingScaleValue [[buffer(0)]],
                                        constant float & widthOffset [[buffer(1)]],
                                        constant float & heightOffset [[buffer(2)]],
                                        constant float & minStep [[buffer(3)]],
                                        constant int & winSize [[buffer(4)]],
                                        constant float3 & lowSkinThreshold [[buffer(5)]],
                                        constant float3 & highSkinThreshold [[buffer(6)]],
                                        constant float3 & skinDefaultRGB [[buffer(7)]]
                                        ) {
        float epslone = 0.006 * skinLightingScaleValue * skinLightingScaleValue;
        // float epslone = 0.006*0.36;
        float xInc = minStep * widthOffset;
        float yInc = minStep * heightOffset;
        float4 rColor = float4(0.);
        float4 a = float4(0.);
        float4 b = float4(0.);
        float4 meanI = float4(0.);
        float4 meanII = float4(0.);
        float4 temp = float4(0.);
        float4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        float3 relation = float3(1.) + min((sourceColor.xyz - skinDefaultRGB), float3(0.0));
        float meanrelation = (relation.x + relation.y + relation.z) / 3.0;
        relation = float3(meanrelation);
        relation = 1./ (1. + exp(24. - 30. * relation));
        float4 eps = float4(1.);
        eps.xyz = epslone * relation; //float4(epslone * relation, epslone);
        
        //this one can be judged outside shader
        if (any(eps < float4(0.000001))) {
            rColor = float4(0.5,0.5,0.5,1.);
            return rColor;
        }
        
        for(int i = 0; i < winSize; i++) {
            for(int j = 0; j < winSize; j++) {
                temp = colorTexture.sample(colorSampler, float2( vertexIn.textureCoordinate.x + (-float(winSize / 2) * xInc) + float(i) * xInc, vertexIn.textureCoordinate.y + (-float(winSize / 2) * yInc) + float(j) * yInc));
                meanI += temp;
                meanII += temp * temp;
            }
        }
        meanI /= float(winSize * winSize);
        meanII /= float(winSize * winSize);
        temp = meanII - meanI * meanI;
        a = clamp(temp / (temp + eps), 0.0, 1.0);
        b = meanI - a * meanI;
        rColor = a * sourceColor + b;
        rColor = float4(rColor.xyz- sourceColor.xyz + float3(0.5,0.5,0.5), 1.0);
        return rColor;
    }
    
    fragment float4 linearLightMixMSQRD(VertexOut vertexIn [[ stage_in ]],
                                        texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                        sampler inputSampler [[ sampler(0) ]],
                                        texture2d<float, access::sample> inputBackgroundTexture [[ texture(1) ]],
                                        sampler inputBackgroundSampler [[ sampler(1) ]]
                                        ) {
        
        float4 color1 = inputTexture.sample(inputSampler, vertexIn.textureCoordinate);
        float4 color2 = inputBackgroundTexture.sample(inputBackgroundSampler, vertexIn.textureCoordinate); //  textureCoordinate2 ?
        float4 rColor = float4(color1.xyz + 2.*color2.xyz - float3(1.,1.,1.), 1.0);
        return  mix(rColor, color1, 0.5);
    }
    
    //        float3 B2_spline(float3 x) { // returns 3 B-spline functions of degree 2
    //            float3 t = 3.0 * x;
    //            float3 b0 = step(0.0, t)     * step(0.0, 1.0-t);
    //            float3 b1 = step(0.0, t-1.0) * step(0.0, 2.0-t);
    //            float3 b2 = step(0.0, t-2.0) * step(0.0, 3.0-t);
    //            return 0.5 * (
    //                          b0 * pow(t, float3(2.0)) +
    //                          b1 * (-2.0*pow(t, float3(2.0)) + 6.0*t - 3.0) +
    //                          b2 * pow(3.0-t,float3(2.0))
    //                          );
    //        }
    
    fragment float4 audioVisualizationFilterSample(VertexOut vertexIn [[ stage_in ]],
                                                   texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                                                   sampler inputSampler [[ sampler(0) ]],
                                                   constant float & iGlobalTime [[buffer(0)]]) {
        
        // create pixel coordinates
        float2 uv =  vertexIn.textureCoordinate;
        
        float fVBars = 30.0;
        //            float fHSpacing = 10.00;
        
        
        float x = floor(uv.x * fVBars)/fVBars;
        float fSample = inputTexture.sample(inputSampler, float2(abs(2.0 * x - 1.0), 0.25)).x;
        
        float squarewave = sign(mod(uv.x, 1.0/fVBars)-0.012);
        float fft = squarewave * fSample* 0.5;
        
        float fHBars = 100.0;
        float fVSpacing = 0.0;
        float fVFreq = (uv.y * 3.1415926535);
        fVFreq = sign(sin(fVFreq * fHBars)+1.0-fVSpacing);
        
        //            float2 centered = float2(1.0) * uv - float2(1.0) ;
        //            float t = iGlobalTime / 100.0;
        //            float polychrome = 1.0;
        //            float3 spline_args = fract(float3(polychrome*uv.x-t) + float3(0.0, -1.0/3.0, -2.0/3.0));
        //            float3 spline = B2_spline(spline_args);
        //
        //            float f = abs(centered.y);
        float3 base_color  = float3(1.0, 1.0, 1.0);
        float3 flame_color = base_color;
        
        float tt = 0.5 - uv.y;
        float df = sign(tt);
        df = (df + 1.0)/0.5;
        float3 col = flame_color * float3(1.0 - step(fft, abs(0.5-uv.y))) * float3(fVFreq);
        
        // output final color
        return float4(col, 1.0 - step(col,float3(0.0,0.0,0.0)).x);
    }
    
    
    fragment float4 colorStroke(VertexOut vertexIn [[ stage_in ]],
                                texture2d<float, access::sample> inputOriginTexture [[ texture(0) ]],
                                sampler  inputOriginSampler [[ sampler(0) ]],
                                texture2d<float, access::sample> inputFilterTexture [[ texture(1) ]],
                                sampler  inputFilterSampler [[ sampler(1) ]],
                                constant bool & strokeEnabled[[buffer(0)]],
                                constant int & strokeRadius[[buffer(1)]],
                                constant float4 & strokeColor[[buffer(2)]],
                                constant float2 & stepValue[[buffer(3)]]
                                ) {
        float4 picture = float4(0);
        if (strokeEnabled) {
            float intensityForEdge = 0;
            float2 center = vertexIn.textureCoordinate;
            float4 centerTex = inputFilterTexture.sample(inputFilterSampler, center);
            float intensity = centerTex.r;
            for (int i = 0; i < strokeRadius; i++) {
                float2 left = center + float2(stepValue.x * float(i), 0.0);
                float2 right = center + float2(stepValue.x * -float(i), 0.0);
                float2 top = center + float2(0.0, -stepValue.y * float(i));
                float2 bottom = center + float2(0.0, +stepValue.y * float(i));
                float4 leftTex = inputFilterTexture.sample(inputFilterSampler, left);
                float4 rightTex = inputFilterTexture.sample(inputFilterSampler,right);
                float4 topTex = inputFilterTexture.sample(inputFilterSampler, top);
                float4 bottomTex = inputFilterTexture.sample(inputFilterSampler, bottom);
                intensity = (intensity+(leftTex.r+rightTex.r+ topTex.r+ bottomTex.r)*(1.0-float(i)/float(strokeRadius)));
            }
            intensityForEdge = intensity * float(strokeRadius);
            if (intensityForEdge > 0.0) {
                return strokeColor;
            } else {
                return picture;
            }
        } else {
            return  picture;
        }
    }
    
    float intensity(float4 color, float threshold){
        return sign(sqrt((color.x*color.x)+(color.y*color.y)+(color.z*color.z))-threshold);
    }
    
    vertex Varyings nearbySampleVertex(const device VertexIn * vertices [[ buffer(0) ]],
                                       uint vid [[ vertex_id ]],
                                       constant float2 & textureSize [[ buffer(1) ]]) {
        Varyings varyings;
        VertexIn inVertex = vertices[vid];
        varyings.position = inVertex.position;
        
        float2 widthStep = float2(textureSize.x, 0.0);
        float2 heightStep = float2(0.0, textureSize.y);
        float2 widthNegativeHeightStep = float2(textureSize.x, -textureSize.y);
        
        varyings.texcoordL = inVertex.textureCoordinate - widthStep;
        varyings.texcoordR = inVertex.textureCoordinate + widthStep;
        varyings.texcoordT = inVertex.textureCoordinate - heightStep;
        varyings.texcoordTL = inVertex.textureCoordinate - textureSize;
        varyings.texcoordTR = inVertex.textureCoordinate + widthNegativeHeightStep;
        varyings.texcoordB = inVertex.textureCoordinate + heightStep;
        varyings.texcoordBL = inVertex.textureCoordinate - widthNegativeHeightStep;
        varyings.texcoordBR = inVertex.textureCoordinate + textureSize;
        return varyings;
    }
    
    fragment float4 sobel(Varyings nearbyVertex [[ stage_in ]],
                          texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                          sampler  inputTextureSampler [[ sampler(0) ]],
                          constant float & threshold [[buffer(0)]],
                          constant bool & sobelEnabled [[buffer(1)]]
                          ) {
        
        if (sobelEnabled) {
            
            float tleft = intensity(inputTexture.sample(inputTextureSampler, clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordTL)), threshold);
            float left = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordL)), threshold);
            float bleft = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordBL)), threshold);
            float top = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordT)), threshold);
            float bottom = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordB)), threshold);
            float tright = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordTR)), threshold);
            float right = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordR)), threshold);
            float bright = intensity(inputTexture.sample(inputTextureSampler,  clamp(float2(0.0), float2(1.0), nearbyVertex.texcoordBR)), threshold);
            
            // Sobel masks (see http://en.wikipedia.org/wiki/Sobel_operator)
            //        1 0 -1     -1 -2 -1
            //    X = 2 0 -2  Y = 0  0  0
            //        1 0 -1      1  2  1
            
            // You could also use Scharr operator:
            //        3 0 -3        3 10   3
            //    X = 10 0 -10  Y = 0  0   0
            //        3 0 -3        -3 -10 -3
            
            float x = 1.0*tleft + 2.0*left + 1.0*bleft - 1.0*tright - 2.0*right - 1.0*bright;
            float y = -1.0*tleft - 2.0*top - 1.0*tright + 1.0*bleft + 2.0 * bottom + 1.0*bright;
            //float x = 3.0*tleft + 10.0*left + 3.0*bleft - 3.0*tright - 10.0*right - 3.0*bright;
            //float y = -3.0*tleft - 10.0*top - 3.0*tright + 3.0*bleft + 10.0 * bottom + 3.0*bright;
            
            float color = sqrt((x*x) + (y*y));
            return float4(float3(color), 1.0);
        } else {
            return float4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    float4 softlight(float4 base, float4 overlay) {
        float alphaDivisor = base.a + step(base.a, 0.0); // Protect against a divide-by-zero blacking out things in the output
        return base * (overlay.a * (base / alphaDivisor) + (2.0 * overlay * (1.0 - (base / alphaDivisor)))) + overlay * (1.0 - base.a) + base * (1.0 - overlay.a);
    }
    
    float4 multiply(float4 base, float4 overlayer) {
        return overlayer * base + overlayer * (1.0 - base.a) + base * (1.0 - overlayer.a);
    }
    
    float lum(float3 c) {
        return dot(c, float3(0.3, 0.59, 0.11));
    }
    
    float3 clipcolor(float3 c) {
        float l = lum(c);
        float n = min(min(c.r, c.g), c.b);
        float x = max(max(c.r, c.g), c.b);
        
        if (n < 0.0) {
            c.r = l + ((c.r - l) * l) / (l - n);
            c.g = l + ((c.g - l) * l) / (l - n);
            c.b = l + ((c.b - l) * l) / (l - n);
        }
        if (x > 1.0) {
            c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
            c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
            c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
        }
        
        return c;
    }
    
    float3 setlum(float3 c, float l) {
        float d = l - lum(c);
        c = c + float3(d);
        return clipcolor(c);
    }
    
    fragment float4 facialMask(VertexOut vertexIn [[ stage_in ]],
                               texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                               sampler colorSampler [[ sampler(0) ]],
                               float4 backgroundColor [[ color(0) ]],
                               constant float & maskOpacity [[ buffer(0) ]],
                               constant bool & maskHasPremultiply [[ buffer(1) ]]
                               ) {
        float4 maskColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        if (maskHasPremultiply) {
            maskColor = unpremultiply(maskColor);
        }
        maskColor.a = maskColor.a * maskOpacity;
        if (maskColor.a > 0.0) {
            float4 overlay = maskColor;
            float4 overlayAlpha = overlay;
            
            overlay.rgb = overlay.rgb * overlay.a;
            
            overlayAlpha.a = 0.7 * overlay.a;
            overlayAlpha.rgb = overlayAlpha.rgb * overlayAlpha.a;
            
            float4 base = backgroundColor;
            base = softlight(base,overlay);
            base = softlight(base,overlay);
            base = multiply(base,overlayAlpha);
            
            float4 baseColor = base;
            float4 overlayColor = overlay;
            
            return float4(baseColor.rgb * (1.0 - overlayColor.a) + setlum(overlayColor.rgb, lum(baseColor.rgb)) * overlayColor.a, baseColor.a);
        } else {
            return backgroundColor;
        }
    }
    
    fragment float4 mosaic(VertexOut vertexIn [[ stage_in ]],
                           texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                           sampler colorSampler [[ sampler(0) ]],
                           constant float & intensity [[ buffer(0) ]],
                           constant float & textureWHRatio [[ buffer(1) ]]
                           ) {
        float2 mos_coord;
        if (intensity > 0) {
            float factor = 25.0 / intensity;
            mos_coord = floor(vertexIn.textureCoordinate * float2(factor, factor * textureWHRatio)) / float2(factor, factor * textureWHRatio);
        } else {
            mos_coord = vertexIn.textureCoordinate;
        }
        return colorTexture.sample(colorSampler,mos_coord);
    }
    
    fragment float4 crosshatch(VertexOut vertexIn [[ stage_in ]],
                               texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                               sampler colorSampler [[ sampler(0) ]],
                               constant float & intensity [[ buffer(0) ]],
                               constant float2 & textureSize [[ buffer(1) ]]
                               ) {
        float4 sourceColor = colorTexture.sample(colorSampler, vertexIn.textureCoordinate);
        if (intensity > 0) {
            float factor = ceil(10.0 * intensity) ;
            
            float2 pixelCoord = float2(vertexIn.textureCoordinate.x * textureSize.x, vertexIn.textureCoordinate.y * textureSize.y);
            
            float lightWeight = length(sourceColor.rgb);
            
            if (lightWeight < 1.0) {
                if (mod(floor(pixelCoord.x + pixelCoord.y), factor) == 0.0) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
            }
            if (lightWeight < 0.75) {
                if (mod(floor(pixelCoord.x - pixelCoord.y), factor) == 0.0) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
            }
            if (lightWeight < 0.5) {
                if (mod(floor(pixelCoord.x + pixelCoord.y - factor * 0.5), factor) == 0.0) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
            }
            if (lightWeight < 0.3) {
                if (mod(floor(pixelCoord.x - pixelCoord.y - factor * 0.5), factor) == 0.0) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
            }
            return float4(1.0);
        }
        return sourceColor;
    }
    
    float comic_texture(float x, float y, texture2d<float, access::sample> inputImageTexture,
                     sampler inputImageSampler, float2 textureSize)
    {
        float4 currentC = inputImageTexture.sample(inputImageSampler, float2(x, y) / textureSize);
        return (currentC.r + currentC.g + currentC.b)/3.0;
    }
    
    fragment float4 comic(VertexOut vertexIn [[ stage_in ]],
                          texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                          sampler colorSampler [[ sampler(0) ]],
                          constant float & intensity [[ buffer(0) ]],
                          constant float2 & textureSize [[ buffer(1) ]]
                          ) {
        float threshold = 0.2;
        float2 uv = vertexIn.textureCoordinate;
        float2 fragCoord = uv * textureSize;
        float x = fragCoord.x;
        float y = fragCoord.y;
        
        float xValue = -comic_texture(x-1.0, y-1.0, colorTexture, colorSampler, textureSize) - comic_texture(x-1.0, y, colorTexture, colorSampler, textureSize) - comic_texture(x-1.0, y+1.0, colorTexture, colorSampler, textureSize)
        + comic_texture(x+1.0, y-1.0, colorTexture, colorSampler, textureSize) + comic_texture(x+1.0, y, colorTexture, colorSampler, textureSize) + comic_texture(x+1.0, y+1.0, colorTexture, colorSampler, textureSize);
        float yValue = comic_texture(x-1.0, y-1.0, colorTexture, colorSampler, textureSize) + comic_texture(x, y-1.0, colorTexture, colorSampler, textureSize) + comic_texture(x+1.0, y-1.0, colorTexture, colorSampler, textureSize)
        - comic_texture(x-1.0, y+1.0, colorTexture, colorSampler, textureSize) - comic_texture(x, y+1.0, colorTexture, colorSampler, textureSize) - comic_texture(x+1.0, y+1.0, colorTexture, colorSampler, textureSize);
        
        if(length(float2(xValue, yValue)) > threshold)
        {
            return float4(0);
        }
        else
        {
            float4 currentPixel = colorTexture.sample(colorSampler, uv);
            return currentPixel;
        }
    }
    
    // -- effect list

    fragment float4 changeColorLut(VertexOut vertexIn [[ stage_in ]],
                                   texture2d<float, access::sample> inputImageTexture [[ texture(0) ]],
                                   texture2d<float, access::sample> lut0ImageTexture [[ texture(1) ]],
                                   texture2d<float, access::sample> lut1ImageTexture [[ texture(2) ]],
                                   sampler inputImageSampler [[ sampler(0) ]],
                                   sampler lut0ImageSampler [[ sampler(1) ]],
                                   sampler lut1ImageSampler [[ sampler(2) ]],
                                   constant float & intensity [[ buffer(0) ]],
                                   constant float & radian [[ buffer(1) ]]
                                   ) {
        float4 textureColor = inputImageTexture.sample(inputImageSampler,  vertexIn.textureCoordinate);
        float4 lut0out = lut0ImageTexture.sample(lut0ImageSampler,  vertexIn.textureCoordinate);
        float4 lut1out = lut1ImageTexture.sample(lut1ImageSampler,  vertexIn.textureCoordinate);
        
        float density = sin(radian);
        density = (density + 1.0) / 2.0;
        
        return mix(textureColor, mix(lut0out, lut1out, density), intensity);
    }
    
    // fishEye
    
    float rand(float2 co) {
        return fract(sin(dot(co.xy,float2(12.9898,78.233))) * 43758.5453);
    }
    
    float4 getBg(texture2d<float, access::sample> texture, sampler textureSampler, float2 uv){
        float2 center = float2(0.5, 0.5);
        
        float2 rr = uv + 0.01 * 1.4 * (uv - center);
        float2 bb = uv - 0.02 * 1.4 * (uv - center);
        
        float r_Value = texture.sample(textureSampler, clamp(rr, 0.0, 1.0)).r;
        float g_Value = texture.sample(textureSampler, uv).g;
        float b_Value = texture.sample(textureSampler, clamp(bb, 0.0, 1.0)).b;
        
        float4 fragColor = float4(r_Value, g_Value, b_Value, 1.0);
        
        return fragColor;// + vec4(rand(uv * (uTime / 1000.0))) * 0.1;
    }
    
    float3 checker(texture2d<float, access::sample> texture, sampler textureSampler, float2 uv){
        return getBg(texture, textureSampler,uv).rgb;
    }
    
    float3 checker2(float2 uv){
        return float3(0.);
    }
    
    float4 getColor(texture2d<float, access::sample> texture, sampler textureSampler, float2 uv, float2 ratio){
        
        float d = length(uv);
        if(d>1.) return float4(checker2(uv),1.);//vec4(0.); //getBg(blurImage, textureCoordinate)*(2.-d);
        float z = sqrt(1.0 - 1.*d * d); //0.8->radius
        float r = atan2(d, z) / 3.141592653589; //main deform function -> 1. /(m_pi/2) for normalization, then /2 for scale to [0,0.5]
        
        float phi = atan2(uv.y, uv.x);
        
        uv = float2(r*cos(phi),r*sin(phi) * ratio.x);
        uv*=1.8; //intensity
        uv += float2(.5);
        
        return float4(checker(texture, textureSampler, uv),1.);
    }
    
    float4 blend_normal(float4 base, float4 overlay){
        return base + overlay*(1.-base.a);
    }
    
    float4 reverse(texture2d<float, access::sample> texture, sampler textureSampler, float2 uv)
    {
        float2 tex = uv;
        tex.y = 1. - tex.y;
        return texture.sample(textureSampler,tex);
    }

    fragment float4 fishEye(VertexOut vertexIn [[ stage_in ]],
                            texture2d<float, access::sample> inputImageTexture [[ texture(0) ]],
                            texture2d<float, access::sample> boxTexture [[ texture(1) ]],
                            texture2d<float, access::sample> backgroundTexture [[ texture(2) ]],
                            sampler inputImageSampler [[ sampler(0) ]],
                            sampler boxImageSampler [[ sampler(1) ]],
                            sampler backgroundImageSampler [[ sampler(2) ]],
                            constant float & radius [[ buffer(0) ]],
                            constant float & depth [[ buffer(1) ]]
                                   ) {
        float2 uv = vertexIn.textureCoordinate * 2. - float2(1.);
        uv /= 1.4; //radius of visible
        float2 ratio = float2(1.0, 1.0);
        uv /= float2(1., ratio.x);
        float4 fragColor = getColor(inputImageTexture, inputImageSampler, uv, ratio);
        
        float4 boxColor = boxTexture.sample(boxImageSampler, vertexIn.textureCoordinate);
        float4 bottomColor = backgroundTexture.sample(backgroundImageSampler,vertexIn.textureCoordinate);
        //    boxColor = blend_normal(bottomColor,boxColor);
        //    fragColor = blend_normal(boxColor ,fragColor);
        float4 rColor;
        rColor  = blend_normal(bottomColor ,fragColor);
        rColor  = blend_normal(boxColor ,fragColor);
        //    bottomColor = blend_normal(boxColor,bottomColor);
        //    fragColor = blend_normal(bottomColor,fragColor);
        return rColor;

    }
    
#define p2  float2(0.109322,0.090341)
#define p4  float2(0.141959,0.406709)
#define p6  float2(0.167116,0.519916)
#define p8  float2(0.194969,0.633124)
#define p10 float2(0.243486,0.734801)
#define p12 float2(0.311770,0.820755)
#define p14 float2(0.389039,0.887841)
#define p16 float2(0.484277,0.918239)
#define p18 float2(0.582210,0.894130)
#define p20 float2(0.670261,0.833333)
#define p22 float2(0.743935,0.755765)
#define p24 float2(0.798742,0.656184)
#define p26 float2(0.831986,0.541929)
#define p28 float2(0.850854,0.423480)
#define p30 float2(0.867925,0.308176)
#define p43 float2(0.495957,0.209476)
#define p46 float2(0.495957,0.420000)
#define p44 float2(0.495957,0.284382)
#define p45 float2(0.495957,0.369287)
    
#define x_a 1.0
#define y_a 1.0
    
    struct Triangle {
        float2 A;
        float2 B;
        float2 C;
        Triangle(float2 a,float2 b,float2 c)
        {
            A=a;
            B=b;
            C=c;
            
            
        }
    };
    
    bool pointInTriangle(float2 p, Triangle triangle) {
        float2 A = triangle.A;
        float2 B = triangle.B;
        float2 C = triangle.C;
        
        float2 v0 = C - A;
        float2 v1 = B - A;
        float2 v2 = p - A;
        
        float dot00 = dot(v0,v0);
        float dot01 = dot(v0,v1);
        float dot02 = dot(v0,v2);
        float dot11 = dot(v1,v1);
        float dot12 = dot(v1,v2);
        
        float inverDeno = 1.0 / (dot00 * dot11 - dot01 * dot01);
        
        float u = (dot11 * dot02 - dot01 * dot12) * inverDeno;
        float v = (dot00 * dot12 - dot01 * dot02) * inverDeno;
        
        float condition;
        if((u >= 0.0 && u <= 1.0)
           && (v >= 0.0 && v <= 1.0)
           && (u+v <= 1.0)) {
            return true;
        } else {
            return false;
        }
    }
    
    float2 triangleTransform(float2 curPoint,Triangle dstTriangle,Triangle srcTriangle)
    {
        float2 A = dstTriangle.A;
        float2 B = dstTriangle.B;
        float2 C = dstTriangle.C;
        
        float2 a = srcTriangle.A;
        float2 b = srcTriangle.B;
        float2 c = srcTriangle.C;
        
        float2 AP = curPoint - A;
        float2 BC = C - B;
        
        float apxy = AP.x/AP.y;
        float bcyx = BC.y/BC.x;
        
        float2 D = float2(0.0);
        D.y = apxy*bcyx;
        D.x = B.y*apxy - A.y*apxy - B.x*D.y + A.x;
        D.x /= 1.0 - D.y;
        D.y = D.x*bcyx - B.x*bcyx + B.y;
        
        apxy = length(D - B)/length(BC);
        bcyx = length(AP)/length(D - A);
        
        D = b + (c-b)*apxy;
        D = a + (D-a)*bcyx;
        
        return D;
    }
    
    float2 faceStretch(float2 textureCoord, float2 originPosition, float2 targetPosition, float radius, float curve)
    {
        float2 direction = targetPosition - originPosition;
        float lengthA = length(direction);
        if(lengthA<0.0001)   return direction;
        float lengthB = min(lengthA, radius);
        direction *= lengthB / lengthA;
        float infect = distance(textureCoord, originPosition)/radius;
        infect = clamp(1.0-infect,0.0,1.0);
        infect = pow(infect, curve);
        
        return direction * infect;
    }
    
    float2 stretchFun(float2 textureCoord, float2 originPosition, float2 targetPosition, float radius)
    {
        float2 offset = float2(0.0);
        float2 result = float2(0.0);
        
        float2 direction = targetPosition - originPosition;
        float lengthA = length(direction);
        
        float infect = distance(textureCoord, originPosition)/radius;
        
        infect = 1.0 - infect;
        infect = clamp(infect,0.0,1.0);
        offset = direction * infect;
        
        result = textureCoord - offset;
        
        return result;
    }
    
    float2 enlargeFun(float2 curCoord,float2 circleCenter,float radius,float intensity)
    {
        float currentDistance = distance(curCoord,circleCenter);
        {
            float weight = currentDistance/radius;
            weight = 1.0-intensity*(1.0-weight*weight);
            weight = clamp(weight,0.0,1.0);
            curCoord = circleCenter+(curCoord-circleCenter)*weight;
        }
        return curCoord;
    }
    
    float2 narrowFun(float2 curCoord,float2 circleCenter,float radius,float intensity)
    {
        float currentDistance = distance(curCoord,circleCenter);
        {
            float weight = currentDistance/radius;
            weight = 1.0-intensity*(1.0-weight*weight);
            weight = clamp(weight,0.0001,1.0);
            curCoord = circleCenter+(curCoord-circleCenter)/weight;
        }
        return curCoord;
    }
    
    
    fragment float4 bigMouthKP(VertexOut vertexIn [[ stage_in ]],
                              texture2d<float, access::sample> maskTexture [[ texture(0) ]],
                              texture2d<float, access::sample> inputTexture [[ texture(1) ]],
                              sampler colorSampler [[ sampler(0) ]],
                              constant float & intensity [[ buffer(0) ]],
                              constant float2 & textureSize [[ buffer(1) ]],
                              device  const float  *landmarks [[ buffer(2) ]]
                              ) {
        
        float4  originColor = inputTexture.sample(colorSampler,vertexIn.textureCoordinate);

        float2 pos2   = float2(landmarks[0],landmarks[1]);
        float2 pos4   = float2(landmarks[2],landmarks[3]);
        float2 pos6   = float2(landmarks[4],landmarks[5]);
        float2 pos8   = float2(landmarks[6],landmarks[7]);
        float2 pos10  = float2(landmarks[8],landmarks[9]);
        float2 pos12  = float2(landmarks[10],landmarks[11]);
        float2 pos14  = float2(landmarks[12],landmarks[13]);
        float2 pos16  = float2(landmarks[14],landmarks[15]);

        float2 pos18   = float2(landmarks[16],landmarks[17]);
        float2 pos20   = float2(landmarks[18],landmarks[19]);
        float2 pos22   = float2(landmarks[20],landmarks[21]);
        float2 pos24   = float2(landmarks[22],landmarks[23]);
        float2 pos26  = float2(landmarks[24],landmarks[25]);
        float2 pos28  = float2(landmarks[26],landmarks[27]);
        float2 pos30  = float2(landmarks[28],landmarks[29]);
        float2 pos43  = float2(landmarks[30],landmarks[31]);
        
        float2 pos44   = float2(landmarks[32],landmarks[33]);
        float2 pos45   = float2(landmarks[34],landmarks[35]);
        float2 pos46   = float2(landmarks[36],landmarks[37]);
        float2 pos87   = float2(landmarks[38],landmarks[39]);
        float2 pos98  = float2(landmarks[40],landmarks[41]);
        float2 pos102  = float2(landmarks[42],landmarks[43]);
        
        float surfaceWidth = textureSize.x;
        float surfaceHeight = textureSize.y;
        
        if(pos46.x > 0.03 || pos46.y > 0.03) {
            float2 sampleCoordinate   = float2(0.0);
            float4 sampleColor        = float4(0.0);
            
            if(length((pos43-pos16)*403.0/638.0)>distance(pos16,pos46))
            {
                pos44 = pos16+(pos43-pos16)*560.0/638.0;
                pos45 = pos16+(pos43-pos16)*480.0/638.0;
                pos46 = pos16+(pos43-pos16)*403.0/638.0;
            }
            
            float scale = 0.68;
            float2 curPoint = vertexIn.textureCoordinate;
            float2 mouthCenter = (pos98+pos102)*0.5-(pos16-pos46)*0.5;
            float2 center = pos46;
            float2 vMove = (pos46-pos87)*0.825;
            
            Triangle dstTriangle = Triangle(pos2,pos4,pos46);
            Triangle srcTriangle = Triangle(p2,p4,p46);
            float condition = pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos4,pos6,pos46);
            srcTriangle = Triangle(p4,p6,p46);
            
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos6,pos8,pos46);
            srcTriangle = Triangle(p6,p8,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos8,pos10,pos46);
            srcTriangle = Triangle(p8,p10,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos10,pos12,pos46);
            srcTriangle = Triangle(p10,p12,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos12,pos14,pos46);
            srcTriangle = Triangle(p12,p14,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {                        sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos14,pos16,pos46);
            srcTriangle = Triangle(p14,p16,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos16,pos18,pos46);
            srcTriangle = Triangle(p16,p18,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos18,pos20,pos46);
            srcTriangle = Triangle(p18,p20,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos20,pos22,pos46);
            srcTriangle = Triangle(p20,p22,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos22,pos24,pos46);
            srcTriangle = Triangle(p22,p24,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos24,pos26,pos46);
            srcTriangle = Triangle(p24,p26,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos26,pos28,pos46);
            srcTriangle = Triangle(p26,p28,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos28,pos30,pos46);
            srcTriangle = Triangle(p28,p30,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            //------------------------------------------
            dstTriangle = Triangle(pos2,pos45,pos46);
            srcTriangle = Triangle(p2,p45,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos2,pos44,pos45);
            srcTriangle = Triangle(p2,p44,p45);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos2,pos43,pos44);
            srcTriangle = Triangle(p2,p43,p44);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos30,pos45,pos46);
            srcTriangle = Triangle(p30,p45,p46);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos30,pos44,pos45);
            srcTriangle = Triangle(p30,p44,p45);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            dstTriangle = Triangle(pos30,pos43,pos44);
            srcTriangle = Triangle(p30,p43,p44);
            condition=pointInTriangle(curPoint,dstTriangle);
            if (condition > 0.8) {
                sampleCoordinate = triangleTransform(curPoint,dstTriangle,srcTriangle);
                sampleColor = maskTexture.sample(colorSampler, sampleCoordinate);
            }
            
            float2 targetPoint = curPoint - vMove;
            targetPoint = (targetPoint-mouthCenter)*scale+mouthCenter;
            
            float4 findColor = inputTexture.sample(colorSampler,targetPoint);
            
            float2 xYProportion     = float2(surfaceWidth,surfaceHeight);
            if(0.0==surfaceWidth||0.0==surfaceHeight) {
                xYProportion  = float2(x_a,y_a);
            }
            return mix(originColor,findColor,sampleColor.a);;
        }  else {
            return originColor;
        }
    }
}
