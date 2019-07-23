//
//  MDRenderContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/11/29.
//

#import <Foundation/Foundation.h>
@class MTIContext;

NS_ASSUME_NONNULL_BEGIN

@interface MDRenderContext : NSObject

+ (MTIContext *)metalContext;
+ (EAGLContext *)openGLESContext;

@end

NS_ASSUME_NONNULL_END
