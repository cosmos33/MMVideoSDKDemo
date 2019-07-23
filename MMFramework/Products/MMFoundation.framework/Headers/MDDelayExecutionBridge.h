//
//  MDDelayExecutionBridge.h
//  MomoChat
//
//  Created by Allen on 3/4/14.
//  Copyright (c) 2014 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDelayExecutionBridge : NSObject

/*
 本类提供使用performSelector:afterDelay的中转，obj是真正需要延时执行的对象，但是延时执行会retain obj，导致obj不会马上释放（所以obj为了不被延时释放必须选择一个时机cancelPreviousRequest，但是7里面支持手势后退，所以这个时机的选择有时候就比较纠结），使用这个类中转延时的请求，也就是这个类会被持有。但是obj的类不会被延时释放，可以在obj的dealloc里调用一下@method cancelAllPreviousRequst
 
 ps: 这个类不会持有obj
 */
- (id)initWithDelayExecutedObject:(NSObject *)obj;

- (void)enqueueWithDelay:(NSTimeInterval)delay excutedSelector:(SEL)aSelector argumentObject:(id)anArgument;

//必须在使用这个类的dealloc里调用一下这个方法，不然这个类就失去意义啦！！！，而且这个类为了保证使用者能够正常的dealloc不会持有使用者，所以使用者必须在dealloc里调用这个方法，不然如果有未执行的延时请求肯定会crash
- (void)cancelAllPreviousRequst;

//取消前面提交的某个特定的延时请求
- (void)cancelPreviousReqeustWithSelector:(SEL)aSelector argumentObject:(id)anArgument;

@end
