//
//  MDFaceDecorationManager.h
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDFaceDecorationDownloader.h"
#import "MDRecordMacro.h"
@class MDFaceDecorationItem;
@class MDFaceDecorationClassItem;

//待优化：目前不同业务后台是独立的，造成同样的变脸资源，在不同业务场景下不同，后台优化后可以统一管理变脸资源

@protocol MDFaceDecorationManagerDelegate <MDFaceDecorationDownloaderDelegate>
@optional
- (void)faceDecorationManager:(id)sender  requestFaceDecorationFinished:(NSArray *)classes items:(NSArray *)items itemMap:(NSDictionary*)itemMap;

@end

// 人脸装饰资源管理
@interface MDFaceDecorationManager : NSObject

@property (nonatomic, weak) id <MDFaceDecorationManagerDelegate> delegate;

@property (nonatomic,strong,readonly) NSDictionary<NSString *,MDFaceDecorationItem *> *faceItems;
@property (nonatomic,strong,readonly) NSArray<NSString *> *randomFaceIDs;
@property (nonatomic,strong,readonly) NSArray<NSString *> *recommendFaceIDS;

@property (nonatomic,strong,readonly) NSArray<MDFaceDecorationClassItem *>            *faceClassItems;
@property (nonatomic,strong,readonly) NSDictionary<NSString *,NSArray<NSString *> *>  *faceClassMaps; //key为分类id，value为包含变脸id的数组

//请求本地列表
- (void)requestLocalFaceDecoration;
//向服务器请求抽屉里的变脸资源
- (void)requestFaceDecorationIfNeeded;

- (void)downloadItem:(MDFaceDecorationItem *)item withType:(MDFaceDecorationDownloadType)type;
- (MDFaceDecorationItem *)faceItemWithId:(NSString *)faceIdentifier;
- (void)downloadPreLoadFaceItem:(NSString *)faceId classId:(NSString *)classId faceZipUrlStr:(NSString *)zipUrlStr;

- (void)checkNeedPreDownloadFaceItem:(NSDictionary *)itemDic;

//往某个变脸分类里追加数据
- (void)appendAFaceItemForClassId:(NSString *)faceClassId withFaceID:(NSString *)faceID needRemove:(BOOL)needRemove;

@end
