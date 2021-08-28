//
//  MDRecordFilterDrawerController.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/2.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordMakeUpListView.h"
#import "MDRecordFilterModel.h"

typedef NS_ENUM(NSInteger, MDRecordFilterScenceType) {
    MDRecordFilterScenceTypeNormal,
    MDRecordFilterScenceTypeArPet
};

FOUNDATION_EXPORT NSString *const kDrawerControllerFilterKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerMakeupKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerChangeFacialKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerMicroKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerThinBodyKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerLongLegKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerMakeUpKey;
FOUNDATION_EXPORT NSString *const kDrawerControllerMakeupStyleKey;

@protocol MDRecordFilterDrawerControllerDelegate<NSObject>

@optional
///滤镜
- (void)didSelectedFilterItem:(NSInteger)index;
///美颜 0 清除
- (void)didSelectedMakeUpItem:(NSInteger)index;
///瘦脸  0 清除
- (void)didSelectedFaceLiftItem:(NSInteger)index;
///瘦身
- (void)didSelectedThinBodyItem:(NSInteger)index;
///长腿
- (void)didSelectedLongLegItem:(NSInteger)index;
// 美白
- (void)didSetSkinWhitenValue:(CGFloat)value;
// 磨皮
- (void)didSetSmoothSkinValue:(CGFloat)value;
// 大眼
- (void)didSetBigEyeValue:(CGFloat)value;
// 瘦脸
- (void)didSetThinFaceValue:(CGFloat)value;
// 滤镜浓度
- (void)didSetFilterIntensity:(CGFloat)value;

- (void)didSelectedMakeUpModel:(NSString *)modelType;

- (void)didSetMakeUpLookIntensity:(CGFloat)value;
- (void)didSetMakeUpBeautyIntensity:(CGFloat)value;

- (void)didselectedMicroSurgeryModel:(NSString *)index;
- (void)didSetMicroSurgeryIntensity:(CGFloat)value;

- (void)longTounchBtnClickStart;
- (void)longTounchBtnClickEnd;

@end


@interface MDRecordFilterDrawerController : UIViewController

- (instancetype)initWithTagArray:(NSArray *)tagArray;

@property(nonatomic,weak) id<MDRecordFilterDrawerControllerDelegate> delegate;

- (instancetype)initWithFilterScenceType:(MDRecordFilterScenceType)scenceType;

@property (nonatomic,assign,getter=isShowed)    BOOL        show;
@property (nonatomic,assign,getter=isAnimating) BOOL        animating;

- (void)setFilterModels:(NSArray<MDRecordFilterModel *> *)filterModels;
- (void)setDefaultSelectIndex:(NSUInteger)index;

- (void)showAnimation;
- (void)hideAnimationWithCompleteBlock:(void(^)(void))completeBlock;

- (void)setFilterIndex:(NSUInteger)index;
- (void)setMakeUpIndex:(NSUInteger)index;
- (void)setThinFaceIndex:(NSInteger)index;
- (void)setThinBodyIndex:(NSInteger)index;
- (void)setLongLegIndex:(NSInteger)index;

- (void)setMakeupBeautyIndex:(NSUInteger)index;
- (void)setMakeupStyleIndex:(NSUInteger)index;
- (void)setMicroSurgeryIndex:(NSUInteger)index;
@end
