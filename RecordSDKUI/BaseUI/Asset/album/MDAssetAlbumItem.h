//
//  MDAssetAlbumItem.h
//  MDChat
//
//  Created by YZK on 2018/10/26.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetAlbumItem : NSObject

@property (nonatomic, copy  ) NSString          *name;
@property (nonatomic, strong) UIImage           *image;
@property (nonatomic, assign) NSInteger         count;
@property (nonatomic, strong) PHAsset           *firstAsset;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

NS_ASSUME_NONNULL_END
