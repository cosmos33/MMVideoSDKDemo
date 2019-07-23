//
//  MDMusicResourceUtility.h
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MDMusicBVO;

@interface MDMusicResourceUtility : NSObject

+ (BOOL)checkAssetValidWithURL:(NSURL *)url sizeConstraint:(BOOL)needConstraint;

+ (CMTimeRange)timeRangeWithStartPercent:(CGFloat)startPercent endPercent:(CGFloat)endPercent duration:(CMTime)duration;

+ (NSString *)keyWithMusicBVO:(MDMusicBVO *)bvo;

@end

NS_ASSUME_NONNULL_END
