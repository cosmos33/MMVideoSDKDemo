//
//  MDBeautyMusicCell.h
//  MDChat
//
//  Created by Leery on 2018/5/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDBeautyMusicManager.h"

@interface MDMomentMusicListCellModel : NSObject

//id
@property (nonatomic, copy) NSString            *identifier;
@property (nonatomic, strong) id                dataObj;
@property (nonatomic, strong) NSString          *cateID;
@property (nonatomic, strong) NSURL             *localUrl;
@property (nonatomic, copy) NSString            *localMusicId;
@property (nonatomic, assign) CMTime            duration;
@property (nonatomic, assign) BOOL              isSelected;
@property (nonatomic, assign) BOOL              isDownloading;
@property (nonatomic, assign) BOOL              showTopLine;
@property (nonatomic, assign) BOOL              showBottomLine;
@property (nonatomic, assign) BOOL              showArrow;
@property (nonatomic, strong) NSString          *celltitle;
@property (nonatomic, strong) NSString          *targetString;
@property (nonatomic, assign) CGFloat           musicStartPercent;
@property (nonatomic, assign) CGFloat           musicEndPercent;
@property (nonatomic, assign) CMTimeRange       timeRange;

- (instancetype)initWithMusicID:(NSString *)musicID;

@end

static const CGFloat kBeautyMusicCellHeight = 55;
@interface MDBeautyMusicCell : UITableViewCell

@property (nonatomic, strong) UILabel                       *titleLabel;
- (void)bindModel:(id)model;

@end
