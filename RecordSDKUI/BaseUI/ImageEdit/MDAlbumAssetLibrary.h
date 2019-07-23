//
//  MDAlbumAssetLibrary.h
//  MDChat
//
//  Created by YZK on 2018/12/4.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface MDAlbumAssetLibrary : NSObject

+ (PHFetchResult *)fetchAllAssets;
+ (PHFetchResult *)fetchAllAssetsWithOption:(nullable PHFetchOptions *)option;

@end

NS_ASSUME_NONNULL_END
