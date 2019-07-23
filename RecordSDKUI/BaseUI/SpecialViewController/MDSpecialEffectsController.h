//
//  MDSpecialEffectsController.h
//  MDChat
//
//  Created by YZK on 2018/8/3.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RecordSDK/MDRecordPlayerViewController.h>

@class MDDocumentRenderer,MDPlayerViewController,MDDocument;

@protocol MDSpecialEffectsControllerDelegate <NSObject>

- (void)specialEffectsDidChange;
- (void)specialEffectsDidFinishedEditing;

@end


@interface MDSpecialEffectsController : UIViewController

- (instancetype)initWithDocument:(MDDocument *)document
            playerViewController:(MDRecordPlayerViewController *)playerViewController
                        delegate:(id<MDSpecialEffectsControllerDelegate>)delegate;

@property (nonatomic, strong  ) NSArray *specialImageArray;
- (void)updateSpecialImageArray:(NSArray *)imageArray;

@property (nonatomic, readonly) BOOL isShow;
- (void)showWithAnimated:(BOOL)animated;
- (void)seekPlayTime:(CMTime)time;
@end
