//
//  MDAlbumAssetLibrary.m
//  MDChat
//
//  Created by YZK on 2018/12/4.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAlbumAssetLibrary.h"

@implementation MDAlbumAssetLibrary

+ (PHFetchResult *)fetchAllAssets {
    return [self fetchAllAssetsWithOption:nil];
}

+ (PHFetchResult *)fetchAllAssetsWithOption:(PHFetchOptions *)option {
    if (@available(iOS 12.0, *)) {
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHAssetCollection *collection = smartAlbums.firstObject;
        PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        return assetsFetchResults;
    }else {
        @try {
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:option];
            return assetsFetchResults;
        } @catch (NSException *exception) {
            return nil;
        } @finally {
        }
    }
}

@end
