//
//  MDImageClipAndScaleViewController.h
//  MDChat
//
//  Created by Aaron on 14/11/7.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import "MDViewController.h"

@class MDImageClipAndScaleViewController;

@protocol MDImageClipAndScaleViewControllerDelegate <NSObject>

-(void)clipControllerDidCancel:(MDImageClipAndScaleViewController *)controller;
-(void)clipController:(MDImageClipAndScaleViewController *)controller didClipImage:(UIImage *)image;

@end



@interface MDImageClipAndScaleViewController : MDViewController

@property (nonatomic, weak) id<MDImageClipAndScaleViewControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat   imageClipScale;

-(instancetype)initWithImage:(UIImage *)aImage;


@end
