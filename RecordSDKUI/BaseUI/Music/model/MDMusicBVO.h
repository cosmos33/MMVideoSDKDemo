//
//  MDMusicBVO.h
//  MDChat
//
//  Created by YZK on 2018/11/8.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicBVO : NSObject <NSCopying>

@property (nonatomic ,strong) NSString       *musicID;
@property (nonatomic ,strong) NSString       *title;
@property (nonatomic ,strong) NSString       *remoteUrl;
@property (nonatomic ,strong) NSString       *cover;
@property (nonatomic ,strong) NSString       *type;
@property (nonatomic ,strong) NSString       *categoryID;
@property (nonatomic ,strong) NSString       *author;
@property (nonatomic ,strong) NSString       *opid;
@property (nonatomic ,assign) NSTimeInterval duration;

+ (MDMusicBVO *)converToMusicItemWithDictionary:(NSDictionary *)dic;
+ (NSDictionary *)converToDictionaryWithMusicItem:(MDMusicBVO *)item;

@end

NS_ASSUME_NONNULL_END
