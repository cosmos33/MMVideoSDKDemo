//
//  MCCResourceDownloader.h
//  MCCSDK
//
//  Created by sunfei on 2019/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordDownloadTask: NSObject

- (void)cancel;

@end

typedef NS_ENUM(NSUInteger, MDRecordDownloadResult) {
    MDRecordDownloadSuccessful,
    MDRecordDownloadFailed,
    MDRecordDownloadCancelled,
};

typedef void(^MDRecordResourceDownloadCallback)(MDRecordDownloadResult result, NSURL * _Nullable localURL);

@interface MDRecordResourceDownloader : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)downloader;

- (MDRecordDownloadTask *)startResourceDownloadWithURL:(NSURL *)resourceURL
                                       completion:(MDRecordResourceDownloadCallback)completion;

@end

NS_ASSUME_NONNULL_END
