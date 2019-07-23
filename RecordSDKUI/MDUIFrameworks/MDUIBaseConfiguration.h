//
//  MDUIBaseConfiguration.h
//  Pods
//
//  Created by RecordSDK on 2016/10/9.
//
//

#import <Foundation/Foundation.h>

@class MDViewController;

typedef void (^MDBaseControllerHandlerBlock)(MDViewController *_self);

@interface MDUIBaseConfiguration : NSObject

+ (MDUIBaseConfiguration *)uibaseConfiguration;

/* MDViewController viewWillAppear 统一业务逻辑 */
@property (nonatomic, copy) MDBaseControllerHandlerBlock viewWillAppearHandler;
/* MDViewController viewDidAppear 统一业务逻辑 */
@property (nonatomic, copy) MDBaseControllerHandlerBlock viewDidAppearHandler;

/* MDViewController viewWillDisappear 统一业务逻辑 */
@property (nonatomic, copy) MDBaseControllerHandlerBlock viewWillDisappearHandler;

/* MDViewController dealloc 统一处理，类似 [[MDContext apiManager] removeDelegate:self]; */
@property (nonatomic, copy) MDBaseControllerHandlerBlock deallocHandler;

@end
