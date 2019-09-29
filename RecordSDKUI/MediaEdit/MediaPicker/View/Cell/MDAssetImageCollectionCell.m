//
//  MDAssetImageCollectionCell.m
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetImageCollectionCell.h"

@interface MDAssetImageCollectionCell ()

@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) UIImageView *selectedView;
@property (nonatomic, strong) UILabel     *numLabel;
@property (nonatomic, strong) UIView      *selectedMaskView;

@end


@implementation MDAssetImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView.layer addSublayer:self.shadowLayer];
        [self.contentView addSubview:self.selectedMaskView];
        [self.contentView addSubview:self.selectedView];
        [self.selectedView addSubview:self.numLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}


- (void)bindModel:(MDPhotoItem *)item {
    [super bindModel:item];
    
    if (item.selected) {
        self.selectedView.image = [UIImage imageNamed:@"icon_album_selected"];
        self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)self.item.idxNumber];
        self.selectedMaskView.hidden = NO;
    } else {
        self.selectedView.image = [UIImage imageNamed:@"icon_album_unselected"];
        self.numLabel.text = @"";
        self.selectedMaskView.hidden = YES;
    }
}

- (void)setEnableSelect:(BOOL)enable {
    self.selectedView.hidden = !enable;
    self.numLabel.hidden = !enable;
}

#pragma mark - event

- (void)userDidTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [sender locationInView:self];
        if (tapPoint.x > self.width/2.0 && tapPoint.y < self.height/2.0) {//选中
            [self tapSelectAction];
        } else {//进预览
            [self tapPreviewAction];
        }
    }
}

- (void)tapSelectAction {
    BOOL canSelect = YES;
    if ([self.cellDelegate respondsToSelector:@selector(assetImageCellCanSelect:)]) {
        canSelect = [self.cellDelegate assetImageCellCanSelect:self];
    }
    if (!canSelect) {
        return;
    }
    self.item.selected = !self.item.selected;
    if (self.item.selected) {
        self.selectedView.image = [UIImage imageNamed:@"icon_album_selected"];
        self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)self.item.idxNumber];
        self.selectedMaskView.hidden = NO;
    } else {
        self.selectedView.image = [UIImage imageNamed:@"icon_album_unselected"];
        self.numLabel.text = @"";
        self.selectedMaskView.hidden = YES;
    }
    
    if ([self.cellDelegate respondsToSelector:@selector(assetImageCell:didClickImageWithSelected:)]) {
        [self.cellDelegate assetImageCell:self didClickImageWithSelected:self.item.selected];
    }
}

- (void)tapPreviewAction {
    if ([self.cellDelegate respondsToSelector:@selector(assetImageCellClickPreview:)]) {
        [self.cellDelegate assetImageCellClickPreview:self];
    }
}

- (void)refreshSelectedNumber {
    if (self.item.selected) {
        self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)self.item.idxNumber];
    }
}


#pragma mark - UI

- (CAGradientLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [CAGradientLayer layer];
        _shadowLayer.frame = self.imageView.bounds;
        _shadowLayer.colors = @[(__bridge id)RGBACOLOR(255, 255, 255, 0).CGColor, (__bridge id)RGBACOLOR(0, 0, 0, 0.19).CGColor];
        _shadowLayer.startPoint = CGPointMake(0.5, 1.0);
        _shadowLayer.endPoint = CGPointMake(0.5, 0.0);
    }
    return _shadowLayer;
}

- (UIImageView *)selectedView {
    if (!_selectedView) {
        UIImage *image = [UIImage imageNamed:@"icon_album_unselected"];
        _selectedView = [[UIImageView alloc] initWithImage:image];
        _selectedView.frame = CGRectMake(self.width-30, 5, image.size.width, image.size.height);
    }
    return _selectedView;
}

- (UIView *)selectedMaskView {
    if (!_selectedMaskView) {
        _selectedMaskView = [[UIView alloc]initWithFrame:self.contentView.bounds];
        _selectedMaskView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        _selectedMaskView.hidden = YES;
    }
    return _selectedMaskView;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]initWithFrame:self.selectedView.bounds];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _numLabel;
}



@end
