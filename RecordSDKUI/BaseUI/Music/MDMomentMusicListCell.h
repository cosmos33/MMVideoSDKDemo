//
//  MDMomentMusicListCell.h
//  MDChat
//
//  Created by wangxuan on 17/2/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDBeautyMusicCell.h"
#import "MDSMSelectIntervalProgressView.h"
#import "MDBeautyMusicManager.h"

@class MDMomentMusicListCell;

static const CGFloat kMusicCellTrimmerViewHeight = 70;
static const CGFloat kMomentMusicListCellHeight = 45;
@protocol MDMomentMusicListCellDelegate <NSObject>

@optional
- (void)currentMusic:(MDMomentMusicListCellModel *)cellModel begainPoint:(CGFloat)begain endPoint:(CGFloat)end;

@end

@interface MDMomentMusicListCell : MDBeautyMusicCell

@property (nonatomic, assign) float progress;

@end
