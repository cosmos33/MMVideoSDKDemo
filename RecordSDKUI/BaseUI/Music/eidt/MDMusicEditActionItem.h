//
//  MDMusicEditActionItem.h
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionItem.h"
#import "MDRecordHeader.h"

typedef NS_ENUM(NSInteger, MDMusicEditActionType) {
    MDMusicEditActionTypeLibrary = 1, //音乐库
    MDMusicEditActionTypeClear,       //无音乐
    MDMusicEditActionTypeLocal,       //本地音乐
};


NS_ASSUME_NONNULL_BEGIN

@interface MDMusicEditActionItem : MDMusicBaseCollectionItem

@property (nonatomic, strong) NSString *iconString;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) MDMusicEditActionType type;

+ (instancetype)libraryEditActionItem;
+ (instancetype)clearEditActionItem;
+ (instancetype)localMusicActionItem;

@end

NS_ASSUME_NONNULL_END
