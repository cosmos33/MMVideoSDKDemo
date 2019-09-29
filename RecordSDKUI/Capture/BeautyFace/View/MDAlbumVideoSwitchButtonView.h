//
//  MDAlbumVideoSwitchButtonView.h
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDAlbumVideoSwitchButtonView : UIView

@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, copy) void(^titleButtonClicked)(MDAlbumVideoSwitchButtonView *switchButtonView, NSInteger index);

- (void)setSelectedIndex:(NSInteger)index;
- (NSInteger)currentSelectedIndex;

@end
