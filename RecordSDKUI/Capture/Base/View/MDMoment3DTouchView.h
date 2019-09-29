//
//  MDMoment3DTouchView.h
//  MDChat
//
//  Created by sdk on 17/03/2018.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^MD3DTouchLevelHandle)(void);

@interface MDMoment3DTouchView : UIView

@property (strong) MD3DTouchLevelHandle touchLevelHandle;

@property (assign) BOOL acceptTouct;

@end
