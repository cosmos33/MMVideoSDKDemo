//
//  MDRecordStickersEditView.h
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordEditProtocol.h"
#import "MDRecordEditContainerPanelView.h"

NS_ASSUME_NONNULL_BEGIN


@interface MDRecordEditStickersView : UIView

@property (nonatomic, weak) id<MDRecordStickersEditViewDelegate> delegate;

+ (MDRecordEditStickersView *)imageEditStickersView;

- (instancetype)initWithFrame:(CGRect)frame isDynamicDecoratorMode:(BOOL)isDynamicDecoratorMode;

@property (nonatomic, strong) UICollectionView *collectionView;

- (void)requestIfNeed;

@end

NS_ASSUME_NONNULL_END
