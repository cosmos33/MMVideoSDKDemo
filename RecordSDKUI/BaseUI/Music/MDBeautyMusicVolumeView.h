//
//  MDBeautyMusicVolumeView.h
//  MDChat
//
//  Created by Fu.Chen on 2018/5/9.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMusicVolumeViewHeight       (75)

@protocol MDBeautyMusicVolumeViewDelegate<NSObject>
@required
- (void) progressDidChange:(CGFloat)progress;

@end

@interface MDBeautyMusicVolumeView : UIView

@property (nonatomic,weak) id<MDBeautyMusicVolumeViewDelegate> delegate;

@property (nonatomic,assign) CGFloat        progress;
- (void)updateVolumeProgress:(CGFloat)progress;
- (void)setMusicNameText:(NSString *)name;

@end
