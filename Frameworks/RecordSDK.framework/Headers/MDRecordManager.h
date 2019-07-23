//
//  MDRecordManager.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/2/19.
//

#import <Foundation/Foundation.h>
#import "MDRecordCallbackMessage.h"
#import "MDRecordDetectorPreloader.h"

NS_ASSUME_NONNULL_BEGIN

#define COMMAND_REGISTER 1
#define COMMAND_FETCH_CONFIF 2

#define STORE_KEY_APPTOKEN @"APP_TOKEN"

@interface MDRecordManager : NSObject

@property (nonatomic,assign) SEL mCommandListener;
@property (nonatomic,weak) id lisenterTarget;
@property (nonatomic,strong) MDRecordCallbackMessage *callbackMessage;

+ (void)initSDK:(NSString *)appID;

+ (void)runBlock:(dispatch_block_t)aBlock;

+ (BOOL)isReady;

+ (void)registerToken;

+ (void)fetchConfig;

+ (void)fetchConfigUsingAppId;

+ (void)onCommand:(int)command code:(int)code message:(NSString *)message userInfo:(NSDictionary *)userInfo;

+ (void) addCommandListener: (SEL) mSelctor target:(id) mTarget;

+ (NSString *)version;

+ (NSString *)appToken;

+ (void)setDetectorModelsPreloader:(id<MDRecordDetectorPreloader>)preloader;

@end

NS_ASSUME_NONNULL_END
