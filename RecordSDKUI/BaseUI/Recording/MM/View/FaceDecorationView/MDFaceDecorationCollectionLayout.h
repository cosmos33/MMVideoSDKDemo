//
//  MDFaceDecorationCollectionLayout.h
//  MDChat
//
//  Created by YZK on 2017/7/25.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDFaceDecorationCollectionLayout : UICollectionViewFlowLayout

/** 有效距离:当item的中间x距离屏幕的中间x在ActiveDistance以内,才会开始放大 */
@property (nonatomic, assign) CGFloat activeDistance;
/** 缩放因素: 值越大, item就会越大, 0表示不放大 */
@property (nonatomic, assign) CGFloat scaleFactor;
/** 增大间距: 值多大，中间item间距两测item的间距增大多少 */
@property (nonatomic, assign) CGFloat translationDistance;

@end
