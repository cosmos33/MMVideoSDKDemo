//
//  MDMusicBottomEditView.h
//  MDChat
//
//  Created by YZK on 2018/11/14.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMusicCollectionItem.h"
#import "MDRecordHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDMusicBottomEditViewDelegate <NSObject>

@optional
- (void)musicDidPlayEndWithTimeRange:(CMTimeRange)timeRange;
- (void)musicDidEditWithTimeRange:(CMTimeRange)timeRange;
- (void)musicDidSeletedMusicItem:(MDMusicCollectionItem *)item timeRange:(CMTimeRange)timeRange;

@end


@interface MDMusicBottomEditView : UIView

@property (nonatomic, weak) AVPlayer *musicPlayer;
@property (nonatomic, weak) id<MDMusicBottomEditViewDelegate> delegate;
@property (nonatomic, strong, readonly) MDMusicCollectionItem *item;
@property (nonatomic, assign, readonly) CMTimeRange currentTimeRange;

- (void)bindModel:(MDMusicCollectionItem *)item;
- (void)periodicTimeCallback:(CMTime)time;

@end

NS_ASSUME_NONNULL_END
