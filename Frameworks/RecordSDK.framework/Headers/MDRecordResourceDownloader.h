//
//  MDRecordResourceDownloader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/8.
//

#import <Foundation/Foundation.h>
#import "MDCancellable.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordDownloadTask: NSObject <MDCancellable>

@end

typedef NS_ENUM(NSUInteger, MDRecordDownloadResult) {
    MDRecordDownloadSuccessful,
    MDRecordDownloadFailed,
    MDRecordDownloadCancelled,
};

typedef void(^MDResourceDownloadCallback)(MDRecordDownloadResult result, NSURL *localURL);

@interface MDRecordResourceDownloader : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)downloader;

- (id<MDCancellable>)startResourceDownloadWithURL:(NSURL *)resourceURL
                                       completion:(MDResourceDownloadCallback)completion;

@end

NS_ASSUME_NONNULL_END
