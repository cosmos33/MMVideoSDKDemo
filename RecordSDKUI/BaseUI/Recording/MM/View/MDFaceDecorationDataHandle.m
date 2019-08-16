//
//  MDFaceDecorationDataHandle.m
//  MDChat
//
//  Created by YZK on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationDataHandle.h"
#import "MDDecorationTool.h"
#import "MDFaceDecorationManager.h"

NSString * const MDFaceDecorationRecommendUpdateNotiName = @"MDFaceDecorationRecommendUpdateNotiName";
NSString * const MDFaceDecorationDrawerUpdateNotiName = @"MDFaceDecorationDrawerUpdateNotiName";


typedef NS_ENUM(NSInteger,MDFaceDecorationFromSource) {
    MDFaceDecorationFromDrawer = 1,  //变脸抽屉
    MDFaceDecorationFromRecommend,   //变脸推荐栏
};


@interface MDFaceDecorationDataHandle ()
<MDFaceDecorationManagerDelegate>

//运营带入的变脸id和classId
@property (nonatomic,strong) NSString *operationFaceId;
@property (nonatomic,strong) NSString *operationClassId;

@property (nonatomic,strong) NSArray<MDFaceDecorationItem*> *recommendOriginArray;
@property (nonatomic,strong) NSArray<MDFaceDecorationItem*> *recommendDataArray;

//当前使用的变脸item，注意和currentSelectItem区分，表示的意义不同
@property (nonatomic,strong) MDFaceDecorationItem *currentUseItem;

@property (nonatomic,strong) NSMutableDictionary *fromSourceDict; //记录下载成功的变脸是从推荐栏还是抽屉发起，用于下载完成打点

@property (nonatomic,assign) BOOL filterARDecoration; //用于区分是否过滤ar素材
@end

@implementation MDFaceDecorationDataHandle


- (instancetype)init {
    return [self initWithFilterARDecoration:NO];
}
- (instancetype)initWithFilterARDecoration:(BOOL)filterARDecoration {
    self = [super init];
    if (self) {
        _filterARDecoration = filterARDecoration;

        [MDRecordContext faceDecorationManager].delegate = self;
        [[MDRecordContext faceDecorationManager] requestLocalFaceDecoration];
        [self loadRecommendData];
    }
    return self;
}

- (void)dealloc {
    [MDRecordContext faceDecorationManager].delegate = nil;
}

- (void)setOperationItemWithFaceId:(NSString *)faceId
                           classId:(NSString *)classId {
    if ([faceId isNotEmpty] && [classId isNotEmpty]) {
        self.operationFaceId = faceId;
        self.operationClassId = classId;
        
        //更新变脸推荐列表
        [self loadRecommendData];
    }
}

- (void)setRecommendScrollToIndex:(NSInteger)index {
    [self updateRecommendUIAndScrollToIndex:index needSelected:YES];
}

#pragma mark - 数据源处理

/**
 重新加载推荐变脸数据
 */
- (void)loadRecommendData {
    self.recommendOriginArray = [self getOriginRecommendDataArray];
    self.recommendDataArray = self.recommendOriginArray;
}

/**
 获取变脸推荐列表数据源，不包含第N+1号位(变脸抽屉选中的)
 */
- (NSArray<MDFaceDecorationItem*> *)getOriginRecommendDataArray {
    // 获取全部变脸数据
    NSDictionary *faceItems = [MDRecordContext faceDecorationManager].faceItems;
    
    NSMutableArray<MDFaceDecorationItem *> *itemArray = [NSMutableArray array];

    //添加2号位变脸
    MDFaceDecorationItem *secondFaceItem = nil;
    if ([self.operationFaceId isNotEmpty]) {
        //使用运营带过来的变脸id
        secondFaceItem = [faceItems objectForKey:self.operationFaceId defaultValue:nil];
    }else {
        //从随即变脸池中随即选取一个
        NSString *randomFaceId = [self randomStringWithArray:[MDRecordContext faceDecorationManager].randomFaceIDs];
        secondFaceItem = [faceItems objectForKey:randomFaceId defaultValue:nil];
    }
    [itemArray addObjectSafe:secondFaceItem];

    
    //添加3~N号位变脸
    NSMutableArray *recommendFaceIds = [NSMutableArray arrayWithArray:[MDRecordContext faceDecorationManager].recommendFaceIDS];
    //与2号位排重
    [recommendFaceIds removeObject:secondFaceItem.identifier];
    for (NSString *identifier in recommendFaceIds) {
        MDFaceDecorationItem *faceItem = [faceItems objectForKey:identifier defaultValue:nil];
        [itemArray addObjectSafe:faceItem];
    }
    
    //如果有数据，添加1号位空白的变脸
    if (itemArray.count>0) {
        MDFaceDecorationItem* item = [[MDFaceDecorationItem alloc] init];
        item.isPlaceholdItem = YES;
        [itemArray insertObject:item atIndexInBoundary:0];
    }
    
    if (self.filterARDecoration) {
        //过滤掉ar素材
        NSMutableArray<MDFaceDecorationItem *> *filterARArray = [NSMutableArray array];
        for (MDFaceDecorationItem* item in itemArray) {
            if (item.needAR) {
                [filterARArray addObject:item];
            }
        }
        [itemArray removeObjectsInArray:filterARArray];
    }
    
    return itemArray;
}


/**
 获取变脸抽屉列表数据源
 */
- (NSArray<NSArray<MDFaceDecorationItem*> *> *)getDrawerDataArray {
    // 获取全部变脸数据
    NSDictionary *faceItems = [MDRecordContext faceDecorationManager].faceItems;
    // 获取变脸抽屉数据
    NSDictionary<NSString *,NSArray<NSString *>*> *faceClassMaps = [MDRecordContext faceDecorationManager].faceClassMaps;
    // 获取分类数据
    NSArray<MDFaceDecorationClassItem*> *faceClassItems = [self getDrawerClassDataArray];
    
    NSMutableArray<NSArray<MDFaceDecorationItem*> *> *drawerDataArray = [NSMutableArray array];
    for (MDFaceDecorationClassItem *classItem in faceClassItems) {
        NSArray<NSString *> *items = [faceClassMaps arrayForKey:classItem.identifier defaultValue:nil];
        
        NSMutableArray* classItemArray = [NSMutableArray array];
        for (NSString* identifier in items) {
            MDFaceDecorationItem *faceItem = [faceItems objectForKey:identifier defaultValue:nil];
            
            if (self.filterARDecoration && faceItem.needAR) {
                //如果需要过滤ar且素材是ar，则过滤掉
                continue;
            }
            [classItemArray addObjectSafe:faceItem];
        }
        [drawerDataArray addObjectSafe:classItemArray];
    }
    return drawerDataArray;
}

/**
 获取变脸分类列表数据源
 */
- (NSArray<MDFaceDecorationClassItem*> *)getDrawerClassDataArray {
    return [MDRecordContext faceDecorationManager].faceClassItems;
}

#pragma mark - 下载，添加item

- (void)downloadItemWithFaceId:(NSString *)faceId fromSource:(MDFaceDecorationFromSource)fromSource {
    //记录下载来源，用于下载完成打点
    [self.fromSourceDict setInteger:fromSource forKey:faceId];
    
    NSDictionary *faceItems = [MDRecordContext faceDecorationManager].faceItems;
    MDFaceDecorationItem *faceItem = [faceItems objectForKey:faceId defaultValue:nil];
    [[MDRecordContext faceDecorationManager] downloadItem:faceItem withType:MDFaceDecorationDownloadType_Zip];
    
    //打点
    [self logWithFaceId:faceId fromSource:fromSource beginDownload:YES];
}

- (void)appendItemForClassId:(NSString *)faceClassId withFaceID:(NSString *)faceID {
    BOOL needRemove = NO;
    NSDictionary<NSString *,NSArray<NSString *>*> *faceClassMaps = [MDRecordContext faceDecorationManager].faceClassMaps;
    NSArray<NSString *> *items = [faceClassMaps arrayForKey:faceClassId defaultValue:nil];
    if (items.count>=kMaxDecorationCount*4) {
        needRemove = YES;
    }
    [[MDRecordContext faceDecorationManager] appendAFaceItemForClassId:faceClassId withFaceID:faceID needRemove:needRemove];
}

#pragma mark - 选中item

- (void)recommendDidSelectedItem:(MDFaceDecorationItem *)item {
    //取消所有item的选定
    [self deselectAllItem];
    
    if (![item.identifier isNotEmpty]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidSelectedItem:)]) {
            [self.delegate recommendFaceDecorationDidSelectedItem:nil];
        }
        [self updateDrawerUI];
        return;
    }
    
    if (item.isDownloading) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidLoadingItem:)]) {
            [self.delegate recommendFaceDecorationDidLoadingItem:item];
        }
        return;
    }
    
    if ([item.resourcePath isNotEmpty]) {
        //资源包已经存在，通知代理应用变脸效果
        if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidSelectedItem:)]) {
            [self.delegate recommendFaceDecorationDidSelectedItem:item];
        }
        item.isSelected = YES;
        self.currentUseItem = item;
        
        [self appendItemForClassId:kFaceClassIndentifierOfMy withFaceID:item.identifier];
        [self updateDrawerUIWithDataChange:YES];

    } else {
        //下载资源,通过dataHandle中下载开始的回调刷新UI
        if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidLoadingItem:)]) {
            [self.delegate recommendFaceDecorationDidLoadingItem:item];
        }
        [self downloadItemWithFaceId:item.identifier fromSource:MDFaceDecorationFromRecommend];
    }
}

- (void)drawerDidSelectedItem:(MDFaceDecorationItem *)item {
    //去掉变脸推荐bar后新增，如果要加会变脸推荐栏，删除此逻辑
    self.currentSelectItem = nil;
    
    if ([item.resourcePath isNotEmpty]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawerFaceDecorationDidSelectedItem:)]) {
            [self.delegate drawerFaceDecorationDidSelectedItem:item];
        }
        [self deselectAllItem];
        item.isSelected = YES;
        self.currentUseItem = item;

        [self appendItemForClassId:kFaceClassIndentifierOfMy withFaceID:item.identifier];
        [self updateDrawerUIWithDataChange:YES];
        [self updateRecommendUIWithDrawerSelectedItem:item];
        
    } else {
        //下载资源,通过dataHandle中下载开始的回调刷新UI
        [self downloadItemWithFaceId:item.identifier fromSource:MDFaceDecorationFromDrawer];
    }
}

- (void)drawerDidSelectedGift:(MDFaceDecorationItem *)item {
    //去掉变脸推荐bar后新增，如果要加会变脸推荐栏，删除此逻辑
    self.currentSelectItem = nil;
    
    if ([item.resourcePath isNotEmpty]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawerFaceDecorationDidSelectedGift:)]) {
            [self.delegate drawerFaceDecorationDidSelectedGift:item];
        }
        [self deselectAllItem];
        item.isSelected = YES;
        self.currentUseItem = item;
        
        [self appendItemForClassId:kFaceClassIndentifierOfMy withFaceID:item.identifier];
        [self updateDrawerUIWithDataChange:YES];
        [self updateRecommendUIWithDrawerSelectedItem:item];
        
    } else {
        //下载资源,通过dataHandle中下载开始的回调刷新UI
        [self downloadItemWithFaceId:item.identifier fromSource:MDFaceDecorationFromDrawer];
    }
}

- (void)drawerDidCleanAllItem {
    [self deselectAllItem];
    [self updateRecommendUIAndScrollToIndex:0];
    [self updateDrawerUI];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawerFaceDecorationDidSelectedItem:)]) {
        [self.delegate drawerFaceDecorationDidSelectedItem:nil];
    }
}

- (void)drawerDidCleanAllGift {
    [self deselectAllItem];
    [self updateRecommendUIAndScrollToIndex:0];
    [self updateDrawerUI];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawerFaceDecorationDidClearAllGift)]) {
        [self.delegate drawerFaceDecorationDidClearAllGift];
    }
}

- (void)deselectAllItem {
    self.currentUseItem.isSelected = NO;
    self.currentUseItem = nil;
}


/**
 根据 变脸抽屉选中的变脸item更新 变脸推荐UI
 */
- (void)updateRecommendUIWithDrawerSelectedItem:(MDFaceDecorationItem *)decorationItem {
    if (self.recommendDataArray.count == 0) {
        return;
    }
    
    __block NSInteger index = NSNotFound;
    [self.recommendOriginArray enumerateObjectsUsingBlock:^(MDFaceDecorationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:decorationItem.identifier]) {
            //说明当前抽屉选中的item在变脸推荐中
            index = idx;
            *stop = YES;
        }
    }];
    
    self.recommendDataArray = self.recommendOriginArray;
    if (index == NSNotFound) {
        //更新变脸推荐列表
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:self.recommendOriginArray];
        [dataArray addObjectSafe:decorationItem];
        self.recommendDataArray = dataArray;
        index = self.recommendDataArray.count-1;
    }
    [self updateRecommendUIAndScrollToIndex:index];
}


#pragma mark - MDFaceDecorationDownloaderDelegate

- (void)faceDecorationDownloaderStart:(id)sender
                     downloadWithItem:(MDFaceDecorationItem *)item
                                 type:(MDFaceDecorationDownloadType)type {
    item.isDownloading = YES;
    [self updateRecommendUI];
    [self updateDrawerUI];
}

- (void)faceDecorationDownloader:(id)sender
                downloadWithItem:(MDFaceDecorationItem *)item
                            type:(MDFaceDecorationDownloadType)type
                     downloadEnd:(BOOL)result {
    //这里不能直接使用这个item，需要重新去取
    NSDictionary *faceItems = [MDRecordContext faceDecorationManager].faceItems;
    MDFaceDecorationItem *faceItem = [faceItems objectForKey:item.identifier defaultValue:nil];

    faceItem.isDownloading = NO;
    faceItem.resourcePath = item.resourcePath;
    
    //清除下载来源记录
    MDFaceDecorationFromSource fromSource = [self.fromSourceDict integerForKey:faceItem.identifier defaultValue:0];
    if (faceItem.identifier) {  //TODO:yzk暂时不知道为什么会出现faceItem.identifier是nil的情况，稍后分析
        [self.fromSourceDict removeObjectForKey:faceItem.identifier];
    }
    
    
    if (result == NO) {
        [self updateDrawerUI];
        [self updateRecommendUI];

        if ([self.currentSelectItem.identifier isEqualToString:faceItem.identifier]) {
            //如果当前变脸推荐的选中变脸和下载失败的一样，代理回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidDownLoadFail:)]) {
                [self.delegate recommendFaceDecorationDidDownLoadFail:faceItem];
            }
        }
        return;
    }
    
    if ([self.currentSelectItem.identifier isEqualToString:faceItem.identifier]) {
        [self deselectAllItem];
        self.currentSelectItem.isSelected = YES;
        self.currentUseItem = self.currentSelectItem;

        //如果当前变脸推荐的选中变脸和下载好的一样，立即使用此变脸
        if (self.delegate && [self.delegate respondsToSelector:@selector(recommendFaceDecorationDidSelectedItem:)]) {
            [self.delegate recommendFaceDecorationDidSelectedItem:faceItem];
        }
    }
    
    [self appendItemForClassId:kFaceClassIndentifierOfMy withFaceID:faceItem.identifier];
    [self updateDrawerUIWithDataChange:YES];
    [self updateRecommendUI];
    
    //打点
    [self logWithFaceId:faceItem.identifier fromSource:fromSource beginDownload:NO];
}

#pragma mark - 通知更新UI

/**
 通知变脸推荐列表界面刷新，选中对应index的cell，
 
 @param selectIndex 需要滚动到的index，不需要滚动传NSNotFound
 @param needSelected 需要需要选中对应的index
 */
- (void)updateRecommendUI {
    [self updateRecommendUIAndScrollToIndex:NSNotFound];
}
- (void)updateRecommendUIAndScrollToIndex:(NSInteger)selectIndex {
    [self updateRecommendUIAndScrollToIndex:selectIndex needSelected:NO];
}
- (void)updateRecommendUIAndScrollToIndex:(NSInteger)selectIndex needSelected:(BOOL)needSelected {
    NSDictionary *userInfo = @{
                               @"selectIndex":@(selectIndex),
                               @"needSelected":@(needSelected),
                               };
    //发送通知,通知界面刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:MDFaceDecorationRecommendUpdateNotiName object:nil userInfo:userInfo];
}

/**
 通知变脸抽屉列表界面刷新
 */
- (void)updateDrawerUI {
    [self updateDrawerUIWithDataChange:NO];
}
- (void)updateDrawerUIWithDataChange:(BOOL)change {
    //发送通知,通知界面刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:MDFaceDecorationDrawerUpdateNotiName object:nil userInfo:@{@"change":@(change)}];
}

#pragma mark - 辅助方法

/**
 从给定字符串数组中随即选取一个字符串

 @param array 给定的随即范围
 @return 随即的字符串
 */
- (NSString *)randomStringWithArray:(NSArray<NSString *> *)array {
    NSInteger count = array.count;
    if (count == 0) {
        return nil;
    }
    
    return [array stringAtIndex:arc4random_uniform(count) defaultValue:nil];
}


/**
 打点统计
 
 @param faceId 变脸id
 @param fromSource 触发来源，是抽屉还是推荐栏
 @param beginDownload 开始下载还是结束下载
 */
- (void)logWithFaceId:(NSString *)faceId
           fromSource:(MDFaceDecorationFromSource)fromSource
        beginDownload:(BOOL)begin {
    //打点
    NSString *logString = nil;
    if (fromSource == MDFaceDecorationFromDrawer) {
        logString = [NSString stringWithFormat:@"camera_norface_download_%@_%@", begin?@"start":@"finish", faceId];
    }else if (fromSource == MDFaceDecorationFromRecommend) {
        logString = [NSString stringWithFormat:@"camera_recface_download_%@_%@", begin?@"start":@"finish", faceId];
    }
    if (logString) {
//        [MDActionManager handleLocaRecord:logString];
    }
}


- (NSMutableDictionary *)fromSourceDict {
    if (!_fromSourceDict) {
        _fromSourceDict = [NSMutableDictionary dictionary];
    }
    return _fromSourceDict;
}


@end
