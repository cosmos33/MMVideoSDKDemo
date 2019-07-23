//
//  MDRecordVideoEditSettingViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordVideoEditSettingViewController.h"
#import "MDRecordVideoSettingManager.h"

#import "MDRecordMacro.h"
#import "MDCameraContainerViewController.h"
#import "MDRecordVideoResult.h"
#import "MDNavigationController.h"
#import "UINavigationController+AnimatedTransition.h"
#import "MDRecordImageResult.h"
#import "MDPhotoLibraryProvider.h"

@interface MDRecordVideoEditSettingViewController () <MDNavigationBarAppearanceDelegate>

@end

@implementation MDRecordVideoEditSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    
    self.view.backgroundColor = UIColor.blackColor;
    
    MDRecordVideoSettingManager.exportBitRate = 0;
    MDRecordVideoSettingManager.exportFrameRate = 0;
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    visualEffectView.frame = self.view.bounds;
    [self.view addSubview:visualEffectView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [visualEffectView.contentView addGestureRecognizer:tapGesture];
    
    UIButton *closeButton = [self createCloseButton];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:closeButton];
    
    UILabel *headerLabel = [self titleLabelWithTitle:@"编辑设置"];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:headerLabel];
    
    UIView *view1 = [self itemWithTitle:@"帧率" placeholder:@"默认为30,建议范围15-30" textFiedlTag:1000];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:view1];
    
    UIView *view2 = [self itemWithTitle:@"码率(M)" placeholder:@"默认为0,根据视频清晰度自动计算, 单位为M, 建议1-7" textFiedlTag:1001];
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:view2];
    
    UIButton *completeButton = [self createSelectItemButtonWithTitle:@"导入编辑" tag:10010];
    completeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:completeButton];
    
    [closeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:24].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:32].active = YES;
    [closeButton.heightAnchor constraintEqualToAnchor:closeButton.widthAnchor].active = YES;
    
    if (@available(iOS 11.0, *)) {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30].active = YES;
    } else {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;
    }
    
    [headerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [headerLabel.centerYAnchor constraintEqualToAnchor:closeButton.centerYAnchor].active = YES;
    
    [view1.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [view1.topAnchor constraintEqualToAnchor:headerLabel.bottomAnchor constant:25].active = YES;
    [view1.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [view1.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view2.leftAnchor constraintEqualToAnchor:view1.leftAnchor].active = YES;
    [view2.topAnchor constraintEqualToAnchor:view1.bottomAnchor constant:20].active = YES;
    [view2.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [view2.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [completeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [completeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [completeButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [completeButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-60].active = YES;
}

- (UIButton *)createCloseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"btn_moment_music_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)createSelectItemButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setBackgroundColor:[[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2]];
    button.tag = tag;
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)titleLabelWithTitle:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = UIColor.whiteColor;
    label.text = text;
    return label;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag {
    UITextField *textField = [[UITextField alloc] init];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                      attributes:@{
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                   NSForegroundColorAttributeName : UIColor.whiteColor
                                                                                   }];
    textField.textColor = UIColor.whiteColor;
    textField.font = [UIFont systemFontOfSize:15];
    textField.tag = tag;
    textField.backgroundColor = [UIColor grayColor];
    textField.backgroundColor = [[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2];
    [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    return textField;
}

- (UIView *)itemWithTitle:(NSString *)title placeholder:(NSString *)placeholder textFiedlTag:(NSInteger)tag {
    
    UILabel *titleLabel = [self titleLabelWithTitle:title];
    [titleLabel sizeToFit];
    
    UITextField *textField = [self textFieldWithPlaceholder:placeholder tag:tag];
    textField.keyboardType = UIKeyboardTypePhonePad;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, textField]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 8;
    
    [textField.leftAnchor constraintEqualToAnchor:stackView.leftAnchor].active = YES;
    [textField.rightAnchor constraintEqualToAnchor:stackView.rightAnchor].active = YES;
    [textField.heightAnchor constraintEqualToConstant:40].active = YES;
    textField.layer.cornerRadius = 5;
    
    return stackView;
}

- (void)closeButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldValueChanged:(UITextField *)textField {
    switch (textField.tag) {
        case 1000:
            MDRecordVideoSettingManager.exportFrameRate = [textField.text intValue];
            break;
            
        case 1001:
            MDRecordVideoSettingManager.exportBitRate = [textField.text floatValue] * 1024 * 1024;
            break;
            
        default:
            break;
    }
}

- (void)buttonTapped:(UIButton *)button {
    [self gotoRecord:MDUnifiedRecordLevelTypeAsset];
}

- (void)gotoRecord:(MDUnifiedRecordLevelType)levelType {
    if (![MDCameraContainerViewController checkDevicePermission]) {
        return;
    }
    
    MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
    __weak typeof(containerVC) weakContainerVC = containerVC;
    
    MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
    //    settingItem.recordLog.enterenceType = (levelType == MDUnifiedRecordLevelTypeAsset ? MDUnifiedRecordEnterenceTypeAlbum : MDUnifiedRecordEnterenceTypeRecord);
    settingItem.levelType = levelType;
    settingItem.completeHandler = ^(id result) {
        
        if ([result isKindOfClass:[MDRecordVideoResult class]]) {
            
        } else if ([result isKindOfClass:[MDRecordImageResult class]]) {
        }
        
        [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    containerVC.recordSetting = settingItem;
    
    MDNavigationController *nav = [MDNavigationController md_NavigationControllerWithRootViewController:containerVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tapped:(UIGestureRecognizer *)tapGesture {
    UITextField *field1 = [self.view viewWithTag:1000];
    [field1 resignFirstResponder];
    UITextField *field2 = [self.view viewWithTag:1001];
    [field2 resignFirstResponder];
}

- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

- (BOOL)md_isCurrentCustomed {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
