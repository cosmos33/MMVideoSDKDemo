//
//  MDPreviewPageViewController.h
//  MDChat
//
//  Created by Aaron on 14/12/2.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDViewController.h"

@class MDPreviewPageViewController;

@protocol MDPreviewPageViewControllerDelegate <NSObject>

-(void)previewPageViewControllerDidCancel:(MDPreviewPageViewController *)controller;

-(void)previewPageViewController:(MDPreviewPageViewController *)controller didDoneWithImage:(UIImage *)image;

-(void)previewPageViewController:(MDPreviewPageViewController *)controller willEditImage:(UIImage *)image;

-(void)previewPageViewController:(MDPreviewPageViewController *)controller willDeleteImageAtIndex:(NSInteger)index willPop:(BOOL)willPop;

-(void)previewPageViewController:(MDPreviewPageViewController *)controller didScrollToPage:(NSInteger) index;


@end


@interface MDPreviewPageViewController : MDViewController<UIPageViewControllerDataSource, UIActionSheetDelegate>
@property (nonatomic, weak) id<MDPreviewPageViewControllerDelegate>delegate;
@property (nonatomic, assign) BOOL      enableDelete;

-(instancetype)initWithImageArray:(NSArray *)imageArray andSelectedIndex:(NSInteger)selectedIndex;
-(instancetype)initWithImageArray:(NSArray *)imageArray andSelectedIndex:(NSInteger)selectedIndex withDeleteEnable:(BOOL)enableDelete;
-(instancetype)initWithImageArray:(NSArray *)imageArray andFunctionDisable:(BOOL)flag;


@end
