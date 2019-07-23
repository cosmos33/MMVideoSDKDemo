//
//  MDFaceDecorationManager.m
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationManager.h"
#import "MDFaceDecorationItem.h"
#import "MDFaceDecorationFileHelper.h"
#import "SDWebImage/SDWebImagePrefetcher.h"
#import "MDDecorationTool.h"
#import "MDRecordHeader.h"
#import "MDPublicSwiftHeader.h"

#define kFaceDecorationConfigPath    [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Face_Decoration/faceDrawerConfig.plist"]

#define kFaceRecommendBarConfigPath    [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Face_Decoration/faceRecommendBarConfig.plist"]

@interface MDFaceDecorationManager ()

@property (nonatomic,strong) MDFaceDecorationDownloader *downloader;

@property (nonatomic,strong) NSDictionary *configForFaceDrawer;
@property (nonatomic,strong) NSDictionary *configForFaceRecommendBar;

@property (nonatomic,strong) NSDictionary<NSString *,MDFaceDecorationItem *> *faceItems;
@property (nonatomic,strong) NSArray<NSString *> *randomFaceIDs;
@property (nonatomic,strong) NSArray<NSString *> *recommendFaceIDS;

@property (nonatomic,strong) NSArray<MDFaceDecorationClassItem *>            *faceClassItems;
@property (nonatomic,strong) NSDictionary<NSString *,NSArray<NSString *> *>  *faceClassMaps;

@end

@implementation MDFaceDecorationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self requestFaceDecorationIfNeeded];
        [self loadConfig];
    }
    return self;
}

- (MDFaceDecorationDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [[MDFaceDecorationDownloader alloc] init];
        [_downloader bind:_delegate];
    }
    return _downloader;
}

- (void)setDelegate:(id<MDFaceDecorationManagerDelegate>)delegate
{
    if (!delegate) {
        [self.downloader releaseBind:_delegate];
    } else {
        [self.downloader bind:delegate];
    }
    
    _delegate = delegate;
}

- (void)loadConfig
{
    NSString *path = kFaceDecorationConfigPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if ([plist isKindOfClass:[NSDictionary class]]) {
            self.configForFaceDrawer = plist;
        }
    }
    [self cleanLocalCachaIfNeed];
    
    NSString *faceRecommendpath = kFaceRecommendBarConfigPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:faceRecommendpath]) {
        NSDictionary *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:faceRecommendpath];
        if ([plist isKindOfClass:[NSDictionary class]]) {
            self.configForFaceRecommendBar = plist;
        }
    }
    
    [self loadItems];
}

- (void)backupConfig:(NSDictionary *)config isForFaceDrawer:(BOOL)isForFaceDrawer
{
    NSString *path = [MDFaceDecorationFileHelper FaceDecorationBasePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([config isKindOfClass:[NSDictionary class]]) {
        NSString *path = isForFaceDrawer ? kFaceDecorationConfigPath : kFaceRecommendBarConfigPath;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:config];
        [data writeToFile:path atomically:YES];
    }
}

- (void)cleanLocalCachaIfNeed {
    BOOL needClean = NO;
    
    NSArray *classes = [self.configForFaceDrawer arrayForKey:@"class" defaultValue:nil];
    for (NSDictionary *dic in classes) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        MDFaceDecorationClassItem *classItem = [[MDFaceDecorationClassItem alloc] initWithDic:dic];
        if (![classItem.name isNotEmpty]) {
            needClean = YES;
            break;
        }
    }
    
    if (needClean) {
        self.configForFaceDrawer = nil;
    }
}

- (void)loadItems
{
    if (!self.configForFaceDrawer && !self.configForFaceRecommendBar) {
        return;
    }
    
    self.faceItems = [NSDictionary dictionary];
    self.randomFaceIDs = [NSArray array];
    self.recommendFaceIDS = [NSArray array];
    
    self.faceClassItems = [NSArray array];
    self.faceClassMaps = [NSDictionary dictionary];
    
    // 解析配置信息
    [self parseConfigForFaceDrawer];
    [self parseConfigForFaceRecommend];
}

#pragma mark - 解析变脸抽屉的配置数据
- (void)parseConfigForFaceDrawer
{
    NSArray *classes = [self.configForFaceDrawer arrayForKey:@"class" defaultValue:nil];
    [self parseClasses:classes];
    
    NSDictionary *itemsDic = [self.configForFaceDrawer dictionaryForKey:@"items" defaultValue:nil];
    [self parseItemsForFaceDrawer:itemsDic];
}

- (void)parseClasses:(NSArray *)classes
{
    if (![self existMyFaceClass]) {
        self.configForFaceDrawer = [self newDictAfterInsertMyClassNodeWithDict:self.configForFaceDrawer];
        classes = [self.configForFaceDrawer arrayForKey:@"class" defaultValue:nil];
    }
    
    NSMutableArray *tempFaceClassItems = [NSMutableArray array];
    for (NSDictionary *dic in classes) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        MDFaceDecorationClassItem *classItem = [[MDFaceDecorationClassItem alloc] initWithDic:dic];
        if ([classItem.identifier isEqualToString:kFaceClassIndentifierOfMy]) {
            [tempFaceClassItems insertObject:classItem atIndex:0];
        } else {
            [tempFaceClassItems addObjectSafe:classItem];
        }
    }
    
    self.faceClassItems = tempFaceClassItems;
}

- (void)parseItemsForFaceDrawer:(NSDictionary *)dataDict
{
    NSMutableDictionary *tempFaceClassMap = [[NSMutableDictionary alloc] initWithDictionary:self.faceClassMaps];
    NSMutableDictionary *tempFaceItems = [[NSMutableDictionary alloc] initWithDictionary:self.faceItems];
    
    for (MDFaceDecorationClassItem *classItem in self.faceClassItems) {
        
        NSArray *itemsDict = [dataDict arrayForKey:classItem.identifier defaultValue:nil];
        NSMutableArray *faceIDsOfAFaceClass = [NSMutableArray arrayWithCapacity:itemsDict.count];
        
        for (NSDictionary *aItemDict in itemsDict) {
            if (![aItemDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            MDFaceDecorationItem *faceDecorationItem = [[MDFaceDecorationItem alloc] initWithDic:aItemDict];
            [faceIDsOfAFaceClass addObjectSafe:faceDecorationItem.identifier];
            [tempFaceItems setObjectSafe:faceDecorationItem forKey:faceDecorationItem.identifier];
        }
        
        [tempFaceClassMap setObjectSafe:faceIDsOfAFaceClass forKey:classItem.identifier];
    }
    
    self.faceClassMaps = tempFaceClassMap;
    self.faceItems = tempFaceItems;
}

#pragma mark - 解析变脸推荐栏的配置数据
- (void)parseConfigForFaceRecommend
{
    NSMutableDictionary *tempFaceItems = [NSMutableDictionary dictionaryWithDictionary:self.faceItems];
    
    //解析2号位变脸资源
    NSArray *randomFaceDicts = [self.configForFaceRecommendBar arrayForKey:@"second_pos" defaultValue:nil];
    NSMutableArray *tempRandomFaceIDs = [NSMutableArray arrayWithCapacity:randomFaceDicts.count];
    for (NSDictionary *aFaceDict in randomFaceDicts) {
        if ([aFaceDict isKindOfClass:[NSDictionary class]]) {
            MDFaceDecorationItem *item = [[MDFaceDecorationItem alloc] initWithDic:aFaceDict];
            [tempRandomFaceIDs addObjectSafe:item.identifier];
            
            if (![self.faceItems.allKeys containsObject:item.identifier]) {
                [tempFaceItems setObjectSafe:item forKey:item.identifier];
            }
        }
    }
    self.randomFaceIDs = tempRandomFaceIDs;
    
    //解析3~N号位变脸资源
    NSArray *recommendFaceDicts = [self.configForFaceRecommendBar arrayForKey:@"last" defaultValue:nil];
    NSMutableArray *tempRecommendFaceIDs = [NSMutableArray arrayWithCapacity:recommendFaceDicts.count];
    for (NSDictionary *aFaceDict in recommendFaceDicts) {
        if ([aFaceDict isKindOfClass:[NSDictionary class]]) {
            MDFaceDecorationItem *item = [[MDFaceDecorationItem alloc] initWithDic:aFaceDict];
            [tempRecommendFaceIDs addObjectSafe:item.identifier];
            
            if (![self.faceItems.allKeys containsObject:item.identifier]) {
                [tempFaceItems setObjectSafe:item forKey:item.identifier];
            }
        }
    }
    self.recommendFaceIDS = tempRecommendFaceIDs;
    
    self.faceItems = tempFaceItems;
}

- (MDFaceDecorationItem *)faceItemWithId:(NSString *)faceIdentifier
{
    return [self.faceItems objectForKey:faceIdentifier defaultValue:nil];
}

#pragma mark - 请求变脸资源
// 读本地的
- (void)requestLocalFaceDecoration
{
    [self loadItems];
    
    //从新设置下载状态
    [self.faceItems enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MDFaceDecorationItem * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.isDownloading = [self.downloader isDownloadingItem:obj];
    }];
}

//请求变脸抽屉的数据
- (void)requestFaceDecorationIfNeeded
{
    //版本号不对或者本地没有数据的时候都应该拉取数据
    if ([self getLocalVersionFromFaceDrawer:YES] != [self getAppConfigVersionFromFaceDrawer:YES] ||
        ([self.faceItems count] == 0)) {
        
        [FaceDecorationLoader loadFaceDecorationWithCallback:^(NSString * json, NSError * error) {
            if (json && !error) {
                [self requestFaceDecorationOk:json];
            }
        }];
    }
}

- (void)requestFaceDecorationOk:(NSString *)json
{
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];

    if (!dataDic) {
        return;
    }
    
    if (self.configForFaceDrawer) {
        NSMutableDictionary *tempFaceItems = [NSMutableDictionary dictionaryWithDictionary:self.faceItems];
        NSDictionary *items = [dataDic dictionaryForKey:@"items" defaultValue:nil];
        
        for (NSString *itemKey in items.allKeys) {
            
            NSArray* arr = [items arrayForKey:itemKey defaultValue:nil];
            for (NSDictionary* itemDic in arr) {
                [self removeOldVersionLocalItemFilesWithDictionary:itemDic];
                NSString *identifier    = [itemDic stringForKey:@"id" defaultValue:@""];
                [tempFaceItems removeObjectForKey:identifier];
            }
        }
        
        //删除服务器已经下架的变脸资源，取消下载中的操作
        [self cancelDownLoadingAndRemoveLocalItemWithFaceItems:tempFaceItems];
        
        //从我的分类里删除服务器已经下架的变脸资源
        [self removeFacesOfMyClassWithFaceItems:tempFaceItems];
    }
    
    // 二级缓存
    if ([self existMyFaceClass]) {
        //先保存我的分类下的变脸资源
        NSMutableDictionary *tempItemsDict = [NSMutableDictionary dictionaryWithDictionary:[self.configForFaceDrawer dictionaryForKey:@"items" defaultValue:nil]];
        NSArray *faceItemDictsOfMyClass = [tempItemsDict arrayForKey:kFaceClassIndentifierOfMy defaultValue:nil];
        
        dataDic = [self newDictAfterInsertMyClassNodeWithDict:dataDic];
        dataDic = [self newDictAfterInsertMyClassItemDictArray:faceItemDictsOfMyClass sourceDict:dataDic];
        
        self.configForFaceDrawer = dataDic;
        
    } else {
        self.configForFaceDrawer = dataDic;
    }
    
    [self backupConfig:self.configForFaceDrawer isForFaceDrawer:YES];
}

- (void)removeOldVersionLocalItemFilesWithDictionary:(NSDictionary *)itemDic
{
    if(![itemDic isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    NSString *identifier    = [itemDic stringForKey:@"id" defaultValue:nil];
    NSInteger serverVersion = [itemDic integerForKey:@"version" defaultValue:0];
    MDFaceDecorationItem *localItem = [self.faceItems objectForKey:identifier defaultValue:nil];
    if (localItem.version) {//删除旧数据
        if (localItem.version != serverVersion) {
            // 删掉path下的两个文件
            [MDFaceDecorationFileHelper removeAllComponentWithItem:localItem];
            //如果正在下载，取消下载
            [_downloader cancelDownloadingItem:localItem];
        }
    }
}

- (void)cancelDownLoadingAndRemoveLocalItemWithFaceItems:(NSDictionary *)faceItems
{
    for (NSString *key in faceItems.allKeys) {
        MDFaceDecorationItem *item = [faceItems objectForKey:key defaultValue:nil];
        [MDFaceDecorationFileHelper removeAllComponentWithItem:item];
        //如果正在下载，取消下载
        [_downloader cancelDownloadingItem:item];
    }
}

- (void)removeFacesOfMyClassWithFaceItems:(NSDictionary *)faceItems
{
    NSArray *faceIDsOfMyFaceClass = [self.faceClassMaps arrayForKey:kFaceClassIndentifierOfMy defaultValue:nil];
    NSMutableDictionary *tempConfigForFaceDrawer = [NSMutableDictionary dictionaryWithDictionary:self.configForFaceDrawer];
    
    if (faceIDsOfMyFaceClass.count > 0) {
        
        NSMutableDictionary *tempItemsDict = [NSMutableDictionary dictionaryWithDictionary:[self.configForFaceDrawer dictionaryForKey:@"items" defaultValue:nil]];
        NSArray *myFaceItemDicts = [tempItemsDict arrayForKey:kFaceClassIndentifierOfMy defaultValue:nil];
        NSMutableArray *tempMyFaceItemDicts = [NSMutableArray arrayWithArray:myFaceItemDicts];
        
        NSMutableArray *deleteFaceItems = [NSMutableArray array];
        
        for (NSString *faceID in faceItems.allKeys) {
            for (NSDictionary *faceItemDict in tempMyFaceItemDicts) {
                NSString *oldFaceID = [faceItemDict stringForKey:@"id" defaultValue:nil];
                if ([faceID isEqualToString:oldFaceID]) {
                    [deleteFaceItems addObjectSafe:faceItemDict];
                }
            }
        }
        
        [tempMyFaceItemDicts removeObjectsInArray:deleteFaceItems];
        [tempItemsDict setObjectSafe:tempMyFaceItemDicts forKey:kFaceClassIndentifierOfMy];
        [tempConfigForFaceDrawer setObjectSafe:tempItemsDict forKey:@"items"];
        
        self.configForFaceDrawer = tempConfigForFaceDrawer;
    }
}

#pragma mark - download a faceItem
- (void)downloadItem:(MDFaceDecorationItem *)item withType:(MDFaceDecorationDownloadType)type
{
    //如果重新下载，先删除本地资源
    if (type == MDFaceDecorationDownloadType_Zip) {
        [MDFaceDecorationFileHelper removeResourceWithItem:item];
        item.resourcePath = nil;
    }
    
    [self.downloader downloadItem:item withType:type];
}

- (void)downloadPreLoadFaceItem:(NSString *)faceId classId:(NSString *)classId faceZipUrlStr:(NSString *)zipUrlStr {
    
    if([faceId isNotEmpty]) {
        MDFaceDecorationItem *faceItem =[[MDRecordContext faceDecorationManager] faceItemWithId:faceId];
        
        if ([faceItem.identifier isNotEmpty]) {
            
            if ([zipUrlStr isNotEmpty]) {    //如果服务器有下发资源路径，则需要比对路径
                
                if (![faceItem.zipUrlStr isEqualToString:zipUrlStr]) {
                    [[MDRecordContext faceDecorationManager] downloadItem:faceItem withType:MDFaceDecorationDownloadType_Zip];
                    
                } else if (![faceItem.resourcePath isNotEmpty]) {
                    [[MDRecordContext faceDecorationManager] downloadItem:faceItem withType:MDFaceDecorationDownloadType_Zip];
                }
                
                faceItem.zipUrlStr = zipUrlStr;
                
            } else {                         //如果服务器没有下发资源路径，直接判断本地资源有没有（可能取不到最新的变脸资源）
                if(![faceItem.resourcePath isNotEmpty]) {
                    [[MDRecordContext faceDecorationManager] downloadItem:faceItem withType:MDFaceDecorationDownloadType_Zip];
                }
            }
            
        }
    }
}

- (void)checkNeedPreDownloadFaceItem:(NSDictionary *)itemDic
{
    if (itemDic.count > 0) {
        MDFaceDecorationItem *item = [[MDFaceDecorationItem alloc] initWithDic:itemDic];
        
        if (![item.resourcePath isNotEmpty]) {
            [self downloadItem:item withType:MDFaceDecorationDownloadType_Zip];
        }
    }
}
#pragma mark - 辅助方法
//往某个变脸分类里追加数据
- (void)appendAFaceItemForClassId:(NSString *)faceClassId withFaceID:(NSString *)faceID needRemove:(BOOL)needRemove
{
    if ([faceClassId isNotEmpty] && [faceID isNotEmpty]) {
        
        NSArray *faceIDsOfAFaceClass = [self.faceClassMaps arrayForKey:faceClassId defaultValue:nil];
        if ([faceIDsOfAFaceClass containsObject:faceID]) {
            return;
        }
        
        if (![self existMyFaceClass]) {
            self.configForFaceDrawer = [self newDictAfterInsertMyClassNodeWithDict:self.configForFaceDrawer];
        }
        
        //往config里添加对应的字典数据
        NSMutableDictionary *tempItemsDict = [[NSMutableDictionary alloc] initWithDictionary:[self.configForFaceDrawer dictionaryForKey:@"items" defaultValue:nil]];
        NSArray *myFaceItemDicts = [tempItemsDict arrayForKey:faceClassId defaultValue:nil];
        NSMutableArray *tempMyFaceItemDicts = [NSMutableArray arrayWithArray:myFaceItemDicts];
        
        MDFaceDecorationItem *aFaceItem = [self.faceItems objectForKey:faceID];
        NSDictionary *aFaceItemDict = [aFaceItem dicWithFaceDecorationItem:aFaceItem];
        [tempMyFaceItemDicts insertObject:aFaceItemDict atIndex:0];
        //淘汰旧数据
        if (needRemove) {
            [tempMyFaceItemDicts removeLastObject];
        }
        
        self.configForFaceDrawer = [self newDictAfterInsertMyClassItemDictArray:tempMyFaceItemDicts sourceDict:self.configForFaceDrawer];
        [self backupConfig:self.configForFaceDrawer isForFaceDrawer:YES];
        
        //数据源更新
        NSMutableDictionary *tempFaceClassMaps = [NSMutableDictionary dictionaryWithDictionary:self.faceClassMaps];
        NSMutableArray *tempFaceIDsOfAFaceClass = [NSMutableArray arrayWithArray:faceIDsOfAFaceClass];
        
        [tempFaceIDsOfAFaceClass insertObject:faceID atIndex:0];
        //淘汰旧数据
        if (needRemove) {
            [tempFaceIDsOfAFaceClass removeLastObject];
        }
        faceIDsOfAFaceClass = tempFaceIDsOfAFaceClass;
        
        [tempFaceClassMaps setObjectSafe:tempFaceIDsOfAFaceClass forKey:faceClassId];
        self.faceClassMaps = tempFaceClassMaps;
        
    }
}

- (BOOL)existMyFaceClass
{
    BOOL exist = NO;
    
    NSArray *classes = [self.configForFaceDrawer arrayForKey:@"class" defaultValue:nil];
    for (NSDictionary *dic in classes) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString *identifier = [dic stringForKey:@"id" defaultValue:nil];
        if ([identifier isEqualToString:kFaceClassIndentifierOfMy]) {
            exist = YES;
            break;
        }
    }
    
    return exist;
}

//class 节点下追加我的分类
- (NSDictionary *)newDictAfterInsertMyClassNodeWithDict:(NSDictionary *)sourceDict
{
    NSArray *classes = [sourceDict arrayForKey:@"class" defaultValue:nil];
    
    MDFaceDecorationClassItem *myClassItem = [[MDFaceDecorationClassItem alloc] init];
    myClassItem.identifier = kFaceClassIndentifierOfMy;
    myClassItem.name = @"我的";
    myClassItem.imgUrlStr = @"moment_record_my_class";
    myClassItem.selectedImgUrlStr = @"moment_record_my_class_selected";
    
    NSDictionary *myClassDict = [myClassItem dicWithFaceClassItem:myClassItem];
    
    NSMutableArray *faceClassDicts = [NSMutableArray arrayWithArray:classes];
    [faceClassDicts addObjectSafe:myClassDict];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:sourceDict];
    [tempDict setObjectSafe:faceClassDicts forKey:@"class"];
    
    return tempDict;
}

//items 节点下追加我的分类和对应的items的映射
- (NSDictionary *)newDictAfterInsertMyClassItemDictArray:(NSArray *)itemDictArray sourceDict:(NSDictionary *)sourceDict
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:sourceDict];
    
    NSMutableDictionary *tempItemsDict = [NSMutableDictionary dictionaryWithDictionary:[sourceDict dictionaryForKey:@"items" defaultValue:nil]];
    [tempItemsDict setObjectSafe:itemDictArray forKey:kFaceClassIndentifierOfMy];
    
    [tempDict setObjectSafe:tempItemsDict forKey:@"items"];
    
    return tempDict;
}

//变脸抽屉的version
- (NSInteger)getLocalVersionFromFaceDrawer:(BOOL)isFromFaceDrawer
{
    NSInteger version = 0;
    
    if (isFromFaceDrawer) {
        version = [self.configForFaceDrawer integerForKey:@"version" defaultValue:0];
    } else {
        version = [self.configForFaceRecommendBar integerForKey:@"version" defaultValue:0];
    }
    
    return version;
    
}

#warning sunfei
- (NSInteger)getAppConfigVersionFromFaceDrawer:(BOOL)isFromFaceDrawer
{
    NSInteger version = 0;
    
    if (isFromFaceDrawer) {
//        version = [[MDContext appConfig] momentFaceDecorationResourceVersion];
    } else {
//        version = [[MDContext appConfig] recommendFaceDecorationResourceVersion];
    }
    
    return version;
}

@end
