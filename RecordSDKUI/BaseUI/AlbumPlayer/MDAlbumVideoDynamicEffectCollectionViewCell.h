//
//  MDAlbumVideoDynamicEffectCollectionViewCell.h
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

@import UIKit;
#import "MDAlbumVideoDynamicEffectModel.h"

NS_ASSUME_NONNULL_BEGIN

// 作为collectionView，防止以后动效增加需要放入collectionview中
@interface MDAlbumVideoDynamicEffectCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MDAlbumVideoDynamicEffectModel *cellModel;

@property (nonatomic, copy) void(^tapCallBack)(MDAlbumVideoDynamicEffectCollectionViewCell *cell);

- (void)tapAction:(UITapGestureRecognizer * _Nullable)tap;

@end

NS_ASSUME_NONNULL_END
