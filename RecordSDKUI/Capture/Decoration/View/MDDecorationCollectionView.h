//
//  MDDecorationCollectionView.h
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MDFaceDecorationItem;

@interface MDDecorationCollectionView : UIView

@property (nonatomic, copy) void (^ __nullable scrollEndHandler)(NSInteger index);
@property (nonatomic, copy) void (^ __nullable selectedHandler)(NSInteger section, NSInteger index, MDFaceDecorationItem *item);

- (void)configDrawerDataArray:(NSArray<NSArray<MDFaceDecorationItem*> *> *)drawerDataArray needLayout:(BOOL)needLayout;
- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
