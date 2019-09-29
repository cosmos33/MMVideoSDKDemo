//
//  MDNewMakeupView.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/26.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordNewMakeupView.h"

@interface MDRecordMakeupViewCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *blackView;

@end

@implementation MDRecordMakeupViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    

    UIView *blackView = [[UIView alloc] init];
    blackView.translatesAutoresizingMaskIntoConstraints = NO;
    blackView.backgroundColor = UIColor.blackColor;
    blackView.layer.borderWidth = 3;
    blackView.layer.borderColor = UIColor.clearColor.CGColor;
    blackView.layer.cornerRadius = 30;
    blackView.clipsToBounds = YES;
    [self.contentView addSubview:blackView];
    self.blackView = blackView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeCenter;
    [blackView addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    [blackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [blackView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor].active = YES;
    [blackView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor].active = YES;
    [blackView.widthAnchor constraintEqualToAnchor:blackView.heightAnchor].active = YES;
    
    [imageView.centerXAnchor constraintEqualToAnchor:blackView.centerXAnchor].active = YES;
    [imageView.centerYAnchor constraintEqualToAnchor:blackView.centerYAnchor].active = YES;
    [imageView.widthAnchor constraintEqualToAnchor:blackView.widthAnchor].active = YES;
    [imageView.heightAnchor constraintEqualToAnchor:imageView.heightAnchor].active = YES;
    
    [titleLabel.topAnchor constraintEqualToAnchor:blackView.bottomAnchor constant:5].active = YES;
    [titleLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor].active = YES;
    [titleLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor].active= YES;
    [titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    if (selected) {
        self.blackView.layer.borderColor = [[UIColor alloc] initWithRed:0 green:192.0 / 255.0 blue:1.0 alpha:1.0].CGColor;
    } else {
        self.blackView.layer.borderColor = UIColor.clearColor.CGColor;
    }
}

@end

@interface MDRecordNewMakeupView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation MDRecordNewMakeupView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = UIColor.whiteColor;
    label.text = @"美妆";
    label.font = [UIFont systemFontOfSize:14];
    [self addSubview:label];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 12;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60, 80);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 28, 0, 28);
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.clipsToBounds = YES;
    collectionView.backgroundColor = UIColor.clearColor;
    [self addSubview:collectionView];
    self.collectionView = collectionView;

    [collectionView registerClass:[MDRecordMakeupViewCell class] forCellWithReuseIdentifier:@"makeup.cell"];
    
    [label.topAnchor constraintEqualToAnchor:self.topAnchor constant:20].active = YES;
    [label.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:28].active = YES;
    
    [collectionView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [collectionView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [collectionView.heightAnchor constraintEqualToConstant:80].active = YES;
    [collectionView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

- (void)setItems:(NSArray<MDMomentMakeupItem *> *)items {
    _items = items.copy;
    [self.collectionView reloadData];
}

#pragma mark - collectionView delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    
    if (indexPath.item == 0) {
        [self.delegate didClearWithMakeupView:self];
    } else {
        [self.delegate makeupView:self item:self.items[indexPath.item]];
    }
}

#pragma mark - collectionView datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDRecordMakeupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"makeup.cell" forIndexPath:indexPath];

    MDMomentMakeupItem *item = self.items[indexPath.item];
    cell.titleLabel.text = item.title;
    cell.imageView.image = item.icon;
    
    return cell;
}

@end
