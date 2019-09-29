//
//  MDRecordNewMediaEditorBottomView.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRecordNewMediaEditorBottomView;

NS_ASSUME_NONNULL_BEGIN

@protocol MDRecordNewMediaEditorBottomViewDelegate <NSObject>

- (void)buttonClicked:(MDRecordNewMediaEditorBottomView *)view title:(NSString *)title;

@end

@interface MDRecordNewMediaEditorBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles imageNames:(NSArray<NSString *> *)imageNames;

@property (nonatomic, weak) id<MDRecordNewMediaEditorBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
