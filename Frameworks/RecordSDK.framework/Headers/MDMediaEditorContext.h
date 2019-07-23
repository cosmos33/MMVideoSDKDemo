//
//  MDMediaEditorContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/10/30.
//

#import <Foundation/Foundation.h>
#import "MDProcessImageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDMediaEditorContext : NSObject

- (void)startProcess;
- (void)stopProcess;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
