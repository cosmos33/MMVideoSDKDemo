//
//  MDRecordPlatformUtils.h
//  pushsdk-ios
//
//  Created by wangduanqing on 2018/12/4.
//  Copyright © 2018年 momo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define mdr_IFPGA_NAMESTRING                @"iFPGA"

#define mdr_IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define mdr_IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define mdr_IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define mdr_IPHONE_4_NAMESTRING             @"iPhone 4"
#define mdr_IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define mdr_IPHONE_5_NAMESTRING             @"iPhone 5"
#define mdr_IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define mdr_IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define mdr_IPHONE_6_NAMESTRING             @"iPhone 6"
#define mdr_IPHONE_6PLUS_NAMESTRING         @"iPhone 6 Plus"
#define mdr_IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define mdr_IPHONE_6SPLUS_NAMESTRING        @"iPhone 6S Plus"
#define mdr_IPHONE_SE_NAMESTRING            @"iPhone SE"
#define mdr_IPHONE_7_NAMESTRING             @"iPhone 7"
#define mdr_IPHONE_7PLUS_NAMESTRING         @"iPhone 7 Plus"
#define mdr_IPHONE_8_NAMESTRING             @"iPhone 8"
#define mdr_IPHONE_8PLUS_NAMESTRING         @"iPhone 8 Plus"
#define mdr_IPHONE_X_NAMESTRING             @"iPhone X"
#define mdr_IPHONE_XS_NAMESTRING            @"iPhone XS"
#define mdr_IPHONE_XSMAX_NAMESTRING         @"iPhone XS Max"
#define mdr_IPHONE_XR_NAMESTRING            @"iPhone XR"
#define mdr_IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define mdr_IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define mdr_IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define mdr_IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define mdr_IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define mdr_IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define mdr_IPOD_6G_NAMESTRING              @"iPod touch 6G"
#define mdr_IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define mdr_IPAD_1G_NAMESTRING              @"iPad 1G"
#define mdr_IPAD_2G_NAMESTRING              @"iPad 2G"
#define mdr_IPAD_3G_NAMESTRING              @"iPad 3G"
#define mdr_IPAD_4G_NAMESTRING              @"iPad 4G"
#define mdr_IPAD_AIR_NAMESTRING             @"iPad Air"
#define mdr_IPAD_AIR2_NAMESTRING            @"iPad Air 2"
#define mdr_IPAD_PRO9P7INCH_NAMESTRING      @"iPad Pro 9.7-inch"
#define mdr_IPAD_PRO12P9INCH_NAMESTRING     @"iPad Pro 12.9-inch"
#define mdr_IPAD_5G_NAMESTRING              @"iPad 5G"
#define mdr_IPAD_PRO10P5INCH_NAMESTRING     @"iPad Pro 10.5-inch"
#define mdr_IPAD_PRO12P9INCH2G_NAMESTRING   @"iPad Pro 12.9-inch 2G"
#define mdr_IPAD_MINI_NAMESTRING            @"iPad mini"
#define mdr_IPAD_MINI_RETINA_NAMESTRING     @"iPad mini Retina"
#define mdr_IPAD_MINI3_NAMESTRING           @"iPad mini 3"
#define mdr_IPAD_MINI4_NAMESTRING           @"iPad mini 4"
#define mdr_IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define mdr_APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define mdr_APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define mdr_APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define mdr_APPLETV_4K_NAMESTRING           @"Apple TV 4K"
#define mdr_APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define mdr_IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define mdr_IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define mdr_IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define mdr_IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"

typedef enum {
    mdr_UIDeviceUnknown,
    
    mdr_UIDeviceiPhoneSimulator,
    mdr_UIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    mdr_UIDeviceiPhoneSimulatoriPad,
    
    mdr_UIDevice1GiPhone,
    mdr_UIDevice3GiPhone,
    mdr_UIDevice3GSiPhone,
    mdr_UIDevice4iPhone,
    mdr_UIDevice4SiPhone,
    mdr_UIDevice5iPhone,
    mdr_UIDevice5CiPhone,
    mdr_UIDevice5SiPhone,
    mdr_UIDevice6iPhone,
    mdr_UIDevice6PlusiPhone,
    mdr_UIDevice6SiPhone,
    mdr_UIDevice6SPlusiPhone,
    mdr_UIDeviceSEiPhone,
    mdr_UIDevice7iPhone,
    mdr_UIDevice7PlusiPhone,
    mdr_UIDevice8iPhone,
    mdr_UIDevice8PlusiPhone,
    mdr_UIDeviceXiPhone,
    mdr_UIDeviceXSiPhone,
    mdr_UIDeviceXSMaxiPhone,
    mdr_UIDeviceXRiPhone,
    
    mdr_UIDevice1GiPod,
    mdr_UIDevice2GiPod,
    mdr_UIDevice3GiPod,
    mdr_UIDevice4GiPod,
    mdr_UIDevice5GiPod,
    mdr_UIDevice6GiPod,
    
    mdr_UIDevice1GiPad,
    mdr_UIDevice2GiPad,
    mdr_UIDevice3GiPad,
    mdr_UIDevice4GiPad,
    mdr_UIDeviceAiriPad,
    mdr_UIDeviceAir2iPad,
    mdr_UIDevicePro9p7InchiPad,
    mdr_UIDevicePro12p9InchiPad,
    mdr_UIDevice5GiPad,
    mdr_UIDevicePro10p5InchiPad,
    mdr_UIDevicePro12p9Inch2GiPad,
    
    mdr_UIDeviceiPadmini,
    mdr_UIDeviceiPadminiRetina,
    mdr_UIDeviceiPadmini3,
    mdr_UIDeviceiPadmini4,
    
    mdr_UIDeviceAppleTV2,
    mdr_UIDeviceAppleTV3,
    mdr_UIDeviceAppleTV4,
    mdr_UIDeviceAppleTV4K,
    mdr_UIDeviceUnknownAppleTV,
    
    mdr_UIDeviceUnknowniPhone,
    mdr_UIDeviceUnknowniPod,
    mdr_UIDeviceUnknowniPad,
    mdr_UIDeviceIFPGA,
    
} mdr_UIDevicePlatform;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordPlatformUtils : NSObject
+ (NSString *)randomString: (int) len;
+ (NSString *)urlencode: (NSString*) content;
+ (NSString *)userAgentString;
+ (mdr_UIDevicePlatform)platformType;
@end

NS_ASSUME_NONNULL_END
