//
//  MDVideoExport.h
//  RecordSDK
//
//  Created by sunfei on 2018/11/30.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MDVideoExportProtocol.h"
#import "MDProcessImageProtocol.h"
#import "MDAssetProcessProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoExport : NSObject <MDVideoExportProtocol>

// asset and audiomix to export
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAudioMix *audioMix;

// asset parameters
@property (nonatomic, assign) CGAffineTransform videoPerferredTransform;
@property (nonatomic, assign) float targetBitRate;
@property (nonatomic, assign) CGSize presentationSize;
@property (nonatomic, assign) CMFormatDescriptionRef _Nullable audioFormatHint;

// filters
@property (nonatomic, strong) id<MDProcessImageProtocol> imageProcess;

// export
- (id<MDCancellable> _Nullable)exportToURL:(NSURL *)url
                           progressHandler:(void(^ _Nullable)(double progress))progressHandler
                                completion:(void(^ _Nullable)(NSURL *url))completion
                                   failure:(void(^ _Nullable)(NSError * _Nullable error))failure;

@end

NS_ASSUME_NONNULL_END
