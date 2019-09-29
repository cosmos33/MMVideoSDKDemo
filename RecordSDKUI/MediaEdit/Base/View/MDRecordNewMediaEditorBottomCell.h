//
//  MDRecordNewMediaEditorBottomCell.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MDRecordNewMediaEditorBottomCell : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *contentImage;

@property (nonatomic, copy) void(^tapCallBack)(MDRecordNewMediaEditorBottomCell *);

@end

NS_ASSUME_NONNULL_END
