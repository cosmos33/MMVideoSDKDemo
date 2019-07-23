//
//  MDFaceDecorationDownloader.m
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationDownloader.h"
#import "MDFaceDecorationItem.h"
#import "ZipArchive/ZipArchive.h"
#import "MDFaceDecorationFileHelper.h"
#import "MDPublicSwiftHeader.h"
#import "MDRecordHeader.h"

@interface MDFaceDecorationDownloader ()

@property (nonatomic, strong) NSMutableDictionary *urlStrDic;
@property (nonatomic, strong) NSHashTable<id<MDFaceDecorationDownloaderDelegate>> *delegates;

@end

@implementation MDFaceDecorationDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _urlStrDic = [[NSMutableDictionary alloc] init];
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc
{
}

- (void)downloadItem:(MDFaceDecorationItem *)item withType:(MDFaceDecorationDownloadType)type
{
    if (![item.identifier isNotEmpty]) {
        return;
    }
    
    NSString *urlStr = item.zipUrlStr;
    
    //如果正在下载，忽略
    if (![self isDownloadingItem:item urlStr:urlStr]) {
        [self addDownloadingItem:item urlStr:urlStr];
        item.isDownloading = YES;
        
        [[FaceDecorationDownloaderBridge shared] download:item completion:^(MDFaceDecorationItem * item, NSError * error) {
            if (item) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *path = [MDFaceDecorationFileHelper zipPathWithItem:item];
                    [self deployFaceDecoration:item path:path];
                });
            } else {
                [self removeDownloadingItem:item urlStr:urlStr];
                item.isDownloading = NO;
                
                MDFaceDecorationDownloadType type = MDFaceDecorationDownloadType_Zip;
                [self informDelegateDownloadFinish:item success:NO downloadType:type];
            }
        }];
        
        //开始下载
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MDFaceDecorationDownloaderDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(faceDecorationDownloaderStart:downloadWithItem:type:)]) {
                    [delegate faceDecorationDownloaderStart:self downloadWithItem:item type:type];
                }
            }
        });
    }
}

- (BOOL)isDownloadingItem:(MDFaceDecorationItem *)item
{
    BOOL isDownloading = NO;

    if ([self isDownloadingItem:item urlStr:item.zipUrlStr]) {
        isDownloading = YES;
    }
    
    return isDownloading;
}

- (BOOL)isDownloadingItem:(MDFaceDecorationItem *)item urlStr:(NSString *)urlStr
{
    NSString *identifier = item.identifier;
    NSString *name = [[urlStr componentsSeparatedByString:@"/"] lastObject];
    
    NSString *str = identifier;
    if ([name isNotEmpty]) {
        str = [identifier stringByAppendingString:name];
    }

    return [self.urlStrDic boolForKey:str defaultValue:NO];
}

- (void)addDownloadingItem:(MDFaceDecorationItem *)item urlStr:(NSString *)urlStr
{
    if (![item.identifier isNotEmpty]) {
        return;
    }
    //in case服务器不同的资源返回相同的url
    NSString *identifier = item.identifier;
    NSString *name = [[urlStr componentsSeparatedByString:@"/"] lastObject];
    
    NSString *str = identifier;
    if ([name isNotEmpty]) {
        str = [identifier stringByAppendingString:name];
    }
    
    [self.urlStrDic setObjectSafe:@(1) forKey:str];
}

- (void)removeDownloadingItem:(MDFaceDecorationItem *)item urlStr:(NSString *)urlStr
{
    NSString *identifier = item.identifier;
    
    NSString *name = [[urlStr componentsSeparatedByString:@"/"] lastObject];

    NSString *str = identifier;
    if ([name isNotEmpty]) {
        str = [identifier stringByAppendingString:name];
    }

    [self.urlStrDic removeObjectForKey:str];
}

//取消下载
- (void)cancelDownloadingItem:(MDFaceDecorationItem *)item
{
    if ([self isDownloadingItem:item urlStr:item.zipUrlStr]) {
//        NSString *zipPath = [MDFaceDecorationFileHelper zipPathWithItem:item];
//        [[MDRecordContext fileReceiverManager] cancelReceiver:zipPath];
        [[FaceDecorationDownloaderBridge shared] cancel:item];
        [self removeDownloadingItem:item urlStr:item.zipUrlStr];
    }
    item.isDownloading = NO;
}

//解压资源包
- (BOOL)deployFaceDecoration:(MDFaceDecorationItem *)item path:(NSString *)path
{
    BOOL success = NO;
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    if ([zip UnzipOpenFile:path]) {
        NSString *resourcePath = [MDFaceDecorationFileHelper resourcePathWithItem:item];
        success = [zip UnzipFileTo:resourcePath overWrite:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            item.isDownloading = NO;
            [self removeDownloadingItem:item urlStr:item.zipUrlStr];
            if (success) {
                [zip UnzipCloseFile];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                item.resourcePath = resourcePath;
            } else {
                item.resourcePath = nil;
            }
            [self informDelegateDownloadFinish:item success:success downloadType:MDFaceDecorationDownloadType_Zip];
        });
    }
    
    return success;
}

-(void)informDelegateDownloadFinish:(MDFaceDecorationItem *)item
                            success:(BOOL)sucess
                       downloadType:(MDFaceDecorationDownloadType)type
{
    for (id<MDFaceDecorationDownloaderDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(faceDecorationDownloader:downloadWithItem:type:downloadEnd:)]) {
            [delegate faceDecorationDownloader:self downloadWithItem:item type:type downloadEnd:sucess];
        }
    }
}

- (void)bind:(id<MDFaceDecorationDownloaderDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)releaseBind:(id<MDFaceDecorationDownloaderDelegate>)delegate
{
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

@end
