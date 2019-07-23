//
//  MDBeautyMusicManager.h
//  MDChat
//
//  Created by sdk on 2018/5/11.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDBeautyMusic.h"
#import <CoreMedia/CoreMedia.h>

#define kMYFavorCategary    @"kMYFavorCategary"

@class MDMomentMusicListCellModel;
@interface MDBeautyMusicManager : NSObject

+ (MDBeautyMusic *)localMusic:(NSString *)m_musicID;

+ (void)setMusic:(MDBeautyMusic *)music;
+ (void)setMusics:(NSArray *)array;
/**
 * 获取一组music
 * @return:array 内容为MDBeautyMusic
 */
+ (NSArray *)getMusics:(NSArray *)m_musicIDs;

+ (BOOL)checkAssetValid:(NSURL *)url sizeConstraint:(BOOL)needConstraint;
+ (NSURL *)getMusicLocalPath:(MDBeautyMusic *)musicItem;
+ (MDMomentMusicListCellModel *)coverMusicItemToCellItem:(MDBeautyMusic *)musicItem;
+ (CMTimeRange)getMusicTimeRangeWithURL:(NSURL *)localUrl;

@end
