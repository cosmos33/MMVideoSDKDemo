//
//  MDMusicCollectionItem.h
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionItem.h"
#import "MDMusicBVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicCollectionItem : MDMusicBaseCollectionItem <NSCopying>

@property (nonatomic ,strong) MDMusicBVO     *musicVo;

@property (nonatomic ,assign) BOOL           isLocal; //是否是本地音乐
@property (nonatomic ,strong) NSURL          *resourceUrl; //资源文件url

@property (nonatomic ,assign) BOOL           downLoading; //是否正在下载
@property (nonatomic, assign) BOOL           selected; //是否正被选中

- (instancetype)favouriteCopyItem;

- (BOOL)resourceExist;
- (NSString *)displayTitle;

+ (MDMusicCollectionItem *)converToMusicItemWithDictionary:(NSDictionary *)dic;
+ (NSDictionary *)converToDictionaryWithMusicItem:(MDMusicCollectionItem *)item;

@end

NS_ASSUME_NONNULL_END
