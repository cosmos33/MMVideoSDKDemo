//
//  MDMomentFaceDecorationController.m
//  MDChat
//
//  Created by wangxuan on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentFaceDecorationViewController.h"
#import "MDFaceDecorationItem.h"
//#import "MDFaceDecorationView.h"
#import "MDFaceDecorationPageView.h"
#import "MDPublicSwiftHeader.h"

static const NSString *kMomentFaceDecorationCell = @"MDMomentFaceDecorationCell";

#define kFaceDecorationViewH (250 + HOME_INDICATOR_HEIGHT)

@interface MDMomentFaceDecorationViewController ()
<UIGestureRecognizerDelegate,
NewFaceDecorationViewDelegate>

//@property (nonatomic, strong) MDFaceDecorationView        *decorationView;
@property (nonatomic, strong) UIVisualEffectView          *effectView;
@property (nonatomic, strong) UIView                      *contentView;
@property (nonatomic, strong) NewFaceDecorationView *newDecorationView;
@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation MDMomentFaceDecorationViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, MDScreenHeight - kFaceDecorationViewH , MDScreenWidth, kFaceDecorationViewH);
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.effectView];
//    [self.contentView addSubview:self.decorationView];
    [self.contentView addSubview:self.newDecorationView];
    
    [self.contentView addSubview:self.recordButton];
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.recordButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.recordButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:180].active = YES;
    [self.recordButton.widthAnchor constraintEqualToConstant:50].active = YES;
    [self.recordButton.heightAnchor constraintEqualToAnchor:self.recordButton.widthAnchor].active = YES;

    //dataHandle刷新通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionData:) name:MDFaceDecorationDrawerUpdateNotiName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDataHandle:(MDFaceDecorationDataHandle *)dataHandle {
    _dataHandle = dataHandle;
    //变脸分类数据源
//    NSArray *classArray = [dataHandle getDrawerClassDataArray];
//    [self.decorationView updateSelectedViewItems:classArray];
    //变脸item数据源
//    NSArray *itemsArray = [dataHandle getDrawerDataArray];
//    [self.decorationView updatePageItems:itemsArray];
    
    NSArray<MDFaceDecorationItem *> *itemsArray = [dataHandle getDrawerDataArray][1];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[0].resourcePath isNotEmpty] type:CellTypeGesture];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[1].resourcePath isNotEmpty] type:CellTypeExpression];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[2].resourcePath isNotEmpty] type:CellTypeEffect3D];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[3].resourcePath isNotEmpty] type:CellTypeSegment];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[8].resourcePath isNotEmpty] type:CellTypeAudio];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[9].resourcePath isNotEmpty] type:CellTypeSheepAudio];
    
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[4].resourcePath isNotEmpty] type:CellTypeGift1];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[5].resourcePath isNotEmpty] type:CellTypeGift2];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[6].resourcePath isNotEmpty] type:CellTypeGift3];
    [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[7].resourcePath isNotEmpty] type:CellTypeGift4];
}

- (void)setSelectedClassWithIdentifier:(NSString *)identifer {
//    [self.decorationView setSelectedClassWithIdentifier:identifer];
}
- (void)setSelectedClassWithIndex:(NSInteger)index {
//    [self.decorationView setSelectedClassWithIndex:index];
}

#pragma mark - notification event
- (void)reloadCollectionData:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    BOOL change = NO;
    if (userInfo) {
        change = [userInfo boolForKey:@"change" defaultValue:NO];
    }
    
    if (change) {
        //变脸item数据源
//        NSArray *itemsArray = [self.dataHandle getDrawerDataArray];
//        [self.decorationView updatePageItems:itemsArray];
    }else {
//        [self.decorationView.collectionView reloadData];
    }
    
    NSArray<MDFaceDecorationItem *> *itemsArray = [self.dataHandle getDrawerDataArray][1];
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[0].isDownloading type:CellTypeGesture];
    if (!itemsArray[0].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[0].resourcePath isNotEmpty] type:CellTypeGesture];
    }

    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[1].isDownloading type:CellTypeExpression];
    if (!itemsArray[1].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[1].resourcePath isNotEmpty] type:CellTypeExpression];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[2].isDownloading type:CellTypeEffect3D];
    if (!itemsArray[2].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[2].resourcePath isNotEmpty] type:CellTypeEffect3D];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[3].isDownloading type:CellTypeSegment];
    if (!itemsArray[3].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[3].resourcePath isNotEmpty] type:CellTypeSegment];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[8].isDownloading type:CellTypeAudio];
    if (!itemsArray[8].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[8].resourcePath isNotEmpty] type:CellTypeAudio];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[9].isDownloading type:CellTypeSheepAudio];
    if (!itemsArray[9].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[9].resourcePath isNotEmpty] type:CellTypeSheepAudio];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[4].isDownloading type:CellTypeGift1];
    if (!itemsArray[4].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[4].resourcePath isNotEmpty] type:CellTypeGift1];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[5].isDownloading type:CellTypeGift2];
    if (!itemsArray[5].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[5].resourcePath isNotEmpty] type:CellTypeGift2];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[6].isDownloading type:CellTypeGift3];
    if (!itemsArray[6].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[6].resourcePath isNotEmpty] type:CellTypeGift3];
    }
    
    [self.newDecorationView updateDownloadingWithIsDownloading:itemsArray[7].isDownloading type:CellTypeGift4];
    if (!itemsArray[7].isDownloading) {
        [self.newDecorationView updateHasResourceWithHasResource:[itemsArray[7].resourcePath isNotEmpty] type:CellTypeGift4];
    }
}

- (void)recordButtonTapped:(UIButton *)button {
    self.recordHandler ? self.recordHandler() : nil;
}

#pragma mark - MDFaceDecorationViewDelegate

//- (void)faceDecorationPageView:(MDFaceDecorationPageView *)pageView
//                     indexPath:(NSIndexPath *)indexPath
//                     withModel:(MDFaceDecorationItem *)cellModel {
//
//    if (![cellModel.identifier isNotEmpty] || cellModel.isDownloading) {
//        return;
//    }
//    //设置点击弹性
//    cellModel.clickedToBounce = YES;
//    //调用dataHandle处理item
//    [self.dataHandle drawerDidSelectedItem:cellModel];
//}

//清除选中变脸
//- (void)faceDecorationViewCleanDecoration:(MDFaceDecorationView *)view {
//    [self.dataHandle drawerDidCleanAllItem];
//}

#pragma mark - 显示 隐藏变脸抽屉View
- (BOOL)showAnimate
{
    if (self.isShowed || self.isAnimating) return NO;
    
    self.view.hidden = NO;
    self.show = YES;
    self.animating = YES;
    
    UIView* view = self.contentView;
    view.transform = CGAffineTransformMakeTranslation(0, view.height);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
    
    return YES;
}

- (void)hideAnimateWithCompleteBlock:(void(^)(void))completeBlock
{
    if (!self.isShowed || self.isAnimating) return;

    self.view.hidden = NO;
    self.show = NO;
    self.animating = YES;
    
    UIView* view = self.contentView;
    view.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.25 animations:^{
        view.transform = CGAffineTransformMakeTranslation(0, view.height);
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.animating = NO;
        if (completeBlock) {
            completeBlock();
        }
    }];
}

#pragma mark - lazy
- (UIView *)contentView {
    if(!_contentView){
        _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        _contentView.height += 50;
    }
    return _contentView;
}

//- (MDFaceDecorationView *)decorationView{
//
//    if(!_decorationView){
//        _decorationView = [[MDFaceDecorationView alloc] initWithFrame:self.view.bounds];
//        _decorationView.delegate = self;
//    }
//    return _decorationView;
//}

- (NewFaceDecorationView *)newDecorationView {
    if (!_newDecorationView) {
        _newDecorationView = [[NewFaceDecorationView alloc] initWithFrame:self.view.bounds];
        _newDecorationView.delegate = self;
    }
    return _newDecorationView;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setTitle:@"单击拍" forState:UIControlStateNormal];
        [_recordButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _recordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_recordButton addTarget:self action:@selector(recordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _recordButton.backgroundColor = [UIColor greenColor];
        _recordButton.layer.cornerRadius = 25;
    }
    return _recordButton;
}

- (UIVisualEffectView *)effectView {
    if(!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _effectView.frame = self.contentView.bounds;
        _effectView.layer.cornerRadius = 10.0f;
        _effectView.layer.masksToBounds = YES;
    }
    return _effectView;
}

#pragma mark - NewFaceDecorationViewDelegate Methods

- (void)selectedWithView:(NewFaceDecorationView *)view type:(enum CellType)type {
    //调用dataHandle处理item
    NSArray *itemsArray = [self.dataHandle getDrawerDataArray];
    MDFaceDecorationItem *cellModel = nil;
    switch (type) {
        case CellTypeGesture:
            cellModel = itemsArray[1][0];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
        case CellTypeExpression:
            cellModel = itemsArray[1][1];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
        case CellTypeEffect3D:
            cellModel = itemsArray[1][2];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
        case CellTypeSegment:
            cellModel = itemsArray[1][3];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
        case CellTypeGift1:
            cellModel = itemsArray[1][4];
            [self.dataHandle drawerDidSelectedGift:cellModel];
            break;
        case CellTypeGift2:
            cellModel = itemsArray[1][5];
            [self.dataHandle drawerDidSelectedGift:cellModel];
            break;
        case CellTypeGift3:
            cellModel = itemsArray[1][6];
            [self.dataHandle drawerDidSelectedGift:cellModel];
            break;
        case CellTypeGift4:
            cellModel = itemsArray[1][7];
            [self.dataHandle drawerDidSelectedGift:cellModel];
            break;
        case CellTypeAudio:
            cellModel = itemsArray[1][8];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
        case CellTypeSheepAudio:
            cellModel = itemsArray[1][9];
            [self.dataHandle drawerDidSelectedItem:cellModel];
            break;
            
        default:
            break;
    }

}

- (void)didClearWithView:(NewFaceDecorationView *)view type:(enum CellType)type {
    if (type == CellTypeNone) {
        [self.dataHandle drawerDidCleanAllItem];
    } else if (type == CellTypeGift0) {
        [self.dataHandle drawerDidCleanAllGift];
    }
}

@end
