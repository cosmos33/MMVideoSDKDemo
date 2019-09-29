//
//  MDFilterRecordView.m
//  MomoChat
//
//  Created by YZK on 2019/4/19.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDFilterRecordView.h"
#import "MDRecordColorCircleView.h"
#import "MDRecordWhiteRingView.h"

@interface MDFilterRecordView ()
@property (nonatomic, strong) MDRecordWhiteRingView *whiteRingView;
@property (nonatomic, strong) MDRecordColorCircleView *colorCircleView;
@end

@implementation MDFilterRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.whiteRingView = [[MDRecordWhiteRingView alloc] initWithFrame:self.bounds];
//        [self.whiteRingView setLineWidth:2.0];
        [self addSubview:self.whiteRingView];
        
        self.colorCircleView = [[MDRecordColorCircleView alloc] initWithFrame:self.whiteRingView.frame];
//        [self.colorCircleView setLineWidth:3.0];
        self.colorCircleView.hidden = YES;
        [self addSubview:self.colorCircleView];
    }
    return self;
}

- (void)setRecordLevelType:(MDUnifiedRecordLevelType)levelType
{
    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        self.whiteRingView.hidden = NO;
        self.colorCircleView.hidden = YES;
    } else {
        self.whiteRingView.hidden = YES;
        self.colorCircleView.hidden = NO;
    }
}

- (void)beginAniamtion {
    if (self.colorCircleView.hidden) {
        return;
    }
    [self.colorCircleView beginAniamtion];
}

- (void)endAnimation {
    [self.colorCircleView endAnimation];
}

@end
