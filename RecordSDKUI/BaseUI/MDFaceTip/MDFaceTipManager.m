//
//  MDFaceTipManager.m
//  MDChat
//
//  Created by sdk on 2017/6/22.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceTipManager.h"
#import "MDFaceTipItem.h"
#import <pthread.h>
#import "MDRecordHeader.h"

@interface MDFaceTipManager ()

@property (nonatomic, strong) MDFaceTipItem                 *frontItem;
@property (nonatomic, strong) MDFaceTipItem                 *backItem;
@property (nonatomic, strong) MDFaceTipItem                 *currentItem;

@property (nonatomic, strong) NSTimer *showTimer;

@property (nonatomic, weak) id <MDFaceTipShowDelegate>      target;
@property (nonatomic, assign) AVCaptureDevicePosition       position;

@property (nonatomic, assign) BOOL                          shouldContinue;
@property (atomic, assign) MDFaceTipSignal                  currentSignal;

@property (nonatomic, strong) NSMutableArray                *displayTextQueue;
@property (nonatomic, strong) NSString                      *displayingText;
@end

@implementation MDFaceTipManager

+ (instancetype)managerWithDictionary:(NSDictionary *)dic
                             position:(AVCaptureDevicePosition)position
                           showTarget:(id<MDFaceTipShowDelegate>)showTarget
{
    if (dic.count) {
        MDFaceTipManager *manager = [[[self class] alloc] initWithDictInfo:dic
                                                                  position:position
                                                                showTarget:showTarget];
        return manager;
    } else {
        return nil;
    }
}

- (instancetype)initWithDictInfo:(NSDictionary *)info
                        position:(AVCaptureDevicePosition)position
                      showTarget:(id<MDFaceTipShowDelegate>)showTarget
{
    if (self = [super init]) {
        self.target = showTarget;
        
        self.backItem = [MDFaceTipItem eta_modelFromDictionary:[info dictionaryForKey:@"backTips" defaultValue:@{}]];
        self.frontItem = [MDFaceTipItem eta_modelFromDictionary:[info dictionaryForKey:@"frontTips" defaultValue:@{}]];
        
        //position中的setter会设置currentItem，所以把position的设置放到后面
        self.position = position <= AVCaptureDevicePositionBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        [self ensureContinueState];
    }
    return self;
}

- (instancetype)initWithFaceTipItem:(MDFaceTipItem *)faceTipItem
                           position:(AVCaptureDevicePosition)position
                         showTarget:(id <MDFaceTipShowDelegate>)showTarget
{
    if (self = [super init]) {
        self.target = showTarget;
        
        self.backItem = faceTipItem;
        self.frontItem = faceTipItem;
        
        //position中的setter会设置currentItem，所以把position的设置放到后面
        self.position = position <= AVCaptureDevicePositionBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        [self ensureContinueState];
    }
    return self;
}

- (NSMutableArray *)displayTextQueue
{
    if (!_displayTextQueue) {
        _displayTextQueue = [[NSMutableArray alloc] init];
    }
    
    return _displayTextQueue;
}

- (void)setPosition:(AVCaptureDevicePosition)position
{
    if (_position != position) {
        _position = position;
        
        if (_position == AVCaptureDevicePositionFront) {
            _currentItem = self.frontItem;
        }
        else if (_position == AVCaptureDevicePositionBack) {
            _currentItem = self.backItem;
        }
        else {
            _currentItem = nil;
        }
    }
}

- (void)setShouldContinue:(BOOL)flag
{
    if (_shouldContinue != flag) {
        _shouldContinue = flag;
        
        //notify delegate
        self.target.shouldContinue = flag;
    }
}

- (void)enqueueDisplayText:(NSString *)text
{
    if (text.length > 0) {
        [self.displayTextQueue addObject:text];
        [self beginShowText];
    }
    else {//空文本意味着重置之前的展示
        [_displayTextQueue removeAllObjects];
        if (_showTimer.isValid) {
            [_showTimer invalidate];
        }
        
        self.showTimer = nil;
        [self.target showFaceTipText:text];
    }
    
    [self ensureCurrentStatus];
}

- (void)ensureContinueState
{
    if (!self.currentItem || self.currentItem.finishShow) {
        self.shouldContinue = NO;
    }
    else {
        self.shouldContinue = YES;
    }
}

- (void)ensureCurrentStatus
{
    [self ensureContinueState];
    
    BOOL finish = NO;
    
    if (!_shouldContinue) {
        if (self.currentItem == self.frontItem) {
          if (!self.backItem || self.backItem.finishShow) {
              finish = YES;
          }
        }
        else if (!self.frontItem || self.frontItem.finishShow) {
            finish = YES;
        }
    }
   
    if (finish && !_showTimer) {
        self.target.shouldContinue = NO;
        self.target.currentSignal = MDFaceTipSignalNone;
        
        [self.target showFaceTipText:@""];
        [self.target faceTipDidFinishAllTask];
    }
}

- (void)start
{
    // 清除上一次显示
    void (^block)()= ^{
        [self enqueueDisplayText:@""];
        self.target.shouldContinue = YES;
    };
   
    [self excuteBlockInMainThread:block];
}

- (void)beginShowText
{
    if (!_displayingText && _displayTextQueue.count > 0) {
        _displayingText = [_displayTextQueue firstObject];
        [self.target showFaceTipText:_displayingText];
        
        if (self.showTimer.valid) {
            [self.showTimer invalidate];
        }
        self.showTimer = nil;
        
        self.showTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.showTimer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)timerFired:(NSTimer *)timer
{
    if (self.showTimer.isValid) {
        [self.showTimer invalidate];
    }
    self.showTimer = nil;
    
    self.displayingText = nil;
    if (_displayTextQueue.count) {
        [_displayTextQueue removeObjectAtIndex:0];
    }
    
    if (_displayTextQueue.count > 0) {//展示队列里还有需要展示的内容
        [self beginShowText];
    }
    else {//队列里没有需要展示的内容了，展示时间已到需要通知target清掉之前的显示
        [self.target showFaceTipText:@""];
    }
    
    [self ensureCurrentStatus];
}

- (void)stop
{
    void (^block)()= ^{
        if (self.showTimer.isValid) {
            [self.showTimer invalidate];
        }
        self.showTimer = nil;
        self.target.shouldContinue = NO;
        self.target.currentSignal = MDFaceTipSignalNone;
        
        [self.target showFaceTipText:@""];
    };
   
    [self excuteBlockInMainThread:block];
}

- (void)excuteBlockInMainThread:(dispatch_block_t)block
{
    if (pthread_main_np()) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)input:(MDFaceTipSignal)signal
{
    void (^block)()= ^{
        if (signal == self.currentSignal) {
            return;
        }
        else {
            self.currentSignal = signal;
        }
        
        switch (signal) {
            case MDFaceTipSignalFaceTrack:
            {
                MDFaceTipItem *currentItem = self.currentItem;
                if (currentItem.shouldFaceTrack && !currentItem.finishShow) {
                    currentItem.finishShow = YES;
                    [self enqueueDisplayText:currentItem.faceTrackContent];
                }
                break;
            }
                
            case MDFaceTipSignalFaceNoTrack:
            {
                NSString *text = [self getCurrentDisplayText];
                if (self.currentItem.finishShow) {
                    [self enqueueDisplayText:text];
                }
                else {
                    [self.target showFaceTipText:text];
                }
                break;
            }
                
            case MDFaceTipSignalCameraRotate:
            {
                self.position = (self.position == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
                NSString *text = [self getCurrentDisplayText];
                //切换前后摄像头时如果当前摄像头没有提示文案，保险起见做一个清理当前展示文案的逻辑
                if (!text) {
                    text = @"";
                }
                
                if (self.currentItem.finishShow) {
                    [self enqueueDisplayText:text];
                }
                else {
                    [self.target showFaceTipText:text];
                }
                break;
            }
                
            default:
                break;
        }
        
        self.target.currentSignal = signal;
        [self ensureCurrentStatus];
    };
    
    if (pthread_main_np()) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (NSString *)getCurrentDisplayText
{
    NSString *text = nil;
    
    MDFaceTipItem *currentItem = self.currentItem;
    if (currentItem && !currentItem.finishFaceTrack && !currentItem.finishShow) {
        text = currentItem.content;
        
        if (!currentItem.shouldFaceTrack) {
            currentItem.finishShow = YES;
        }
        else {
            currentItem.finishFaceTrack = YES;
        }
    }
    
    return text;
}

@end
