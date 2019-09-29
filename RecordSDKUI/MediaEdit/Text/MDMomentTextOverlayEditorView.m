//
//  MDMomentTextOverlayEditorView.m
//  MDChat
//
//  Created by wangxuan on 17/2/10.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentTextOverlayEditorView.h"
#import "MDMediaEditTextColorSelectView.h"
#import "MDRecordHeader.h"
#import "MDRecordContext.h"
#import "MDRecordMacro.h"
#import "Toast/Toast.h"

static CGFloat minFontSize = 13;
static CGFloat maxFontSize = 29;
static CGFloat colorViewWidth = 30;

@interface MDMomentTextOverlayEditorView () <UITextViewDelegate>

@property (nonatomic, weak) UITextView  *textView;
@property (nonatomic, weak) UIView      *contentView;
@property (nonatomic, weak) UIView      *decorationView;
@property (nonatomic, weak) UILabel     *placeHolderLabel;
@property (nonatomic, strong) MDMediaEditTextColorSelectView    *colorView;

@property (nonatomic) BOOL hasKeyboardViewFrame;
@property (nonatomic) CGRect keyboardViewFrameToView;

@property (nonatomic) BOOL visible;

@property (nonatomic) BOOL handlingGesture;

//@property (nonatomic,weak) UIPanGestureRecognizer *panGestureRecognizer;
//@property (nonatomic) CGFloat contentViewVerticalLocationBeforeEditing;

@property (nonatomic) CGFloat contentViewVerticalLocation;

@end


@implementation MDMomentTextOverlayEditorView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (![super pointInside:point withEvent:event]) return NO;
    
    __block BOOL subviewContainsPoint = NO;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        CGPoint pointToSubview = [self convertPoint:point toView:subview];
        if([subview pointInside:pointToSubview withEvent:event] && [subview hitTest:pointToSubview withEvent:event]) {
            subviewContainsPoint = YES;
            *stop = YES;
        }
    }];
    
    BOOL hitKeyboard = CGRectContainsPoint(self.keyboardViewFrameToView, point);
    if (subviewContainsPoint || hitKeyboard) {
        return YES;
    } else {
        [self.textView resignFirstResponder];
        return NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize textViewSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.textView.frame), CGFLOAT_MAX)];
    if (textViewSize.height > CGRectGetHeight(self.contentView.bounds)) {
        textViewSize.height = CGRectGetHeight(self.contentView.bounds);
    }
    self.textView.frame = CGRectMake(0, (CGRectGetHeight(self.contentView.bounds) - textViewSize.height)/2.0, CGRectGetWidth(self.textView.frame), textViewSize.height);

    self.colorView.top = CGRectGetMinY(self.keyboardViewFrameToView) - 40;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupTextEditorView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTextEditorView {
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, MDScreenHeight *0.3f, CGRectGetWidth(self.bounds), 60)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.contentView.bounds];
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.textContainer.lineFragmentPadding = 0;
    textView.font = [UIFont boldSystemFontOfSize:maxFontSize];
    textView.textColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor clearColor];
    
    textView.layer.shadowColor = [RGBACOLOR(0, 0, 0, 0.4) CGColor];
    textView.layer.shadowOpacity = 0.5;
    textView.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    
    textView.delegate = self;
    textView.scrollEnabled = NO;
    textView.returnKeyType = UIReturnKeyDone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:textView];
    self.textView = textView;
    
    UILabel *placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height)];
    placeHolderLabel.font = [UIFont systemFontOfSize:maxFontSize];
    placeHolderLabel.textColor = [UIColor whiteColor];
    placeHolderLabel.layer.shadowColor = [RGBACOLOR(0, 0, 0, 0.4) CGColor];
    placeHolderLabel.layer.shadowOpacity = 0.5;
    placeHolderLabel.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    placeHolderLabel.textAlignment = NSTextAlignmentCenter;
    placeHolderLabel.text = self.placeholder;
    [self.contentView addSubview:placeHolderLabel];
    self.placeHolderLabel = placeHolderLabel;
    
    UIImage *image = [UIImage imageNamed:@"media_editor_compelete"];
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth - 15-image.size.width, 15 + HOME_INDICATOR_HEIGHT, image.size.width, image.size.height)];
    [doneButton setImage:image forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneButton];

    [self addColorSelectView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.alpha = 0;
    self.visible = NO;
    self.editable = NO;
}

#pragma mark - color select about
- (void)addColorSelectView
{
    MDMediaEditTextColorSelectView *colorView = [[MDMediaEditTextColorSelectView alloc] initWithFrame:CGRectMake(0, MDScreenHeight *0.3f, MDScreenWidth, colorViewWidth)];
    [self addSubview:colorView];
    
    __weak typeof(self) weakSelf = self;
    [colorView setColorSelectHandler:^(UIColor *color) {
        weakSelf.textView.textColor = color;
    }];
    self.colorView = colorView;
}

#pragma mark - keyboard

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    self.hasKeyboardViewFrame = YES;
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardViewFrameToView = [[UIApplication sharedApplication].keyWindow convertRect:frame toView:self];
    self.keyboardViewFrameToView = keyboardViewFrameToView;
    [self setNeedsLayout];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

    [self checkNeedShowPlaceHolder];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (!textView.markedTextRange) {
        //2 stage input complete
        NSString *text = textView.text;
        if (text.length) {
            BOOL(^textViewEndOfDocumentVisible)(void) = ^(void) {
                return (BOOL)CGRectContainsRect(textView.bounds, [textView caretRectForPosition:textView.endOfDocument]);
            };
            
            if (!textViewEndOfDocumentVisible()) {
                BOOL canFit = NO;
                while (textView.font.pointSize > minFontSize) {
                    textView.font = [textView.font fontWithSize:textView.font.pointSize - 1];
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                    if (textViewEndOfDocumentVisible()) {
                        canFit = YES;
                        break;
                    }
                }
                
                if (!canFit) {
                    [[UIApplication sharedApplication].delegate.window makeToast:@"最多输入两行文字" duration:1.5f position:CSToastPositionCenter];
                    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                                             options:NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse
                                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                              UITextRange *selectedTextRange = textView.selectedTextRange;
                                              textView.text = [text substringToIndex:substringRange.location];
                                              textView.selectedTextRange = selectedTextRange;
                                              [self setNeedsLayout];
                                              [self layoutIfNeeded];
                                              if (textViewEndOfDocumentVisible()) {
                                                  *stop = YES;
                                              }
                                          }];
                }
            } else {
                while (textView.font.pointSize < maxFontSize) {
                    textView.font = [textView.font fontWithSize:textView.font.pointSize + 1];
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                    if (!textViewEndOfDocumentVisible()) {
                        textView.font = [textView.font fontWithSize:textView.font.pointSize - 1];
                        [self setNeedsLayout];
                        [self layoutIfNeeded];
                        break;
                    }
                }
            }
        }
    }
}

- (void)checkNeedShowPlaceHolder
{
    if (self.textView.text.length == 0) {
        self.placeHolderLabel.text = self.placeholder;
    } else {
        self.placeHolderLabel.text = @"";
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self textViewWillBeginEditing:textView];
    return YES;
}

- (void)textViewWillBeginEditing:(UITextView *)textView {
//    if (self.visible) {
//        self.contentViewVerticalLocationBeforeEditing = self.contentViewVerticalLocation;
//    } else {
//        self.contentViewVerticalLocationBeforeEditing = -1;
//    }
    
    [self checkNeedShowPlaceHolder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    self.panGestureRecognizer.enabled = NO;
    [self setNeedsLayout];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
    
    if (self.beginEditingHandler) {
        self.beginEditingHandler();
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self hide];
    [self handleEndEditing];
}

- (void)handleEndEditing
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = self.textView.textColor;
    label.font = self.textView.font;
    label.text = self.textView.text;
    label.numberOfLines = 0;
    CGSize size = [label sizeThatFits:self.textView.textContainer.size];
    label.size = size;
    
    if (self.endEditingHandler) {
        self.endEditingHandler(label, self.colorView.colorIndex);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.length == 0 && [text isEqualToString:@"\n"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView resignFirstResponder];
        });
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 
- (NSString *)text {
    return self.textView.text;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
    [self textViewDidChange:self.textView];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _placeHolderLabel.text = placeholder;
}

- (BOOL)editable {
    return self.textView.userInteractionEnabled;
}

- (void)setEditable:(BOOL)editable {
    self.textView.userInteractionEnabled = editable;
}

- (void)hide {
    self.visible = NO;
    [self resignTextView];
    
//    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
//    }];
}

- (void)show {
    if (!self.visible) {
        self.visible = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
        [self.colorView showPainterAnimation];
        [self.colorView configSelectedColor:0];
    }
}

- (void)configSelectedColor:(NSInteger)index
{
    [self.colorView configSelectedColor:index];
}

- (void)active {
    self.editable = YES;
    [self.textView becomeFirstResponder];
    [self show];
}

- (void)resignTextView
{
    if ([self.textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
}

- (void)doneButtonTapped:(UIButton *)button
{
    [self resignTextView];
}

@end
