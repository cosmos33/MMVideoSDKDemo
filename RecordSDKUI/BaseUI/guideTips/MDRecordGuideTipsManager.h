//
//  MDRecordGuideTipsManager.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordHeader.h"

typedef NS_ENUM(NSUInteger, MDRecordGuideTipsType) {
    MDRecordGuideTipsTypeNormalCapture,
    MDRecordGuideTipsTypeHighCapture,
    MDRecordGuideTipsTypeVideoEdit,
    MDRecordGuideTipsTypeImageEdit
};

@protocol MDRecordGuideTipsManagerDelegate <NSObject>

@required
- (void)anchorPoint:(CGPoint *)point
       anchorOffSet:(CGFloat *)anchorOffSet
         anchorType:(NSInteger *)anchorType
      withIdentifer:(NSString *)identifier;

@optional
- (BOOL)shouldShowLocalGuideWithIdentifier:(NSString *)identifier;

@end

@interface MDRecordGuideTipsManager : NSObject

@property (nonatomic,weak) id<MDRecordGuideTipsManagerDelegate> delegate;

- (void)doGuideAnimationWithTipsType:(MDRecordGuideTipsType)tipsType andContainerView:(UIView *)containerView;

- (BOOL)canShowRedPointWithIdentifier:(NSString *)identifier;
- (void)redPointDidShowWithIdentifier:(NSString *)identifier;


@end

