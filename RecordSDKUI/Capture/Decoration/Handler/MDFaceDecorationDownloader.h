//
//  MDFaceDecorationDownloader.h
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordHeader.h"

@class MDFaceDecorationItem;

typedef NS_ENUM(NSUInteger, MDFaceDecorationDownloadType) {
    MDFaceDecorationDownloadType_Zip,
};

@protocol MDFaceDecorationDownloaderDelegate <NSObject>

@optional

- (void)faceDecorationDownloaderStart:(id)sender
                     downloadWithItem:(MDFaceDecorationItem *)item
                                 type:(MDFaceDecorationDownloadType)type;

- (void)faceDecorationDownloader:(id)sender
                downloadWithItem:(MDFaceDecorationItem *)item
                            type:(MDFaceDecorationDownloadType)type
                     downloadEnd:(BOOL)result;

@end

// 人脸装饰素材下载器
@interface MDFaceDecorationDownloader : NSObject

- (void)downloadItem:(MDFaceDecorationItem *)item withType:(MDFaceDecorationDownloadType)type;
- (BOOL)isDownloadingItem:(MDFaceDecorationItem *)item;
- (void)cancelDownloadingItem:(MDFaceDecorationItem *)item;

- (void)bind:(id<MDFaceDecorationDownloaderDelegate>)delegate;
- (void)releaseBind:(id<MDFaceDecorationDownloaderDelegate>)delegate;

@end
