//
//  MDMusicEditPalletHandler.h
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class MDMusicCollectionItem,MDMusicBaseCollectionItem;

@protocol MDMusicEditPalletHandlerDelegate <NSObject>
- (void)collectionViewDidSelectItem:(MDMusicBaseCollectionItem *)baseItem indexPath:(NSIndexPath *)indexPath;
@end


@interface MDMusicEditPalletHandler : NSObject

- (void)bindCollectionView:(UICollectionView *)collectionView
                  delagate:(id<MDMusicEditPalletHandlerDelegate>)delegate;

- (void)updateCurrentMusicItem:(MDMusicCollectionItem *)musicItem;

@end

NS_ASSUME_NONNULL_END
