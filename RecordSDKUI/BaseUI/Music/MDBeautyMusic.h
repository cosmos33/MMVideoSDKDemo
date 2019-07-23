//
//  MDBeautyMusic.h
//  MDChat
//
//  Created by sdk on 2018/5/11.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Eta/Eta.h>

typedef NS_ENUM(NSInteger ,MDBeautyMusicItemEdit){
    MDBeautyMusicItemEditNO = 0,
    MDBeautyMusicItemEditYES = 1
};

@interface MDBeautyMusic : EtaModel

@property (nonatomic ,strong) NSString                  *m_musicID;
@property (nonatomic ,strong) NSString                  *m_title;
@property (nonatomic ,strong) NSString                  *m_remoteUrl;
@property (nonatomic ,strong) NSString                  *m_desc;
@property (nonatomic ,strong) NSString                  *m_cateID;
@property (nonatomic ,strong) NSString                  *m_author;
@property (nonatomic ,strong) NSString                  *m_opid;
@property (nonatomic ,assign) NSTimeInterval            *m_duration;

//本地音乐用到的音乐
@property (nonatomic ,assign) BOOL                      m_isLocal;
@property (nonatomic ,strong) NSURL                     *m_localUrl;

//音乐聚合页
@property (nonatomic,assign) MDBeautyMusicItemEdit m_isCanEdit;
@property (nonatomic,copy) NSString *m_cover;
@property (nonatomic,assign) int m_joinCount;

+ (MDBeautyMusic *)dictionaryToBeautyMusic:(NSDictionary *)dic;
+ (NSMutableDictionary *)beautyMusicToDictionary:(MDBeautyMusic *)beautyMusic;

@end
