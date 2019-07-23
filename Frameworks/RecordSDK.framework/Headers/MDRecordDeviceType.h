//
//  MDRecordDeviceType.h
//  Pods
//
//  Created by sunfei on 2019/3/11.
//

#ifndef MDRecordDeviceType_h
#define MDRecordDeviceType_h

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE6_OR_MORE (IS_IPHONE && SCREEN_MAX_LENGTH >= 667.0)

#endif /* MDRecordDeviceType_h */
