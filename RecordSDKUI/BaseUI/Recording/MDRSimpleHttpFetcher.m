//
//  MDRSimpleHttpFetcher.m
//  MDRPlayer
//
//  Created by sunfei on 2019/5/8.
//

#import "MDRSimpleHttpFetcher.h"

@implementation MDRRemoteResouce

- (instancetype)init {
    self = [super init];
    if (self) {
        _parser = ^id(NSData *data, NSError **error) {
            if (![data isKindOfClass:[NSData class]]) {
                return nil;
            }
            return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        };
    }
    return self;
}

- (void)setParser:(id  _Nonnull (^)(id _Nonnull, NSError * _Nullable __autoreleasing * _Nullable))parser {
    id(^lastPaser)(id, NSError **) = _parser;
    _parser = ^id(NSData *data, NSError **error) {
        id lastParserdData = lastPaser(data, error);
        if ((error && *error) || (!error && !lastParserdData)) {
            return nil;
        }
        
        return parser(lastParserdData, error);
    };
}

@end

@interface MDRSimpleHttpFetcher ()

@property (nonatomic, assign) BOOL forGetMethod;

@end

@implementation MDRSimpleHttpFetcher

+ (MDRSimpleHttpFetcher *)GET {
    MDRSimpleHttpFetcher *fetcher = [[MDRSimpleHttpFetcher alloc] init];
    fetcher.forGetMethod = YES;
    return fetcher;
}

+ (MDRSimpleHttpFetcher *)POST {
    MDRSimpleHttpFetcher *fetcher = [[MDRSimpleHttpFetcher alloc] init];
    fetcher.forGetMethod = NO;
    return fetcher;
}

- (id<MDRCancellable>)loadResource:(MDRRemoteResouce<id> *)resource
                            queue:(dispatch_queue_t)queue
                       completion:(void(^)(id data, NSData *rawData, NSError *error))completion {
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    
    NSURLRequest *request = [self requestForResource:resource];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     dispatch_async(queue, ^{
                                                                         if (error) {
                                                                             completion(nil, data, error);
                                                                             return;
                                                                         }
                                                                         
                                                                         if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                             NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                                                             NSInteger statusCode = urlResponse.statusCode;
                                                                             if (statusCode >= 400) {
                                                                                 NSError *error = [NSError errorWithDomain:@"MDRPlayerErrorDomain" code:statusCode userInfo:nil];
                                                                                 completion(nil, nil, error);
                                                                                 return;
                                                                             }
                                                                         }
                                                                         
                                                                         if (!resource.parser) {
                                                                             completion(data, data, nil);
                                                                         } else {
                                                                             NSError *error = nil;
                                                                             id parsedData = resource.parser(data, &error);
                                                                             completion(parsedData, data, error);
                                                                         }
                                                                     });
                                                                 }];
    [task resume];
    return task;
}

- (NSURLRequest *)requestForResource:(MDRRemoteResouce *)resource {
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:resource.remoteURL resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray array];
    for (NSString *key in resource.customParams) {
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:resource.customParams[key]];
        [queryItems addObject:item];
    }
    components.queryItems = queryItems;
    
    NSMutableURLRequest *request = nil;
    if (self.forGetMethod) {
        request = [NSMutableURLRequest requestWithURL:components.URL];
        request.HTTPMethod= @"GET";
    } else {
        request = [NSMutableURLRequest requestWithURL:resource.remoteURL];
        request.HTTPMethod= @"POST";
        NSString *body = components.query;
        request.HTTPBody = [NSData dataWithBytes:body.UTF8String length:body.length];
    }
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    for (NSString *key in self.headers) {
        [request setValue:self.headers[key] forHTTPHeaderField:key];
    }
    return [request copy];
}

@end
