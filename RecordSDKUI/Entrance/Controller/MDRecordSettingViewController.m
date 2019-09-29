//
//  MDRecordSettingViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordSettingViewController.h"
#import "MDRecordRecordingSettingMananger.h"
#import "MDRecordMacro.h"
#import "MDCameraContainerViewController.h"
#import "MDRecordVideoResult.h"
#import "MDNavigationController.h"
#import "UINavigationController+AnimatedTransition.h"
#import "MDRecordImageResult.h"
#import "MDFaceDecorationLoader.h"

@interface MDRecordSettingViewController () <MDNavigationBarAppearanceDelegate>

@property (nonatomic, strong) MDFaceDecorationLoader *loader;

@end

@implementation MDRecordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.loader = [[MDFaceDecorationLoader alloc] init];
}

- (void)setupUI {
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.view.backgroundColor = UIColor.blackColor;
    
    MDRecordRecordingSettingMananger.bitRate = 0;
    MDRecordRecordingSettingMananger.frameRate = 0;
    MDRecordRecordingSettingMananger.resolution = RecordingResolution1280x720;
    MDRecordRecordingSettingMananger.ratio = RecordScreenRatioFullScreen;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UIView *contentGuide = [[UIView alloc] initWithFrame:CGRectZero];
    contentGuide.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentGuide];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [scrollView addGestureRecognizer:tapGesture];
    
    UIButton *closeButton = [self createCloseButton];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:closeButton];

    UILabel *headerLabel = [self titleLabelWithTitle:@"拍摄设置"];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerLabel];
    
    UIView *view1 = [self itemWithTitle:@"帧率" placeholder:@"默认为30,建议范围15-30" textFiedlTag:1000];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    [contentGuide addSubview:view1];
    
    UIView *view2 = [self itemWithTitle:@"码率(M)" placeholder:@"默认为0,根据视频清晰度自动计算, 单位为M, 建议1-7" textFiedlTag:1001];
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    [contentGuide addSubview:view2];
    
    UIView *view3 = [self itemWithTitle:@"屏幕比" buttonTitles:@[@"全屏", @"9:16", @"3:4", @"1:1"] selectIndex:0 tag:10000];
    view3.translatesAutoresizingMaskIntoConstraints = NO;
    [contentGuide addSubview:view3];
    
    UIView *view4 = [self itemWithTitle:@"清晰度" buttonTitles:@[@"480p", @"540p", @"720p", @"1080p"] selectIndex:2 tag:10001];
    view4.translatesAutoresizingMaskIntoConstraints = NO;
    [contentGuide addSubview:view4];
    
    UIView *view5 = [self itemWithTitle:@"曝光补偿"
                           Placeholder1:@"上浮动值(0 - 3)"
                                   tag1:1002
                           placeholder2:@"下浮动值(-3 - 0)"
                                   tag2:1003];
    
    view5.translatesAutoresizingMaskIntoConstraints = NO;
    [contentGuide addSubview:view5];
    
    UIButton *recordButton = [self createSelectItemButtonWithTitle:@"开始录制" tag:10010];
    recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:recordButton];
    
    [closeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:24].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:32].active = YES;
    [closeButton.heightAnchor constraintEqualToAnchor:closeButton.widthAnchor].active = YES;
    
    [scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [scrollView.topAnchor constraintEqualToAnchor:headerLabel.bottomAnchor constant:25].active = YES;
    [scrollView.bottomAnchor constraintEqualToAnchor:recordButton.topAnchor constant:-8].active = YES;

    [contentGuide.leftAnchor constraintEqualToAnchor:scrollView.leftAnchor].active = YES;
    [contentGuide.rightAnchor constraintEqualToAnchor:scrollView.rightAnchor].active = YES;
    [contentGuide.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
    [contentGuide.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor].active = YES;
    [contentGuide.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor].active = YES;
    [contentGuide.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;

    if (@available(iOS 11.0, *)) {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30].active = YES;
    } else {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;
    }
    
    [headerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [headerLabel.centerYAnchor constraintEqualToAnchor:closeButton.centerYAnchor].active = YES;
    [headerLabel.heightAnchor constraintEqualToConstant:40].active = YES;
    
    [view1.leftAnchor constraintEqualToAnchor:contentGuide.leftAnchor constant:20].active = YES;
    [view1.topAnchor constraintEqualToAnchor:contentGuide.topAnchor].active = YES;
    [view1.centerXAnchor constraintEqualToAnchor:contentGuide.centerXAnchor].active = YES;
    [view1.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view2.leftAnchor constraintEqualToAnchor:view1.leftAnchor].active = YES;
    [view2.topAnchor constraintEqualToAnchor:view1.bottomAnchor constant:20].active = YES;
    [view2.centerXAnchor constraintEqualToAnchor:contentGuide.centerXAnchor].active = YES;
    [view2.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view3.leftAnchor constraintEqualToAnchor:view2.leftAnchor].active = YES;
    [view3.topAnchor constraintEqualToAnchor:view2.bottomAnchor constant:20].active = YES;
    [view3.centerXAnchor constraintEqualToAnchor:contentGuide.centerXAnchor].active = YES;
    [view3.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view4.leftAnchor constraintEqualToAnchor:view3.leftAnchor].active = YES;
    [view4.topAnchor constraintEqualToAnchor:view3.bottomAnchor constant:20].active = YES;
    [view4.centerXAnchor constraintEqualToAnchor:contentGuide.centerXAnchor].active = YES;
    [view4.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view5.leftAnchor constraintEqualToAnchor:view4.leftAnchor].active = YES;
    [view5.topAnchor constraintEqualToAnchor:view4.bottomAnchor constant:20].active = YES;
    [view5.centerXAnchor constraintEqualToAnchor:contentGuide.centerXAnchor].active = YES;
    [view5.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [recordButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [recordButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [recordButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-60].active = YES;
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
    textField.layer.cornerRadius = 5;
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

    return stackView;
}

- (UIView *)buttonsForTitles:(NSArray<NSString *> *)titles
                 selectIndex:(NSInteger)selectIndex
                         tag:(NSInteger)tag {
    
//    NSMutableArray *buttonArray = [NSMutableArray array];
//    for (int i = 0; i < titles.count; i ++) {
//        UIButton *button = [self createSelectItemButtonWithTitle:titles[i] tag:begin + i];
//        button.translatesAutoresizingMaskIntoConstraints = NO;
//        [buttonArray addObject:button];
//    }
//
//    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:[buttonArray copy]];
//    stackView.axis = UILayoutConstraintAxisHorizontal;
//    stackView.alignment = UIStackViewAlignmentCenter;
//    stackView.distribution = UIStackViewDistributionFillEqually;
//    stackView.spacing = 1;
//
//    for (UIButton *button in buttonArray) {
////        [button.widthAnchor constraintEqualToConstant:80].active = YES;
//        [button.heightAnchor constraintEqualToConstant:40].active = YES;
//    }
//
//    return stackView;
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:titles];
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [control setTintColor:[[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2]];
    [control setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.whiteColor }
                           forState:UIControlStateNormal];
    [control.heightAnchor constraintEqualToConstant:40].active = YES;
    control.backgroundColor = [[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2];
    control.selectedSegmentIndex = selectIndex;
    control.tag = tag;
    [control addTarget:self action:@selector(segmentControlTapped:) forControlEvents:UIControlEventValueChanged];
    return control;
}

- (UIView *)itemWithTitle:(NSString *)title buttonTitles:(NSArray<NSString *> *)titles selectIndex:(NSInteger)selectIndex tag:(NSInteger)tag {
    
    UILabel *titleLabel = [self titleLabelWithTitle:title];
    [titleLabel sizeToFit];
    
    UIView *buttonView = [self buttonsForTitles:titles selectIndex:selectIndex tag:tag];
    buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, buttonView]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 8;
    
    [buttonView.leftAnchor constraintEqualToAnchor:stackView.leftAnchor].active = YES;
    [buttonView.rightAnchor constraintEqualToAnchor:stackView.rightAnchor].active = YES;
    
    return stackView;
}

- (UIView *)itemWithTitle:(NSString *)title Placeholder1:(NSString *)placeHolder1 tag1:(NSInteger)tag1 placeholder2:(NSString *)placeHolder2 tag2:(NSInteger)tag2 {
    
    UILabel *titleLabel = [self titleLabelWithTitle:title];
    [titleLabel sizeToFit];
    
    UITextField *textFiled1 = [self textFieldWithPlaceholder:placeHolder1 tag:tag1];
    textFiled1.translatesAutoresizingMaskIntoConstraints = NO;
    UITextField *textFiled2 = [self textFieldWithPlaceholder:placeHolder2 tag:tag2];
    textFiled2.translatesAutoresizingMaskIntoConstraints = NO;
 
    UIStackView *hStackView = [[UIStackView alloc] initWithArrangedSubviews:@[textFiled1, textFiled2]];
    hStackView.translatesAutoresizingMaskIntoConstraints = NO;
    hStackView.axis = UILayoutConstraintAxisHorizontal;
    hStackView.alignment = UIStackViewAlignmentCenter;
    hStackView.distribution = UIStackViewDistributionFill;
    hStackView.spacing = 8;
    
    [textFiled1.widthAnchor constraintEqualToAnchor:textFiled2.widthAnchor].active = YES;
    [textFiled1.heightAnchor constraintEqualToConstant:40].active = YES;
    [textFiled2.heightAnchor constraintEqualToAnchor:textFiled1.heightAnchor].active = YES;

    UIStackView *vStackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, hStackView]];
    vStackView.axis = UILayoutConstraintAxisVertical;
    vStackView.alignment = UIStackViewAlignmentLeading;
    vStackView.distribution = UIStackViewDistributionFill;
    vStackView.spacing = 8;
    
    [hStackView.leftAnchor constraintEqualToAnchor:vStackView.leftAnchor].active = YES;
    [hStackView.rightAnchor constraintEqualToAnchor:vStackView.rightAnchor].active = YES;
    
    return vStackView;
}

- (void)closeButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonTapped:(UIButton *)button {
    switch (button.tag) {
            
        case 10010:
            [self gotoRecord:MDUnifiedRecordLevelTypeHigh];
            break;
            
        default:
            break;
    }
}

- (void)segmentControlTapped:(UISegmentedControl *)control {
    switch (control.selectedSegmentIndex) {
        case 0:
            if (control.tag == 10000) {
                MDRecordRecordingSettingMananger.ratio = RecordScreenRatioFullScreen;
            } else {
                MDRecordRecordingSettingMananger.resolution = RecordingResolution640x480;
            }
            break;
            
        case 1:
            if (control.tag == 10000) {
                MDRecordRecordingSettingMananger.ratio = RecordScreenRatio9to16;
            } else {
                MDRecordRecordingSettingMananger.resolution = RecordingResolution960x540;
            }
            break;
            
        case 2:
            if (control.tag == 10000) {
                MDRecordRecordingSettingMananger.ratio = RecordScreenRatio3to4;
            } else {
                MDRecordRecordingSettingMananger.resolution = RecordingResolution1280x720;
            }
            break;
            
        case 3:
            if (control.tag == 10000) {
                MDRecordRecordingSettingMananger.ratio = RecordScreenRatio1to1;
            } else {
                MDRecordRecordingSettingMananger.resolution = RecordingResolution1920x1080;
            }
            break;
            
        default:
            break;
    }
}

- (void)textFieldValueChanged:(UITextField *)textField {
    switch (textField.tag) {
        case 1000:
            MDRecordRecordingSettingMananger.frameRate = [textField.text intValue];
            break;
            
        case 1001:
            MDRecordRecordingSettingMananger.bitRate = [textField.text floatValue] * 1024 * 1024;
            break;
            
        case 1002:
            MDRecordRecordingSettingMananger.upperExposureBias = [textField.text floatValue];
            break;
            
        case 1003:
            MDRecordRecordingSettingMananger.lowExposureBias = [textField.text floatValue];
            break;
            
        default:
            break;
    }
}

- (void)gotoRecord:(MDUnifiedRecordLevelType)levelType {
    if (![MDCameraContainerViewController checkDevicePermission]) {
        return;
    }
    
    MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
    __weak typeof(containerVC) weakContainerVC = containerVC;
    
    MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
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
    for (int i = 1000; i < 1004; i++) {
        UITextField *field = [self.view viewWithTag:i];
        [field resignFirstResponder];
    }
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
