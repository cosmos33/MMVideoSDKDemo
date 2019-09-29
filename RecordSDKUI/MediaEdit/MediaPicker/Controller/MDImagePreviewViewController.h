//
//  MDImagePreviewViewController.h
//  MDChat
//
//  Created by Aaron on 14/11/7.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import "MDViewController.h"


@class MDImagePreviewViewController;

@protocol MDImagePreviewViewControllerDelegate <NSObject>

-(void)previewControllerDidCancel:(MDImagePreviewViewController *)controller;
-(void)previewController:(MDImagePreviewViewController *)controller willEditImage:(UIImage *)image;
-(void)previewController:(MDImagePreviewViewController *)controller willDeleteImage:(UIImage *)image;

@end


@interface MDImagePreviewViewController : MDViewController<UIActionSheetDelegate>

@property (nonatomic, assign) id <MDImagePreviewViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger index;

-(instancetype)initWithImage:(UIImage *)aImage;

-(instancetype)initWithImage:(UIImage *)aImage withAnimation:(BOOL)flag;

@end
