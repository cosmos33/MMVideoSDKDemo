//
//  MDMusicBaseCollectionItem.h
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicBaseCollectionItem : NSObject

@property (nonatomic, assign) CGSize cellSize;
- (Class)cellClass;

@end

NS_ASSUME_NONNULL_END
