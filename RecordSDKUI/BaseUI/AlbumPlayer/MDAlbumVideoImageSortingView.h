//
//  MDAlbumVideoImageSortingView.h
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDPhotoItem;

@interface MDAlbumVideoImageSortingView : UIView


- (void)updateImages:(NSArray<MDPhotoItem *> * _Nonnull)images;
- (void)updateImagesOnly:(NSArray<MDPhotoItem *> * _Nonnull)images;

@property (nonatomic, copy, nullable) void(^sorted)(NSArray<MDPhotoItem *> * _Nonnull images);

@property (nonatomic, copy, nullable) void(^deleteItem)(MDPhotoItem * _Nonnull image);

@end
