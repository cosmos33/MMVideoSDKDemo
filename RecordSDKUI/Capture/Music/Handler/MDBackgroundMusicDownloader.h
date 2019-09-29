//
//  MDBackgroundMusicDownloader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMusicBVO.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDBackgroundMusicDownloaderDelegate <NSObject>

- (void)startDownloadWithItem:(MDMusicBVO *)item;
- (void)finishDownloadWithItem:(MDMusicBVO *)item fileUrl:(NSURL * _Nullable)url success:(BOOL)result;

@end

@interface MDBackgroundMusicDownloader : NSObject

+ (instancetype)shared;
+ (NSURL *)resourcePathForItem:(MDMusicBVO *)item;
- (void)requestRecommendMusicWithCompletion:(void(^)(NSString *, NSError *))completion;
- (void)downloadItem:(MDMusicBVO *)item bind:(id<MDBackgroundMusicDownloaderDelegate>)targetOjb;
- (void)downloadItem:(MDMusicBVO *)item completion:(void(^)(MDMusicBVO *, NSURL *, BOOL))completion;

@end

NS_ASSUME_NONNULL_END
