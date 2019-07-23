//
//  MDMusicCurrentPlayView.h
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMusicBVO.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDMusicCurrentPlayViewDelegate <NSObject>
@optional
- (void)currentPlayViewDidCancel;
@end

@interface MDMusicCurrentPlayView : UIView

@property (nonatomic, strong, readonly) MDMusicBVO *item;
@property (nonatomic, weak) id<MDMusicCurrentPlayViewDelegate> delegate;

- (void)bindModel:(MDMusicBVO *)item;

@end

NS_ASSUME_NONNULL_END
