//
//  MDFaceDecorationLoader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDFaceDecorationLoader.h"
#import "MDRSimpleHttpFetcher.h"
@import MCCSecret;

static NSString *fd_randomString(int len);
static NSString * fd_urlencode(NSString *content);

static NSString * const HOST = @"https://cosmos-video-api.immomo.com/video/index/face";
static NSString * const APPID = @"appId";
static NSString * const DEVICEID= @"deviceId";
static NSString * const MZIP = @"mzip";
static NSString * const MSC = @"msc";
static NSString * const ADEBUG = @"debug";
static NSString * const MM_FACE_DECORATION_PUBLIC_KEY = @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKbj7WvmhEVXZbeqvMGXdMDvGlD6/Aa/MRxkhtUzdMBtB1FzUGOs77Yo7Es3cxt4HQGrioAaPXCyNC4KX1L8qdcCAwEAAQ==";

@interface MDFaceDecorationLoader()

@property (nonatomic, strong) MDRSimpleHttpFetcher<NSDictionary *> *fetcher;

@end

@implementation MDFaceDecorationLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fetcher = [MDRSimpleHttpFetcher POST];
        Class utils = NSClassFromString(@"MCCNetworkUtils");
        SEL userAgent = NSSelectorFromString(@"userAgentString");
        NSString *agent = nil;
        if ([utils respondsToSelector:userAgent]) {
            agent = [utils performSelector:userAgent];
        }
        if (!agent) {
            return nil;
        }
        self.fetcher.headers = @{
                                 @"User-Agent" : agent
                                 };
    }
    return self;
}

- (void)fetchDecorationsWithCompletion:(void(^)(NSDictionary *, NSError *))completion {
    NSError *error = nil;
    MDRRemoteResouce<NSDictionary *> *resource = [self resourceWithError:&error];
    
    if (error) {
        completion ? completion(nil, error) : nil;
        return;
    }
    
    [self.fetcher loadResource:resource
                         queue:nil
                    completion:^(id  _Nonnull data, NSData * _Nonnull rawData, NSError * _Nonnull error) {
                        if (error) {
                            completion ? completion(nil, error) : nil;
                            return;
                        }
                        
                        completion ? completion(data, nil) : nil;
                    }];
}

- (MDRRemoteResouce<NSDictionary *> *)resourceWithError:(NSError **)error {
    MDRRemoteResouce<NSDictionary *> *resource = [[MDRRemoteResouce alloc] init];
    resource.remoteURL = [NSURL URLWithString:HOST];
    
    NSString *aesKey = fd_randomString(8);
    NSString *mscStr = [MCCSecretRSA mcc_encryptString:aesKey publicKey:MM_FACE_DECORATION_PUBLIC_KEY];
    NSDictionary *dic = @{
                          APPID : @"9dac61837c9bc9eba14f8a32584bde1f",
                          DEVICEID : [UIDevice currentDevice].identifierForVendor.UUIDString,
                          };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *base64Data = [NSString mcc_base64StringFromData:data length:[data length]];
    NSString *mzipStr = [MCCSecretAESCrypt mcc_encrypt:base64Data password:aesKey];
    
    NSString *encodeMSC = fd_urlencode(mscStr);
    NSString *encodeZIP = fd_urlencode(mzipStr);
    
    if ([encodeMSC stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:-100 userInfo:nil];
        }
        return nil;
    }
    
    if ([encodeZIP stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"" code:-100 userInfo:nil];
        }
        return nil;
    }
    
    resource.customParams = @{
                              MZIP : encodeZIP,
                              MSC : encodeMSC
                              };
    
    resource.parser = ^NSDictionary *(id dic, NSError ** error) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        int ec = [dic[@"ec"] intValue];
        if (ec != 0) {
            if (error) {
                *error = [NSError errorWithDomain:@"errorDomain" code:ec userInfo:dic[@"em"]];
            }
            return nil;
        }
        
        NSDictionary *dataDic = dic[@"data"];
        NSString *dataStr = dataDic[MZIP];
        NSString *decodeData = [MCCSecretAESCrypt mcc_decrypt:dataStr password:aesKey];
        
        if (!decodeData) {
            return nil;
        }
        
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:[decodeData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
        
        if (![userInfo isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSLog(@"sunfei userInfo = %@", userInfo);
        return userInfo;
    };
    
    return resource;
}

@end

static NSString *fd_randomString(int len)  {
    static NSString *mdr_fd_letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [mdr_fd_letters characterAtIndex: arc4random_uniform(62)]];
    }
    return randomString;
}

static NSString * fd_urlencode(NSString *content) {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[content UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


