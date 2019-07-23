//
//  MDMusicFavouriteManager.h
//  MDChat
//
//  Created by YZK on 2018/11/15.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kMusicMyFavouriteCategoryID;

NS_ASSUME_NONNULL_BEGIN

@class MDMusicCollectionItem;
@interface MDMusicFavouriteManager : NSObject

+ (instancetype)getCurrentFavouriteManager;
+ (void)strongSelf;
+ (void)weakSelf;

- (void)getAllFavouriteItemsCompletion:(void (^)(NSArray<MDMusicCollectionItem*> *dataSource))completion;
- (NSArray *)insertMusicItemToFavourite:(MDMusicCollectionItem *)item;
- (void)removeMusicFromFavouriteWithMusicId:(NSString *)musicId;
- (BOOL)isInMusicFavouriteWithMusicId:(NSString *)musicId;

@end

NS_ASSUME_NONNULL_END
