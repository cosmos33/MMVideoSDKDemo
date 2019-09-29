//
//  MDRecordGuideTipsManager.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordGuideTipsManager.h"
#import "MDRecordTipItem.h"
#import "MUAt8AlertBar.h"
#import "MUAlertBarDispatcher.h"



@interface MDRecordGuideTipsManager()

@property (nonatomic,strong) NSDictionary               *tipsConfig;
@property (nonatomic,strong) NSMutableDictionary        *localTipsConfig;

@property (nonatomic,  weak) UIView                     *containerView;
@property (nonatomic,strong) MUAlertBar                 *guideBar;

@property (nonatomic,assign,getter=isShowing) BOOL      showing;

@end

@implementation MDRecordGuideTipsManager

- (instancetype)init
{
    if (self = [super init]) {
        _tipsConfig = nil; //[[[MDContext currentUser] dbStateHoldProvider] recordGuideTipsInfo];
    }
    return self;
}

- (NSMutableDictionary *)localTipsConfig
{
    if (!_localTipsConfig) {
        _localTipsConfig = [NSMutableDictionary dictionary];
    }
    return _localTipsConfig;
}

#pragma mark - 气泡展示
- (void)doGuideAnimationWithTipsType:(MDRecordGuideTipsType)tipsType andContainerView:(UIView *)containerView
{
    _tipsConfig = nil; //[[[MDContext currentUser] dbStateHoldProvider] recordGuideTipsInfo];
    
    if (![self canDoGuideAnimationWithTipsType:tipsType] || self.isShowing) return;
    
    _containerView = containerView;
    _showing = YES;
    
    NSMutableArray<NSString *> *tipKeyArray = [self identifierArrayWithTipsType:tipsType];
    [self doGuideAnimationWithTipKeyArray:tipKeyArray];
}

- (void)doGuideAnimationWithTipKeyArray:(NSMutableArray<NSString *> *)tipKeyArray
{
    if (tipKeyArray.count == 0) {
        _showing = NO;
//        [[[MDContext currentUser] dbStateHoldProvider] setRecordGuideTipsInfo:self.tipsConfig];
        return;
    };
    
    __block NSString *tipKey = [tipKeyArray firstObject];
    MDRecordTipItem *tipItem = [self tipItemWithTipKey:tipKey];
    
    NSString *guideText = tipItem.tipText;
    CGPoint anchorPoint = CGPointZero;
    NSInteger anchorType = MUAt8AnchorTypeBottom;
    CGFloat offset = 0;
    
    [self.delegate anchorPoint:&anchorPoint anchorOffSet:&offset anchorType:&anchorType withIdentifer:tipKey];
    
    __weak typeof(self) weakSelf = self;
    
    [self addGuideBarView:guideText anchorPoint:anchorPoint anchorType:anchorType anchorOffset:offset shouldShow:tipItem.showTip  closeBlock:^{
        
        MDRecordTipItem *tipItem = [weakSelf tipItemWithTipKey:tipKey];
        if ([tipItem.tipText isNotEmpty]) {
            tipItem.showTip = NO;
        }
        
        if ([tipKeyArray containsObject:tipKey]) {
            [tipKeyArray removeObject:tipKey];
            [weakSelf doGuideAnimationWithTipKeyArray:tipKeyArray];
        }
    }];
}

- (void)addGuideBarView:(NSString *)title
            anchorPoint:(CGPoint)anchorPoint
             anchorType:(NSInteger)anchorType
           anchorOffset:(CGFloat)offset
             shouldShow:(BOOL)shouldShow
             closeBlock:(void(^)())closeBlock
{
    if (![title isNotEmpty] || CGPointEqualToPoint(anchorPoint, CGPointZero) || !shouldShow) {
        closeBlock();
        return;
    }
    
    MUAt8AlertBarModel *model = [MUAt8AlertBarModel new];
    model.maskFrame = self.containerView.frame;
    model.title = title;
    model.anchorPoint = anchorPoint;
    model.anchorType = anchorType;
    model.textColor = RGBCOLOR(32, 33, 33);
    model.backgroundColor = [UIColor whiteColor];
    model.anchorOffset = offset;
    model.closeBlock = closeBlock;
    __block MUAlertBar *guideBar = [MUAlertBarDispatcher alertBarWithModel:model];
    [self.containerView addSubview:guideBar];
    //2秒后自动消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (guideBar.superview) {
            [guideBar removeFromSuperview];
            if (closeBlock != nil) {
                closeBlock();
            }
        }
    });
}

- (MDRecordTipItem *)tipItemWithTipKey:(NSString *)tipKey
{
    MDRecordTipItem *tipItem = [self.tipsConfig objectForKey:tipKey defaultValue:nil];
    if (tipItem == nil) {
        tipItem = [self.localTipsConfig objectForKey:tipKey defaultValue:nil];
    }
    return tipItem;
}

- (NSMutableArray<NSString *> *)identifierArrayWithTipsType:(MDRecordGuideTipsType)tipsType
{
    NSMutableArray *result = nil;
    
    switch (tipsType) {
        case MDRecordGuideTipsTypeNormalCapture:
        {
            result = [NSMutableArray arrayWithCapacity:2];
            [result addObjectSafe:kRecordTipOfFace];
            [result addObjectSafe:kRecordTipOfFilter];
            [result addObjectSafe:kRecordTipOfThin];
            break;
        }
        case MDRecordGuideTipsTypeHighCapture:
        {
            result = [NSMutableArray array];
            [result addObjectSafe:kRecordTipOfFace];
            [result addObjectSafe:kRecordTipOfFilter];
            [result addObjectSafe:kRecordTipOfMusic];
            [result addObjectSafe:kRecordTipOfThin];
            break;
        }
        case MDRecordGuideTipsTypeVideoEdit:
        {
            result = [NSMutableArray arrayWithCapacity:4];
            [result addObjectSafe:kRecordTipOfMusic];
            [result addObjectSafe:kRecordTipOfDynamicStiker];
            [result addObjectSafe:kRecordTipOfCover];
            [result addObjectSafe:kRecordTipOfVideoEditThin];
            break;
        }
        case MDRecordGuideTipsTypeImageEdit:
        {
            result = [NSMutableArray arrayWithCapacity:2];
            [result addObjectSafe:kRecordTipOfFilter];
            [result addObjectSafe:kRecordTipOfStaticStiker];
            [result addObjectSafe:kRecordTipOfImageEditThin];
            break;
        }
            
        default:
            break;
    }
    
    return result;
}

- (BOOL)canDoGuideAnimationWithTipsType:(MDRecordGuideTipsType)tipsType
{
    __block BOOL result = NO;
    
    [_tipsConfig enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        MDRecordTipItem *tipItem = nil;
        if ([obj isKindOfClass:[MDRecordTipItem class]]) {
            tipItem = (MDRecordTipItem *)obj;
        }
        if (tipItem && tipItem.showTip) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

#pragma mark - 红点
- (BOOL)canShowRedPointWithIdentifier:(NSString *)identifier
{
    _tipsConfig = nil;// [[[MDContext currentUser] dbStateHoldProvider] recordGuideTipsInfo];
    
    BOOL result = NO;
    
    MDRecordTipItem *tipItem = [self tipItemWithTipKey:identifier];
    if (tipItem.showTip && ![tipItem.tipText isNotEmpty]) {
        result = YES;
    }
    
    return result;
}

- (void)redPointDidShowWithIdentifier:(NSString *)identifier
{
    _tipsConfig = nil;//[[[MDContext currentUser] dbStateHoldProvider] recordGuideTipsInfo];
    
    MDRecordTipItem *tipItem = [self tipItemWithTipKey:identifier];
    tipItem.showTip = NO;
//    [[[MDContext currentUser] dbStateHoldProvider] setRecordGuideTipsInfo:self.tipsConfig];
}

@end
