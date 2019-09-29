//
//  MDFilterSegmentView.h
//  MomoChat
//
//  Created by YZK on 2019/4/10.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MDFilterSegmentView : UIView

- (instancetype)initWithOrigin:(CGPoint)origin title:(NSArray<NSString *> *)titles;

@property (nonatomic, copy) void(^titleButtonClicked)(NSInteger index);
@property (nonatomic, copy) void(^resetButtonClicked)(NSInteger index);

- (void)setSelectedIndex:(NSInteger)index;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@end
