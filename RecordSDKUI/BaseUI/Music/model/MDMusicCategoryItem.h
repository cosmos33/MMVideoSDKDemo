//
//  MDMusicCategoryItem.h
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicCategoryItem : NSObject

// 垂类id 唯一
@property (nonatomic, strong) NSString          *categoryId;
// 垂类标题
@property (nonatomic, strong) NSString          *categoryName;
// 是否是默认配置帧
@property (nonatomic, assign) BOOL              selected;

+ (MDMusicCategoryItem *)dictToMusicCategoryItem:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
