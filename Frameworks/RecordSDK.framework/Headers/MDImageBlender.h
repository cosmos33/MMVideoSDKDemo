//
//  MDImageBlender.h
//  MomoChat
//
//  Created by sunfei on 2018/12/27.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDImageBlender : NSObject

+ (nullable UIImage *)imageByBlendImage:(UIImage *)image withOverlayImage:(UIImage *)overlayImage;

@end

NS_ASSUME_NONNULL_END
