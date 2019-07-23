//
//  MDMomentExpressionDownLoadManager.m
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDDownLoadManager.h"
#import "MDRecordHeader.h"
#import "MDRecordContext.h"
#import "MDPublicSwiftHeader.h"
#import "ZipArchive/ZipArchive.h"
@import RecordSDK;


@interface MDDownLoadManager ()

@property (nonatomic, weak) id<MDDownLoderDelegate>          delegate;
@property (nonatomic, strong) NSMutableDictionary           *downLoadingDict;

@end

@implementation MDDownLoadManager

- (instancetype)initWithDelegate:(id<MDDownLoderDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        _downLoadingDict = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
    }
    
    return self;
}

- (void)dealloc {
}

- (void)downloadItem:(MDDownLoaderModel *)item {
    
    //如果正在下载，忽略
    if (![self isDownloadingItem:item] || !item.downLoadFileSavePath) {
        
        [self addDownloadingItem:item];
        item.state = MDDownLoadStateLoading;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObjectSafe:item forKey:@"item"];
             
        //        NSLog(@"addDownloader:%@ url:%@",item.identifier,urlStr);
        [[DownloadManagerBridge shared] download:item completion:^(MDDownLoaderModel * item, NSError * error) {
            if (item) {
                [self removeDownLoadingItem:item];
                
                if ([[item.url pathExtension] isEqualToString:@"zip"]) {
                    //解压
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self deployFaceDecoration:item path:[item.downLoadFileSavePath stringByAppendingPathExtension:[item.url pathExtension]]];
                    });
                } else {
                    item.state = MDDownLoadStateSuccess;
                    if ([self.delegate respondsToSelector:@selector(downloader:withItem:downloadEnd:)]) {
                        [self.delegate downloader:self withItem:item downloadEnd:YES];
                    }
                }
            } else {
                item.state = MDDownLoadStateFailed;
                
                [self removeDownLoadingItem:item];
                
                if ([self.delegate respondsToSelector:@selector(downloader:withItem:downloadEnd:)]) {
                    [self.delegate downloader:self withItem:item downloadEnd:NO];
                }
            }
        }];
        
        //开始下载
        if ([_delegate respondsToSelector:@selector(downloaderStart:downloadWithItem:)]) {
            [_delegate downloaderStart:self downloadWithItem:item];
        }
    }
}

- (BOOL)isDownloadingItem:(MDDownLoaderModel *)item {
    
    return [[self.downLoadingDict allKeys] containsObject:[item.url md_MD5]];
}

- (void)addDownloadingItem:(MDDownLoaderModel*)item {
    
    [self.downLoadingDict setObjectSafe:item forKey:[item.url md_MD5]];
}

- (void)removeDownLoadingItem:(MDDownLoaderModel*)item {
    
    [self.downLoadingDict removeObjectForKey:[item.url md_MD5]];
}

- (void)cancelDownloadingItem:(MDDownLoaderModel *)item {
    
    if ([self isDownloadingItem:item]) {
        [[DownloadManagerBridge shared] cancelWithItem:item];
        [self removeDownLoadingItem:item];
    }
    
    item.state = MDDownLoadStateNone;
}

//解压资源包
- (BOOL)deployFaceDecoration:(MDDownLoaderModel*)item path:(NSString *)path
{
    BOOL success = NO;
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip setProgressBlock: (ZipArchiveProgressUpdateBlock)^(int percentage, int filesProcessed, int numFiles) {
        
        //        NSLog(@"unzip:%@---->progress:%d",item.identifier, percentage);
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float progress = (percentage /100.f) *0.2 +0.8;
            //            [weakSelf.delegate faceDecorationDownloader:self downloadWithItem:item type:MDFaceDecorationDownloadType_Zip progress:progress];
            
        });
    }];
    
    if ([zip UnzipOpenFile:path]) {
        
        success = [zip UnzipFileTo:item.resourcePath overWrite:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                [zip UnzipCloseFile];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                item.state = MDDownLoadStateSuccess;
            } else {
                item.state = MDDownLoadStateFailed;
            }
            
            if ([self.delegate respondsToSelector:@selector(downloader:withItem:downloadEnd:)]) {
                [self.delegate downloader:self withItem:item downloadEnd:success];
            }
        });
    }
    
    return success;
}

@end
