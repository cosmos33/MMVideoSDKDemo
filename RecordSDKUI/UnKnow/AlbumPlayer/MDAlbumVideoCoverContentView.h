//
//  MDAlbumVideoCoverContentView.h
//  MomoChat
//
//  Created by Leery on 2018/9/13.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlbumVideoCoverContentViewHeight           (74)

@class MDPhotoItem;
typedef void(^AlbumVideoCoverSelectedBlock)(MDPhotoItem *photoItem);
@interface MDAlbumVideoCoverContentView : UIView

- (instancetype)initWithPhotoItems:(NSArray *)array;
- (void)updateAlbumVideoCoverContentViewWithArray:(NSArray *)array selectedItem:(MDPhotoItem *)photoItem;
- (void)albumVideoCoverSelectedItem:(AlbumVideoCoverSelectedBlock)block;

@end
