//
//  MDAlbumVideoDynamicEffectCollectionViewCell.m
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAlbumVideoDynamicEffectCollectionViewCell.h"
#import "UIView+Utils.h"
#import "UIColor+MDRUtils.h"
@import CoreGraphics;
@import MMFoundation;

@interface MDAlbumVideoDynamicEffectCollectionViewCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIImageView *loadingView;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation MDAlbumVideoDynamicEffectCollectionViewCell

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self addGesture];
    }
    return self;
}

- (void)setupUI {
    NSMutableArray *constraints = [NSMutableArray array];
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.layer.cornerRadius = 12;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [constraints addObject:[imageView.widthAnchor constraintEqualToConstant:60]];
        [constraints addObject:[imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor]];
        imageView;
    });
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
        label;
    });
    
    {
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.imageView, self.label]];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 8;
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment = UIStackViewAlignmentCenter;
        [self.contentView addSubview:stackView];
        [constraints addObject:[stackView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor]];
        [constraints addObject:[stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor]];
    }
    
    self.loadingView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_play_loading"]];
        imageView.frame = CGRectMake(0, 0, 30, 30);
        imageView.hidden = YES;
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    [NSLayoutConstraint activateConstraints:constraints];
}

-(CADisplayLink *)displayLink {
    if (!_displayLink) {
        MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    return _displayLink;
}

- (void)startLoading {
    self.imageView.alpha = 0.2f;
    self.displayLink.paused = NO;
    self.loadingView.hidden = NO;
    
    CGPoint center = [self.contentView convertPoint:CGPointMake(self.imageView.width / 2, self.imageView.height / 2) fromView:self.imageView];
    self.loadingView.center = center;
}

- (void)endLoading {
    self.displayLink.paused = YES;
    self.loadingView.hidden = YES;
    self.imageView.alpha = 1.0f;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    
    CGAffineTransform transform = self.loadingView.transform;
    
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

- (void)setCellModel:(MDAlbumVideoDynamicEffectModel *)cellModel {
    _cellModel = cellModel;
    
    self.label.text = cellModel.title;
    self.imageView.image = self.selected ? cellModel.selectedIcon : cellModel.icon;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

//    self.imageView.image = selected ? self.cellModel.selectedIcon : self.cellModel.icon;
    if (selected) {
        self.imageView.layer.borderColor = [UIColor mdr_colorWithHexString:@"00C0FF"].CGColor;
        self.imageView.layer.borderWidth = 2.0;
        self.label.textColor = UIColor.whiteColor;
    } else {
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.0;
        self.label.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    }
    
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    if (self.cellModel.isNeedDownload) {
        [self startLoading];
        __weak typeof(self) weakself = self;
        [self.cellModel startDownloadWithCompletion:^(MDAlbumVideoDynamicEffectModel *model, BOOL result) {
            __strong typeof(self) strongself = weakself;
            [strongself endLoading];
        }];
    } else {
        self.selected = YES;
        self.tapCallBack ? self.tapCallBack(self) : nil;
    }
}

@end
