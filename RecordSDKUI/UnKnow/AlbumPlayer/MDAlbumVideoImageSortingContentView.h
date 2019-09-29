//
//  MDAlbumVideoImageSortingContentView.h
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDAlbumVideoImageSortingContentView, MDPhotoItem, MDMusicCollectionItem;

@protocol MDAlbumVideoImageSortingContentViewDelegate <NSObject>

- (void)contentView:(MDAlbumVideoImageSortingContentView *)view sortedImages:(NSArray<MDPhotoItem *> *)sortedImages;
- (void)contentView:(MDAlbumVideoImageSortingContentView *)view musicItem:(MDMusicCollectionItem *)musicItem animationType:(NSString *)animationType;
- (void)contentView:(MDAlbumVideoImageSortingContentView *)view thumImage:(MDPhotoItem *)thumbImage;

@optional
- (void)contentView:(MDAlbumVideoImageSortingContentView *)view selectIndex:(NSInteger)index;
- (void)contentView:(MDAlbumVideoImageSortingContentView *)view deleteItem:(MDPhotoItem *)photoItem;

@end

@interface MDAlbumVideoImageSortingContentView : UIView

@property (nonatomic, weak) id<MDAlbumVideoImageSortingContentViewDelegate> delegate;
@property (nonatomic, strong) NSArray<MDPhotoItem *> *images;
@property (nonatomic, copy) NSString *currentAnimationType;

- (void)setSelectedIndex:(NSInteger)index;
- (void)updateImages:(NSArray<MDPhotoItem *> *)images animationType:(NSString *)animationType thumbImage:(MDPhotoItem *)thumbImage;

@end
