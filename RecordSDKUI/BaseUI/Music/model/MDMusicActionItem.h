//
//  MDMusicActionItem.h
//  MDChat
//
//  Created by YZK on 2018/11/19.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MDMusicActionType) {
    MDMusicActionTypeUpload = 1,
    MDMusicActionTypeRecommend,
};


@interface MDMusicActionItem : MDMusicBaseCollectionItem

@property (nonatomic ,strong) NSString          *iconString;
@property (nonatomic ,strong) NSString          *title;
@property (nonatomic ,strong) NSString          *subTitle;
@property (nonatomic ,assign) MDMusicActionType type;

+ (instancetype)uploadActionItem;
+ (instancetype)recommendActionItem;

@end

NS_ASSUME_NONNULL_END
