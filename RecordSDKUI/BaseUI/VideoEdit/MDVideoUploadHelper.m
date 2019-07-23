//
//  MDVideoUploadHelper.m
//  MDChat
//
//  Created by wangxuan on 17/2/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDVideoUploadHelper.h"
#import "MDRecordVideoResult.h"

@interface MDVideoUploadHelper ()

@end

@implementation MDVideoUploadHelper

//获取视频预览图
- (UIImage *)getVideoPreviewImage{
    UIImage *previewImage = nil;
    
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.videoInfo.path]];

    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(640, 640);
    
    CMTime time = CMTimeMakeWithSeconds(1.5, asset.duration.timescale);
    
    NSError *error = nil;
    
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    
    previewImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    return previewImage;
}

- (void)saveVideoCover
{
    if (!self.originVideoCover) {
        self.originVideoCover = [self getVideoPreviewImage];
    }
    
    CGFloat compressScale = 1.0;
    if (self.videoInfo.accessSource == MDVideoRecordAccessSource_QVProfile) {
        compressScale = 0.75;
    }
    NSData *originVideoCoverdata = UIImageJPEGRepresentation(self.originVideoCover, compressScale);
    NSString *uuid = [MDRecordContext generateLongUUID];
#warning sunfei
    NSString *originVideoCoverUrl = [MDRecordContext imageTmpPath]; //[[MDContext currentUser].videoManager filePathDraftsWithUUID:uuid extension:@"jpg"];

    BOOL originVideoCoverResult = [originVideoCoverdata writeToURL:[NSURL fileURLWithPath:originVideoCoverUrl] atomically:NO];
    if (originVideoCoverResult) {
        self.videoInfo.videoCoverUuid = uuid;
    } else {
//        [Answers logCustomEventWithName:@"moment_originvideocover_writeerror" customAttributes:nil];
    }
}

- (void)configureMomentVideoInfo
{
    self.videoInfo.hasChooseCover = self.hasChooseCover;
    if (self.videoInfo.accessSource != MDVideoRecordAccessSource_Profile) {
        [self saveVideoCover];
    }

    self.videoInfo.isAllowShared = YES;
    
#warning sunfei
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;// [[[MDContext currentUser] dbStateHoldProvider] momentCameraPosition];
    self.videoInfo.isFrontCamera = position == AVCaptureDevicePositionFront ? 1 : 0 ;
}

- (void)prepareVideoResultWithURL:(NSURL *)url
{
    if (!self.videoInfo) {
        self.videoInfo = [[MDRecordVideoResult alloc] init];
    }
#warning sunfei
    self.videoInfo.uuid = [MDRecordContext generateLongUUID];
    if (self.videoInfo.accessSource == MDVideoRecordAccessSource_Profile || self.videoInfo.accessSource == MDVideoRecordAccessSource_QVProfile) {
        self.videoInfo.path = [MDRecordContext videoTmpPath2]; //[[MDContext currentUser].videoManager videoPathTmpWithUUID:self.videoInfo.uuid type:MDVideoRootPath_Profile];
    } else {
        self.videoInfo.path = [MDRecordContext videoTmpPath2]; // [[MDContext currentUser].videoManager videoPathDraftsWithUUID:self.videoInfo.uuid];
    }
    
    NSURL *targetUrl = [NSURL fileURLWithPath:self.videoInfo.path];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager removeItemAtURL:targetUrl error:&error];
    if (error) {
        NSLog(@"error = %@", error);
    }
    [fileManager moveItemAtURL:url toURL:targetUrl error:&error];
    if (error) {
        NSLog(@"error = %@", error);
    }

    AVAsset *videoAsset = [AVURLAsset assetWithURL:targetUrl];
    AVAssetTrack *track = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize videoSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);

    self.videoInfo.videoNaturalWidth = fabs(videoSize.width);
    self.videoInfo.videoNaturalHeight = fabs(videoSize.height);
    self.videoInfo.duration = CMTimeGetSeconds(videoAsset.duration);
    self.videoInfo.videoBitRate = [track estimatedDataRate];
    self.videoInfo.videoFrameRate = [track nominalFrameRate];
    
    self.videoInfo.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.videoInfo.path error:nil] fileSize];
    self.videoInfo.creationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.videoInfo.path error:nil] fileCreationDate];
    [self configureMomentVideoInfo];
}

- (void)prepareAnimojiVideoResultWithURL:(NSURL *)url andResourceId:(NSString *)resourceId {
    [self prepareVideoResultWithURL:url];
    self.videoInfo.faceID = resourceId;
}

@end
