//
//  MDAlbumVideoImageSortingViewController.h
//  MomoChat
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordSDK/MDAlbumPlayerViewController.h"

@class MDAlbumVideoImageSortingViewController, MDMusicCollectionItem, MDPhotoItem;

@protocol MDAlbumVideoImageSortingViewControllerDelegate <NSObject>

- (void)didCompleteSortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc;
- (void)cancelSortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc;

- (void)sortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc sortedImages:(NSArray<MDPhotoItem *> * _Nullable)images;
- (void)sortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc musicItem:(MDMusicCollectionItem *)musicItem animationType:(NSString * _Nullable)animationType;
- (void)sortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc thumbImage:(MDPhotoItem * _Nullable)thumbImage;

@optional
- (void)sortingController:(MDAlbumVideoImageSortingViewController * _Nonnull)vc selectIndex:(NSInteger)index;

@end

@interface MDAlbumVideoImageSortingViewController : UIViewController

- (instancetype)initWithPlayerViewController:(MDAlbumPlayerViewController *)playerViewController;
- (void)showWithAnimatied:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)index;
- (void)updateImages:(NSArray<MDPhotoItem *> *)images animationType:(NSString *)animationType thumbImage:(MDPhotoItem *)thumbImage;

@property (nonatomic, copy) NSString *currentAnimationType;

@property (nonatomic, strong, nonnull) NSArray<MDPhotoItem *> *images;
@property (nonatomic, weak, nullable) id<MDAlbumVideoImageSortingViewControllerDelegate> delegate;
// 是否在封面页面
@property (nonatomic, readonly) BOOL isInThumbView;

@end
