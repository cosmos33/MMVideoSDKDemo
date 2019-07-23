//
//  main.m
//  MDRecordSDK
//
//  Created by sunfei on 2018/11/29.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GT/GT.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        GT_TIME_START("app启动时间", "冷启动时间");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
