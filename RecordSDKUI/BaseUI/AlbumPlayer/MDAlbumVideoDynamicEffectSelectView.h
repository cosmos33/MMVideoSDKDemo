//
//  MDAlbumVideoDynamicEffectSelectView.h
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDAlbumVideoDynamicEffectModel.h"

@interface MDAlbumVideoDynamicEffectSelectView : UIView

@property (nonatomic, strong) NSArray<MDAlbumVideoDynamicEffectModel *> *models;
@property (nonatomic, copy) void(^tapCell)(MDAlbumVideoDynamicEffectSelectView *view, MDAlbumVideoDynamicEffectModel *model);
@property (nonatomic, copy) NSString *currentAnimationType;

- (void)selectedAnimationType:(NSString *)animationType;

@end
