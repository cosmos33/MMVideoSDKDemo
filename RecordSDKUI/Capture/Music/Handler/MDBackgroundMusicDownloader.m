//
//  MDBackgroundMusicDownloader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDBackgroundMusicDownloader.h"
#import "MDRecordResourceDownloader.h"

@interface MDBackgroundMusicDownloader ()

@end

@implementation MDBackgroundMusicDownloader

+ (instancetype)shared {
    static MDBackgroundMusicDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[MDBackgroundMusicDownloader alloc] init];
    });
    return downloader;
}

+ (NSURL *)resourcePathForItem:(MDMusicBVO *)item {

    NSString *extension = item.remoteUrl.pathExtension;
    NSString *name = [item.musicID stringByAppendingPathExtension:extension];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/VideoBackgroundMusic/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:name]];
}

- (void)requestRecommendMusicWithCompletion:(void(^)(NSString *, NSError *))completion {
    NSURL *url = [NSBundle.mainBundle URLForResource:@"RecomendMusics" withExtension:@"geojson"];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    completion ? completion(content, error) : nil;
}

- (void)downloadItem:(MDMusicBVO *)item bind:(id<MDBackgroundMusicDownloaderDelegate>)targetOjb {
    NSURL *resourcePath = [MDBackgroundMusicDownloader resourcePathForItem:item];
    
    [targetOjb startDownloadWithItem:item];
    [[MDRecordResourceDownloader downloader] startResourceDownloadWithURL:[NSURL URLWithString:item.remoteUrl] completion:^(MDRecordDownloadResult result, NSURL * _Nullable localURL) {
        if (result == MDRecordDownloadSuccessful) {
            [[NSFileManager defaultManager] copyItemAtURL:localURL toURL:resourcePath error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == MDRecordDownloadSuccessful) {
                [targetOjb finishDownloadWithItem:item fileUrl:resourcePath success:YES];
            } else {
                [targetOjb finishDownloadWithItem:item fileUrl:nil success:NO];
            }
        });
    }];
}

- (void)downloadItem:(MDMusicBVO *)item completion:(void(^)(MDMusicBVO *, NSURL *, BOOL))completion {
    NSURL *resourcePath = [MDBackgroundMusicDownloader resourcePathForItem:item];
    
    [[MDRecordResourceDownloader downloader] startResourceDownloadWithURL:[NSURL URLWithString:item.remoteUrl] completion:^(MDRecordDownloadResult result, NSURL * _Nullable localURL) {
        if (result == MDRecordDownloadSuccessful) {
            [[NSFileManager defaultManager] copyItemAtURL:localURL toURL:resourcePath error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           if (result == MDRecordDownloadSuccessful) {
               completion ? completion(item, resourcePath, YES) : nil;
           } else {
               completion ? completion(item, nil, NO) : nil;
           }
        });
    }];
    
}

@end
