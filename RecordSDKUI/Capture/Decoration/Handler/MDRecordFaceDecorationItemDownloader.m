//
//  MDRecordFaceDecorationItemDownloader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordFaceDecorationItemDownloader.h"
#import "MDRecordResourceDownloader.h"
#import "MDFaceDecorationFileHelper.h"

@interface MDRecordFaceDecorationItemDownloader ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MDRecordDownloadTask *> *tasks;

@end

@implementation MDRecordFaceDecorationItemDownloader

+ (instancetype)shared {
    static MDRecordFaceDecorationItemDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[MDRecordFaceDecorationItemDownloader alloc] init];
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

- (void)downloadItem:(MDFaceDecorationItem *)item completion:(void(^)(MDFaceDecorationItem *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:item.zipUrlStr];
    NSURL *dst = [NSURL fileURLWithPath:[MDFaceDecorationFileHelper zipPathWithItem:item]];
    
    NSURL *dir = [dst URLByDeletingLastPathComponent];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    MDRecordDownloadTask *task = [[MDRecordResourceDownloader downloader] startResourceDownloadWithURL:url completion:^(MDRecordDownloadResult result, NSURL * _Nullable localURL) {
        if (result == MDRecordDownloadSuccessful && localURL) {
            [[NSFileManager defaultManager] copyItemAtURL:localURL toURL:dst error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tasks[item.zipUrlStr] = nil;
            if (result == MDRecordDownloadSuccessful) {
                completion ? completion(item, nil) : nil;
            } else {
                NSError *error = [NSError errorWithDomain:@"RecordSDK.Demo" code:-1001 userInfo:nil];
                completion ? completion(nil, error) : nil;
            }
        });
    }];
    self.tasks[item.zipUrlStr] = task;
}

- (void)cancelWithItem:(MDFaceDecorationItem *)item {
    MDRecordDownloadTask *task = self.tasks[item.zipUrlStr];
    [task cancel];
}

@end
