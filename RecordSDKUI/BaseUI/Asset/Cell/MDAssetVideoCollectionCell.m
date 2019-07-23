//
//  MDAssetVideoCollectionCell.m
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetVideoCollectionCell.h"
#import "MDRecordHeader.h"

@interface MDAssetVideoCollectionCell ()

@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) UILabel         *timeLabel;
@property (nonatomic, strong) UIImageView     *videoIcon;
@property (nonatomic, strong) UIView          *maskView;

@end

@implementation MDAssetVideoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView.layer addSublayer:self.shadowLayer];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.videoIcon];
        [self.contentView addSubview:self.maskView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}


- (void)bindModel:(MDPhotoItem *)item {
    [super bindModel:item];
    
    self.timeLabel.text = [MDRecordContext formatRemainSecondToStardardTime:item.asset.duration];
    CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(100, 16)];
    self.timeLabel.width = size.width;
    self.timeLabel.right = self.width-5;
    self.videoIcon.right = self.timeLabel.left-4.5;
}

- (void)setEnableSelect:(BOOL)enable {
    self.maskView.hidden = enable;
}

- (void)userDidTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.cellDelegate respondsToSelector:@selector(assetVideoCellClickVideo:)]) {
            [self.cellDelegate assetVideoCellClickVideo:self];
        }
    }
}


#pragma mark - UI

- (CAGradientLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [CAGradientLayer layer];
        _shadowLayer.frame = self.imageView.bounds;
        _shadowLayer.colors = @[(__bridge id)RGBACOLOR(0, 0, 0, 0).CGColor, (__bridge id)RGBACOLOR(0, 0, 0, 0.3).CGColor];
        _shadowLayer.startPoint = CGPointMake(0.5, 0);
        _shadowLayer.endPoint = CGPointMake(0.5, 1.0);
    }
    return _shadowLayer;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:self.contentView.bounds];
        _maskView.backgroundColor = RGBACOLOR(255, 255, 255, 0.7);
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width-65, self.height-20, 60, 16)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _timeLabel;
}

- (UIImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_album_video"]];
        _videoIcon.centerY = self.timeLabel.centerY;
    }
    return _videoIcon;
}


@end
