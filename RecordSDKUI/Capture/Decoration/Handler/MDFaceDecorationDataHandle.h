//
//  MDFaceDecorationDataHandle.h
//  MDChat
//
//  Created by YZK on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDFaceDecorationItem.h"
#import "MDRecordHeader.h"

FOUNDATION_EXPORT NSString * const MDFaceDecorationRecommendUpdateNotiName;
FOUNDATION_EXPORT NSString * const MDFaceDecorationDrawerUpdateNotiName;


@protocol MDFaceDecorationDataHandleDelegate <NSObject>
//需要取消选中的变脸效果
- (void)recommendFaceDecorationDidLoadingItem:(MDFaceDecorationItem *)item;
//变脸推荐栏选中item，此时需要应用变脸效果,如果是nil，说明此时选中1号位，取消变脸
- (void)recommendFaceDecorationDidSelectedItem:(MDFaceDecorationItem *)item;
//变脸推荐栏选中item下载失败
- (void)recommendFaceDecorationDidDownLoadFail:(MDFaceDecorationItem *)item;
//变脸抽屉选中item，如果是nil，说明取消变脸
- (void)drawerFaceDecorationDidSelectedItem:(MDFaceDecorationItem *)item;

//变脸抽屉选中gift, 如果是nil, 说明取消gift
- (void)drawerFaceDecorationDidSelectedGift:(MDFaceDecorationItem *)gift;
// 清除礼物
- (void)drawerFaceDecorationDidClearAllGift;

@end


@interface MDFaceDecorationDataHandle : NSObject

- (instancetype)initWithFilterARDecoration:(BOOL)filterARDecoration;

@property (nonatomic, weak) id<MDFaceDecorationDataHandleDelegate> delegate;

//当前变脸推荐选中的变脸item，当为1号位时是nil，由变脸推荐VCL传入，注意和变脸抽屉选中的不一定是一个，比如选中一个未下载的变脸，此时打开变脸抽屉，变脸抽屉应该没有任何选中，所以不能标记currentSelectItem.isSelected = YES
@property (nonatomic,strong) MDFaceDecorationItem *currentSelectItem;


/**
 设置变脸推荐栏列默认定位
 */
- (void)setRecommendScrollToIndex:(NSInteger)index;

//变脸推荐数据列表
@property (nonatomic,strong,readonly) NSArray<MDFaceDecorationItem*> *recommendDataArray;

/**
 运营带入的默认变脸数据，需要放入2号位
 */
- (void)setOperationItemWithFaceId:(NSString *)faceId
                           classId:(NSString *)classId;

/**
 获取变脸抽屉列表数据源
 */
- (NSArray<NSArray<MDFaceDecorationItem*> *> *)getDrawerDataArray;

/**
 获取变脸分类列表数据源
 */
- (NSArray<MDFaceDecorationClassItem*> *)getDrawerClassDataArray;

/**
 变脸抽屉往某个变脸分类里追加数据
 */
- (void)appendItemForClassId:(NSString *)faceClassId withFaceID:(NSString *)faceID;


/**
 选中/取消选中变脸item
 */
- (void)recommendDidSelectedItem:(MDFaceDecorationItem *)item;
- (void)drawerDidSelectedItem:(MDFaceDecorationItem *)item;
- (void)drawerDidCleanAllItem;

- (void)drawerDidSelectedGift:(MDFaceDecorationItem *)gift;
- (void)drawerDidCleanAllGift;

@end
