//
//  MDMusicFavouriteManager.m
//  MDChat
//
//  Created by YZK on 2018/11/15.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicFavouriteManager.h"
#import "MDMusicCollectionItem.h"
#import "MDMusicEditCardItem.h"
#import "MDRecordHeader.h"

#define kMusicMyFavouriteCachePath    [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/VideoBackgroundMusic/Favourite"]

NSString * const kMusicMyFavouriteCategoryID = @"kMusicMyFavouriteCategoryID";

@interface MDMusicFavouriteManager ()
@property (nonatomic,strong) NSDictionary *cacheDict;
@property (nonatomic,strong) NSSet *musicSet;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger strongCount;
@end


@implementation MDMusicFavouriteManager

static MDMusicFavouriteManager *_manager = nil;
+ (instancetype)getCurrentFavouriteManager {
    if (!_manager) {
        _manager = [[MDMusicFavouriteManager alloc] init];
    }
    return _manager;
}

+ (void)strongSelf {
    _manager.strongCount++;
}
+ (void)weakSelf {
    _manager.strongCount--;
    if (_manager.strongCount <= 0) {
        [self deallocCurrentFavouriteManager];
    }
}

+ (void)deallocCurrentFavouriteManager {
    if (_manager) {
        NSString *path = [kMusicMyFavouriteCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",MDRecordContext.recordSDKUIVersion]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_manager.cacheDict];
        [data writeToFile:path atomically:YES];
    }
    _manager = nil;
}

- (void)getAllFavouriteItemsCompletion:(void (^)(NSArray<MDMusicCollectionItem*> *dataSource))completion {
    if (completion) completion([self.dataSource copy]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:kMusicMyFavouriteCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kMusicMyFavouriteCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self loadAllFavouriteItems];
    }
    return self;
}

- (void)loadAllFavouriteItems {
    NSString *path = [kMusicMyFavouriteCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",MDRecordContext.recordSDKUIVersion]];
    NSDictionary *cacheDict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if ([plist isKindOfClass:[NSDictionary class]]) {
            cacheDict = plist;
        }
    }
    self.cacheDict = cacheDict;
    
    NSMutableArray *mutaDataSource = [NSMutableArray array];
    NSMutableSet *mutaSet = [NSMutableSet set];
    NSArray *allFavouriteDictArray = [cacheDict arrayForKey:@"list" defaultValue:nil];
    for (NSDictionary *dict in allFavouriteDictArray) {
        MDMusicCollectionItem *musicItem = [MDMusicCollectionItem converToMusicItemWithDictionary:dict];
        if (musicItem.isLocal) {
            if (![musicItem.resourceUrl checkResourceIsReachableAndReturnError:nil]) {
                continue;
            }
        }
        [mutaDataSource addObjectSafe:musicItem];
        [mutaSet addObjectSafe:musicItem.musicVo.musicID];
    }
    self.musicSet = [mutaSet copy];
    self.dataSource = [mutaDataSource copy];
}

- (NSArray *)insertMusicItemToFavourite:(MDMusicCollectionItem *)item {
    if (!item) {
        return @[];
    }
    if ([item isKindOfClass:[MDMusicEditCardItem class]]) {
        item = [MDMusicEditCardItem collectionItemWithItem:(MDMusicEditCardItem *)item];
    }
    if(![item.musicVo.categoryID isEqualToString:kMusicMyFavouriteCategoryID]) {
        item = [item favouriteCopyItem];
    }
    
    NSMutableSet *mutaSet = [NSMutableSet setWithSet:self.musicSet?:[NSSet set]];
    if (![mutaSet containsObject:item.musicVo.musicID]) {
        NSArray *allFavouriteDictArray = [self.cacheDict arrayForKey:@"list" defaultValue:nil];
        
        NSMutableArray *mFavouriteDictArray = [NSMutableArray arrayWithArray:allFavouriteDictArray];
        [mFavouriteDictArray insertObject:[MDMusicCollectionItem converToDictionaryWithMusicItem:item] atIndexInBoundary:0];
        
        NSMutableArray *mutaDataSource = [NSMutableArray arrayWithArray:self.dataSource];
        [mutaDataSource insertObject:item atIndexInBoundary:0];
        
        [mutaSet addObjectSafe:item.musicVo.musicID];
        if (mFavouriteDictArray.count>100) {
            [mFavouriteDictArray removeLastObject];
            MDMusicCollectionItem *lastItem = [mutaDataSource lastObject];
            [mutaDataSource removeLastObject];
            [mutaSet removeObject:lastItem.musicVo.musicID];
        }
        self.dataSource = [mutaDataSource copy];
        self.musicSet = [mutaSet copy];
        
        self.cacheDict = @{@"list" : mFavouriteDictArray};
    }
    return self.dataSource;
}

- (void)removeMusicFromFavouriteWithMusicId:(NSString *)musicId {
    NSMutableSet *mutaSet = [NSMutableSet setWithSet:self.musicSet];
    if ([mutaSet containsObject:musicId]) {
        NSArray *allFavouriteDictArray = [self.cacheDict arrayForKey:@"list" defaultValue:nil];
        
        NSMutableArray *mFavouriteDictArray = [NSMutableArray arrayWithArray:allFavouriteDictArray];
        for (NSDictionary *dict in mFavouriteDictArray) {
            NSString *aMusicId = [dict stringForKey:@"music_id" defaultValue:nil];
            if ([aMusicId isEqualToString:musicId]) {
                [mFavouriteDictArray removeObject:dict];
                break;
            }
        }
        
        NSMutableArray *mutaDataSource = [NSMutableArray arrayWithArray:self.dataSource];
        for (MDMusicCollectionItem *item in mutaDataSource) {
            if ([item.musicVo.musicID isEqualToString:musicId]) {
                [mutaDataSource removeObject:item];
                break;
            }
        }
        
        [mutaSet removeObject:musicId];
        
        self.dataSource = [mutaDataSource copy];
        self.musicSet = [mutaSet copy];
        self.cacheDict = @{@"list" : mFavouriteDictArray};
    }
}

- (BOOL)isInMusicFavouriteWithMusicId:(NSString *)musicId {
    NSMutableSet *mutaSet = [NSMutableSet setWithSet:self.musicSet];
    if ([mutaSet containsObject:musicId]) {
        return YES;
    }
    return NO;
}

@end
