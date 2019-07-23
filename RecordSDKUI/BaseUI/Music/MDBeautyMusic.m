//
//  MDBeautyMusic.m
//  MDChat
//
//  Created by Leery on 2018/5/11.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDBeautyMusic.h"

@implementation MDBeautyMusic

#pragma mark - Eta
+ (NSDictionary *)eta_jsonKeyPathsByProperty {
    return @{
                     @"m_musicID"           :@"music_id",
                     @"m_title"             :@"title",
                     @"m_remoteUrl"         :@"url",
                     @"m_desc"              :@"type",
                     @"m_cateID"            :@"category_id",
                     @"m_author"            :@"author",
                     @"m_opid"              :@"opid",
                     @"m_isLocal"           :@"m_isLocal",
                     @"m_localUrl"          :@"m_localUrl",
                     @"m_joinCount"         :@"join_count",
                     @"m_cover"             :@"cover",
                     @"m_isCanEdit"         :@"is_can_edit"
            };
}

+ (NSString *)eta_key {
    return @"m_musicID";
}

+ (NSArray *)eta_dbStoreProperty {
    return @[
                  @"m_musicID"          ,
                  @"m_title"            ,
                  @"m_remoteUrl"        ,
                  @"m_desc"             ,
                  @"m_cateID"           ,
                  @"m_author"           ,
                  @"m_opid"         ,
                  @"m_isLocal"          ,
                  @"m_localUrl"         ,
            ];
}

+ (NSDictionary *)eta_valueTransform {
    return @{
             @"m_localUrl":[EtaBlockTransformer transformerWithDecodeBlock:^id _Nonnull(id  _Nonnull from) {
                 return [NSURL URLWithString:from];
             } encodeBlock:^id _Nonnull(id  _Nonnull from) {
                 return [from absoluteString];
             }]
             };
}

//升级新表
+ (NSInteger)eta_dbVersion {
    return 1;
}

+ (MDBeautyMusic *)dictionaryToBeautyMusic:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }
    return [self eta_modelFromDictionary:dic];
}


+ (NSMutableDictionary *)beautyMusicToDictionary:(MDBeautyMusic *)beautyMusic {
    if (beautyMusic == nil) {
        return nil;
    }
    return [[self eta_dictionaryFromModel:beautyMusic] mutableCopy];
}



@end
