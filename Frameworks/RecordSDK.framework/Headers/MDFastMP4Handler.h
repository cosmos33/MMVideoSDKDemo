//
//  MDFastMP4Handler.h
//  videosdk
//
//  Created by YZK on 2019/1/9.
//  Copyright © 2019 videosdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDFastMP4Handler : NSObject

+ (int)MP4FastWithSrcMP4Path:(NSString *)pSrcMP4Path pDstMP4Path:(NSString *)pDstMP4Path;

@end

NS_ASSUME_NONNULL_END
