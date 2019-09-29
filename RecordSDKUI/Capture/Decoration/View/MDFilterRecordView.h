//
//  MDFilterRecordView.h
//  MomoChat
//
//  Created by YZK on 2019/4/19.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDFilterRecordView : UIView

- (void)setRecordLevelType:(MDUnifiedRecordLevelType)levelType;
- (void)beginAniamtion;
- (void)endAnimation;

@end

NS_ASSUME_NONNULL_END
