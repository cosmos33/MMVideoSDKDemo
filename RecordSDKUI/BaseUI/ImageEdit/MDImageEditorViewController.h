//
//  MDImageEditorViewController.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/12.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

//#import "MDVideoRecordDefine.h"
#import "MDViewController.h"

@class MDImageUploadParamModel;

typedef void(^MDImageEditorCompleteBlock)(UIImage *image, BOOL isEdited);
typedef void (^MDImageEditorCancelBlock)(BOOL isEdit);
typedef void (^MDQualityResultCancelBLock)(void);

@interface MDImageEditorViewController : MDViewController

- (instancetype)initWithImage:(UIImage *)originImage completeBlock:(MDImageEditorCompleteBlock)completeBlock;

@property (nonatomic, assign) BOOL                      useFastInit;

//右边按钮文案
@property (nonatomic, copy) NSString                    *doneButtonTitle;

@property (nonatomic, copy) MDImageEditorCancelBlock    cancelBlock;
@property (nonatomic, copy) MDQualityResultCancelBLock    qualityCancelBlock;

@property (nonatomic, strong) MDImageUploadParamModel   *imageUploadParamModel;



@end
