//
//  MDAssetSelectState.m
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetSelectState.h"
#import "MDRecordHeader.h"

@interface MDAssetSelectState ()
@property (nonatomic, strong) NSMutableArray<MDAssetStateModel*> *selectedAssetArray;
@property (nonatomic, readwrite) NSInteger selectedCount;
@end

@implementation MDAssetSelectState

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedAssetArray = [NSMutableArray array];
    }
    return self;
}

- (void)changeSelectState:(BOOL)selected forAsset:(MDPhotoItem *)asset indexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%d_%d_%d", (int)self.albumIndex, (int)indexPath.section, (int)indexPath.row];
    MDAssetStateModel *model = [[MDAssetStateModel alloc] initWithAssetItem:asset key:key];
    if (selected) {
        [self.selectedAssetArray addObjectSafe:model];
    } else {
        [self.selectedAssetArray removeObject:model];
    }
    self.selectedCount = self.selectedAssetArray.count;
}

- (NSArray<NSIndexPath*> *)updateAssetSelectIndex {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (MDAssetStateModel *model in self.selectedAssetArray) {
        NSString *key = model.key;
        NSArray *indexArray = [key componentsSeparatedByString:@"_"];
        NSInteger modelAlbumIndex = [indexArray integerAtIndex:0 defaultValue:-1];
        if (self.albumIndex == modelAlbumIndex) {
            NSInteger section = [indexArray integerAtIndex:1 defaultValue:-1];
            NSInteger row = [indexArray integerAtIndex:2 defaultValue:-1];
            model.assetItem.idxNumber = resultArray.count+1;
            [resultArray addObjectSafe:[NSIndexPath indexPathForRow:row inSection:section]];
        } else {
            [resultArray addObjectSafe:[NSIndexPath indexPathForRow:-1 inSection:-1]];
        }
    }
    return resultArray;
}

- (void)cleanAll {
    [self.selectedAssetArray removeAllObjects];
    self.selectedCount = 0;
}

- (NSArray<MDAssetStateModel *> *)selectedArray {
    return [self.selectedAssetArray copy];
}

- (NSInteger)indexOfSelectAssetItem:(MDPhotoItem *)assetItem {
    NSArray *arr = self.selectedArray;
    for (int i=0; i<arr.count; i++) {
        MDAssetStateModel *model = arr[i];
        if (model.assetItem == assetItem) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSArray<MDPhotoItem*> *)selectedItemArray {
    NSMutableArray *itemArray = [NSMutableArray array];
    for (MDAssetStateModel *model in self.selectedArray) {
        [itemArray addObjectSafe:model.assetItem];
    }
    return itemArray;
}

@end


@implementation MDAssetStateModel

- (instancetype)initWithAssetItem:(MDPhotoItem *)assetItem key:(NSString *)key {
    self = [super init];
    if (self) {
        self.assetItem = assetItem;
        self.key = key;
    }
    return self;
}

- (NSIndexPath *)indexPath {
    NSArray *indexArray = [self.key componentsSeparatedByString:@"_"];
    NSInteger section = [indexArray integerAtIndex:1 defaultValue:-1];
    NSInteger row = [indexArray integerAtIndex:2 defaultValue:-1];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[MDAssetStateModel class]]) {
        return NO;
    }
    
    return [self isEqualToStateModel:object];
}

- (BOOL)isEqualToStateModel:(MDAssetStateModel *)other {
    BOOL keyIsEqual = (self.key == other.key || [self.key isEqual:other.key]);
    return keyIsEqual;
}

@end
