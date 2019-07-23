//
//  UIPanGestureRecognizer+GestureTag.h
//  Pods
//
//  Created by RecordSDK on 2016/12/8.
//
//

#import <UIKit/UIKit.h>

@interface UIPanGestureRecognizer (GestureTag)

- (void)setGestureTag:(NSInteger)tag;

@property (nonatomic, assign, readonly) NSInteger tag;

@end
