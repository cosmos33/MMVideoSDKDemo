//
//  MDFilter.h
//  MomoChat
//
//  Created by jichuan on 2017/6/16.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MLFilterDescriptor;
@class GPUImageOutput;
@protocol GPUImageInput;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordFilter : NSObject

@property (readonly) NSURL *contentsOfURL;
@property (readonly) NSString *identifier;
@property (readonly) NSString *name;
@property (readonly) NSString *iconPath;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContentsOfURL:(NSURL *)url name:(NSString *)name iconPath:(NSString *)iconPath identifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithContentsOfURL:(NSURL *)url;

// 创建原图Filter
+ (MDRecordFilter *)createOriginalEffectFilter;

// Make GPUImageFilter with lazy loading
- (GPUImageOutput<GPUImageInput> *)makeGPUImageFilter;

// Processes the specified image using the receiver synchronously
- (UIImage *)imageByProcessImage:(UIImage *)image;

// Processes the specified image using the receiver asynchronously, the completionHandler called on the main thread
- (void)processImage:(UIImage *)image completionHandler:(void (^)(UIImage *outputImage))completionHandler;

@end

@interface MDRecordFilter (Copying) <NSCopying>

@end

@interface MDRecordFilter (Equal)

@end

@interface MDRecordFilter (ProcessingQueue)

+ (NSOperationQueue *)globalProcessingQueue;

@end

@interface MDRecordFilterBlender : NSObject

+ (nullable UIImage *)imageByBlendImage:(UIImage *)image withOverlayImage:(UIImage *)overlayImage;

@end

NS_ASSUME_NONNULL_END
