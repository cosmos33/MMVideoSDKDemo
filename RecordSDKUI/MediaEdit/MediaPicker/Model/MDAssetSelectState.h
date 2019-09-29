//
//  MDAssetSelectState.h
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPhotoLibraryProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class MDAssetStateModel;
@interface MDAssetSelectState : NSObject

@property (nonatomic, assign) NSInteger albumIndex; //当前相册的索引
@property (nonatomic, assign) NSInteger  selectionLimit;//总共允许选的张数
@property (nonatomic, readonly) NSInteger selectedCount;//当前已选
@property (nonatomic, strong, readonly) NSArray<MDAssetStateModel*> *selectedArray;
@property (nonatomic, strong, readonly) NSArray<MDPhotoItem*> *selectedItemArray;

- (void)cleanAll;
- (void)changeSelectState:(BOOL)selected forAsset:(MDPhotoItem *)asset indexPath:(NSIndexPath *)indexPath;
- (NSArray<NSIndexPath*> *)updateAssetSelectIndex;
- (NSInteger)indexOfSelectAssetItem:(MDPhotoItem *)assetItem;

@end


@interface MDAssetStateModel : NSObject

@property (nonatomic, strong) MDPhotoItem *assetItem;
@property (nonatomic, strong) NSString *key;

- (instancetype)initWithAssetItem:(MDPhotoItem *)assetItem key:(NSString *)key;
- (NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
