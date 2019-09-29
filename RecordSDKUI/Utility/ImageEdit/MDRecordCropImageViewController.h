//
//  MDRecordCropImageViewController.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/30.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MDRecordCropImageViewController;

@protocol MDRecordCropImageViewControllerDelegate <NSObject>

- (void)cropImageViewController:(MDRecordCropImageViewController *)vc resizedImage:(UIImage *)resizedImage;
- (void)cropImageViewControllerCancelCrop:(MDRecordCropImageViewController *)vc;

@end

@interface MDRecordCropImageViewController : MDViewController

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, weak) id<MDRecordCropImageViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
