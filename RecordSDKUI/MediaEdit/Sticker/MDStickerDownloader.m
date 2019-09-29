//
//  MDStickerDownloader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDStickerDownloader.h"
#import "MDRecordResourceDownloader.h"

@interface MDStickerDownloader ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MDRecordDownloadTask *> *tasks;

@end

@implementation MDStickerDownloader

+ (instancetype)shared {
    static MDStickerDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[MDStickerDownloader alloc] init];
    });
    return downloader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadSticker:(MDDownLoaderModel *)sticker completion:(void(^)(MDDownLoaderModel *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:sticker.url];
    NSURL *dst = [NSURL fileURLWithPath:sticker.downLoadFileSavePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dst.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:dst withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    dst = [dst URLByAppendingPathExtension:url.pathExtension];
    MDRecordDownloadTask *task = [[MDRecordResourceDownloader downloader] startResourceDownloadWithURL:url completion:^(MDRecordDownloadResult result, NSURL * _Nullable localURL) {
        if (result == MDRecordDownloadSuccessful) {
            [[NSFileManager defaultManager] copyItemAtURL:localURL toURL:dst error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tasks[sticker.url] = nil;
            if (result == MDRecordDownloadSuccessful) {
                completion ? completion(sticker, nil) : nil;
            } else {
                NSError *error = [NSError errorWithDomain:@"RecordSDK.Demo" code:-1001 userInfo:nil];
                completion ? completion(nil, error) : nil;
            }
        });
    }];
    
    self.tasks[sticker.url] = task;
}

- (void)cancelSticker:(MDDownLoaderModel *)sticker {
    MDRecordDownloadTask *task = self.tasks[sticker.url];
    [task cancel];
}

@end
