//
//  MDRecordNewMusicTrimView.h
//  MDRecordSDK
//
//  Created by wangxuefei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDSMSelectIntervalProgressView;
@class MDRecordNewMusicTrimView;
NS_ASSUME_NONNULL_BEGIN

@protocol MDRecordNewMusicTrimViewDelegate <NSObject>

- (void)valueChanged:(MDRecordNewMusicTrimView *)view startPercent:(CGFloat)startPercent endPercent:(CGFloat)endPercent;

@end


@interface MDRecordNewMusicTrimView : UIView





@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) BOOL disable;

@property (nonatomic, assign) CGFloat beginTime;

@property (nonatomic, assign) CGFloat currentValue;

@property (nonatomic, weak) id <MDRecordNewMusicTrimViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
