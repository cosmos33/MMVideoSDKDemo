//
//  MDRecordResourceDownloader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/8.
//

#import "MDRecordResourceDownloader.h"
#import <stdatomic.h>

@interface MDRecordDownloadTask ()  <NSCopying>

@property (nonatomic, strong) NSURL *remoteResourceURL;
@property (nonatomic, assign) uint64_t taskIdentifier;

@end

@interface MDRecordResourceDownloadTrace: NSObject

// data can be of type NSData * or NSURL *
typedef void(^MDRecordUnifiedDownloadCallback)(MDRecordDownloadResult result, NSURL *tmpURL);

@property (nonatomic, strong) NSMutableDictionary<MDRecordDownloadTask *, MDRecordUnifiedDownloadCallback> *callbacks;
@property (nonatomic, strong) NSURLSessionTask *internalTask;

@end

@interface MDRecordResourceDownloader ()

@property (nonatomic, strong) NSMutableDictionary<NSURL *, MDRecordResourceDownloadTrace *> *downloadingRsources;

- (void)cancelTask:(MDRecordDownloadTask *)task;

@end

@implementation MDRecordDownloadTask

static atomic_uint_fast64_t globalMediaTaskCount = 0;

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskIdentifier = atomic_fetch_add_explicit(&globalMediaTaskCount, 1, memory_order_relaxed);
    }
    return self;
}

- (instancetype)initNoCount {
    return [super init];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MDRecordDownloadTask *task = [[MDRecordDownloadTask alloc] initNoCount];
    task.taskIdentifier = self.taskIdentifier;
    task.remoteResourceURL = self.remoteResourceURL;
    return task;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MDRecordDownloadTask class]]) {
        return NO;
    }
    
    MDRecordDownloadTask *anotherTask = (MDRecordDownloadTask *)object;
    return anotherTask.taskIdentifier == self.taskIdentifier;
}

- (NSUInteger)hash {
    return (NSUInteger)_taskIdentifier;
}

- (void)cancel {
    MDRecordResourceDownloader *downloader = [MDRecordResourceDownloader downloader];
    [downloader cancelTask:self];
}

@end

@implementation MDRecordResourceDownloadTrace

- (instancetype)init {
    self = [super init];
    if (self) {
        _callbacks = [NSMutableDictionary dictionary];
    }
    return self;
}

@end

@implementation MDRecordResourceDownloader

+ (instancetype)downloader {
    static dispatch_once_t token;
    static MDRecordResourceDownloader *downloader;
    dispatch_once(&token, ^{
        downloader = [[MDRecordResourceDownloader alloc] initPrivate];
    });
    return downloader;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _downloadingRsources = [NSMutableDictionary dictionary];
    }
    return self;
}

typedef NSURLSessionTask *(^InternalTaskCreation)(NSURLSession *session, NSURLRequest *request);

- (MDRecordDownloadTask *)startResourceDownloadWithURL:(NSURL *)resourceURL
                                       completion:(MDRecordResourceDownloadCallback)completion {
    InternalTaskCreation internalTask = ^NSURLSessionTask *(NSURLSession *session, NSURLRequest *request) {
        NSURL *remoteURL = request.URL;
        return [session downloadTaskWithRequest:request
                              completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
                                  
#ifdef DEBUG
                                  NSInteger stateCode = (NSInteger)[(NSHTTPURLResponse *)response statusCode];
                                  NSLog(@"MDRecord Netwrok Download Model url:%@ responseCode:%ld error:%@",resourceURL,(long)stateCode,error);
#endif
                                  
                                  // move file to cache directory
                                  NSURL *cachedFileURL = nil;
                                  if (!error && location.lastPathComponent) {
                                      NSURL *cacheDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
                                      cachedFileURL = [cacheDirectory URLByAppendingPathComponent:location.lastPathComponent];
                                  }
                                  
                                  if (![self verifyResponce:response consistenceWithRequestAsImage:NO]) {
                                      cachedFileURL = nil;
                                  }
                                  
                                  if (cachedFileURL && ![[NSFileManager defaultManager] moveItemAtURL:location toURL:cachedFileURL error:NULL]) {
                                      cachedFileURL = nil;
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self notifyTaskFinishedWithData:cachedFileURL forURL:remoteURL];
                                  });
                              }];
    };
    
    return [self registerCallback:completion
                forRemoteReosurce:resourceURL
                     internalTask:internalTask];
}

- (BOOL)verifyResponce:(NSURLResponse *)response consistenceWithRequestAsImage:(BOOL)asImage {
    
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return NO;
    }
    NSHTTPURLResponse *httpResponce = (NSHTTPURLResponse *)response;
    if (httpResponce.statusCode != 200) {
        return NO;
    }
    
    return YES;
}

- (MDRecordDownloadTask *)registerCallback:(MDRecordUnifiedDownloadCallback)callback
                         forRemoteReosurce:(NSURL *)remoteResourceURL
                              internalTask:(InternalTaskCreation)createInternalTaskIfNeeded {
    assert(createInternalTaskIfNeeded);

    MDRecordResourceDownloadTrace *trace = self.downloadingRsources[remoteResourceURL];
    if (!trace) {
        trace = [[MDRecordResourceDownloadTrace alloc] init];

        static dispatch_once_t sessionCreationToken;
        static NSURLSession *session;
        dispatch_once(&sessionCreationToken, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.HTTPMaximumConnectionsPerHost = 6;
            session = [NSURLSession sessionWithConfiguration:configuration];
        });
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:remoteResourceURL
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:60];
        
        trace.internalTask = createInternalTaskIfNeeded(session, request);
        self.downloadingRsources[remoteResourceURL] = trace;
        [trace.internalTask resume];
    }
    
    MDRecordDownloadTask *task = [[MDRecordDownloadTask alloc] init];
    task.remoteResourceURL = remoteResourceURL;
    trace.callbacks[task] = callback;
    
    return task;
}

- (void)cancelTask:(MDRecordDownloadTask *)task {
    NSURL *remoteResourceURL = task.remoteResourceURL;
    MDRecordResourceDownloadTrace *trace = self.downloadingRsources[remoteResourceURL];
    if (!trace) {
        return;
    }
    
    MDRecordUnifiedDownloadCallback callback = trace.callbacks[task];
    if (!callback) {
        return;
    }
    
    callback(MDRecordDownloadCancelled, nil);
    trace.callbacks[task] = nil;
    if (trace.callbacks.count == 0) {
        // 无引用则停止内核task
        [trace.internalTask cancel];
        self.downloadingRsources[remoteResourceURL] = nil;
    }
}

- (void)notifyTaskFinishedWithData:(NSURL *)tmpURL forURL:(NSURL *)remoteResourceURL {
    MDRecordResourceDownloadTrace *trace = self.downloadingRsources[remoteResourceURL];
    for (MDRecordUnifiedDownloadCallback callback in trace.callbacks.allValues) {
        // check returned type
        callback(tmpURL != nil ? MDRecordDownloadSuccessful : MDRecordDownloadFailed,
                 tmpURL);
    }
    
    // 移除缓存文件
    [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:NULL];
    // 清空记录
    self.downloadingRsources[remoteResourceURL] = nil;
}

@end
