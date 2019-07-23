//
//  MDImageEditorContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/10/30.
//

#import <UIKit/UIKit.h>
#import "MDMediaEditorContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDImageEditorContext : MDMediaEditorContext

- (instancetype)initWithImage:(UIImage *)image completionHander:(void(^)(CVPixelBufferRef _Nullable, NSError * _Nullable))completion;

@property (nonatomic, readonly) CIContext *ciContext;

@property (nonatomic, strong) id<MDProcessImageProtocol> filter;

@property (nonatomic, readonly) UIImage *image;

- (void)saveImage:(UIImage *)image completion:(void(^ _Nullable)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
