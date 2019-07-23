//
//  MDMomentThumbCell.m
//  MDChat
//
//  Created by Leery on 16/12/28.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentThumbCell.h"
#import "MDRecordHeader.h"

#if !__has_feature(objc_arc)
#error MDMomentThumbCell must be built with ARC.
#endif

@interface MDMomentThumbCell ()
@property (nonatomic ,strong) UIImageView       *coverNailImageView;
@end

@implementation MDMomentThumbCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        [self setupCellContentView];
    }
    return self;
}

- (void)setupCellContentView {
    
    self.coverNailImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.coverNailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverNailImageView.clipsToBounds = YES;
    self.coverNailImageView.backgroundColor = ALL_VIEW_BACKGROUND_COLOR;
    [self addSubview:self.coverNailImageView];
}

- (void)updateCoverNailImageWithImage:(UIImage *)image {
    
    if(image) {
        [self.coverNailImageView setImage:image];
    }
}

@end
