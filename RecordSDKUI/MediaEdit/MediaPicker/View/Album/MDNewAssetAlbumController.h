//
//  MDNewAssetAlbumController.h
//  MDChat
//
//  Created by YZK on 2018/10/26.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDAssetAlbumItem.h"
#import "MDUnifiedRecordSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDNewAssetAlbumControllerDelegate <NSObject>

- (void)didPickerAlbumCompleteWithItem:(nullable MDAssetAlbumItem *)item index:(NSInteger)index;

@end



@interface MDNewAssetAlbumController : UIViewController

@property (nonatomic, weak) id<MDNewAssetAlbumControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat topHeihgt;
@property (nonatomic, assign) MDAssetMediaType      mediaType;

- (void)showWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
