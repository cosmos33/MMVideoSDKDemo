//
//  MDMomentTextOverlayEditorView.h
//  MDChat
//
//  Created by wangxuan on 17/2/10.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDMomentTextOverlayEditorView : UIView

@property (nonatomic, copy)     NSString *text;
@property (nonatomic, strong)   NSString *placeholder;

@property (nonatomic) BOOL      editable;
@property (nonatomic, readonly) BOOL visible;

//call back
@property (nonatomic,copy) void (^beginEditingHandler)(void);
@property (nonatomic,copy) void (^endEditingHandler)(UILabel *label, NSInteger colorIndex);

- (void)show;

- (void)active; //show -> editable -> becomefirstresponder

- (void)hide;

- (void)resignTextView;

- (void)configSelectedColor:(NSInteger)index;

@end
