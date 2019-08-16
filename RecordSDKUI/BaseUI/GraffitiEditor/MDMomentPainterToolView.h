//
//  MDMomentPainterToolView.h
//  MDChat
//
//  Created by wangxuan on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordEditProtocol.h"


@interface MDMomentPainterToolView : UIView

@property (nonatomic, weak) id<MDMomentPainterToolViewDelegate> delegate;

-(void)showAnimation;

- (void)setMosaicBrushButtonHidden:(BOOL)isHidden;

@end
