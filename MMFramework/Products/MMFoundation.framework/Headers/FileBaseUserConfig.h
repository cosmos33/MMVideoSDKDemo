//
//  FileBaseUserConfig.h
//  IMJClient
//
//  Created by Latermoon on 12-9-3.
//
//

#import <Foundation/Foundation.h>
#import "MFUserConfig.h"

/**
 * 提供基于文本存储的UserConfig
 * UserConfig *userConfig = [FileBaseUserConfig configWithFile:@"100422.conf"];
 */
@interface FileBaseUserConfig : NSObject <MFUserConfig>
{
    NSString *filePath;
    // 持久化Queue
    dispatch_queue_t opQueue;
    // 将配置数据保存到内存
    NSMutableDictionary *configDictionary;
    
    /* 
     *  为了解决频繁调用synchronize时的卡顿问题，在每次调用setObject:(id)value forKey:(id)aKey时，
     *  只是把内存内容更新，并将标志位needSynchronize置为YES，
     *  由计时器去触发，并判断是否需要真正的调用synchronize方法。
     *  在调用synchronize方法后，需要把needSynchronize置为NO.
     */
    BOOL needSynchronize;
}

@property(readonly) NSString *filePath;

#pragma mark - Init
- (FileBaseUserConfig *)initWithFile:(NSString *)aFilePath;

@end

/**
 * Private Method
 */
@interface FileBaseUserConfig (Private)

// 持久化
- (BOOL)synchronize;

@end

