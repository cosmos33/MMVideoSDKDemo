/*
 https://github.com/erica/uidevice-extension/blob/master/UIDevice-Hardware.h
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS" 
#define IPHONE_4_NAMESTRING             @"iPhone 4" 
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6PLUS_NAMESTRING         @"iPhone 6 Plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define IPHONE_6SPLUS_NAMESTRING        @"iPhone 6S Plus"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7PLUS_NAMESTRING         @"iPhone 7 Plus"
#define IPHONE_8_NAMESTRING             @"iPhone 8"
#define IPHONE_8PLUS_NAMESTRING         @"iPhone 8 Plus"
#define IPHONE_X_NAMESTRING             @"iPhone X"
#define IPHONE_XS_NAMESTRING            @"iPhone XS"
#define IPHONE_XSMAX_NAMESTRING         @"iPhone XS Max"
#define IPHONE_XR_NAMESTRING            @"iPhone XR"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_6G_NAMESTRING              @"iPod touch 6G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_AIR_NAMESTRING             @"iPad Air"
#define IPAD_AIR2_NAMESTRING            @"iPad Air 2"
#define IPAD_PRO9P7INCH_NAMESTRING      @"iPad Pro 9.7-inch"
#define IPAD_PRO12P9INCH_NAMESTRING     @"iPad Pro 12.9-inch"
#define IPAD_5G_NAMESTRING              @"iPad 5G"
#define IPAD_PRO10P5INCH_NAMESTRING     @"iPad Pro 10.5-inch"
#define IPAD_PRO12P9INCH2G_NAMESTRING   @"iPad Pro 12.9-inch 2G"
#define IPAD_6G_NAMESTRING              @"iPad 6G"
#define IPAD_PRO11INCH_NAMESTRING       @"iPad Pro 11-inch"
#define IPAD_PRO12P9INCH3G_NAMESTRING   @"iPad Pro 12.9-inch 3G"
#define IPAD_MINI_NAMESTRING            @"iPad mini"
#define IPAD_MINI_RETINA_NAMESTRING     @"iPad mini Retina"
#define IPAD_MINI3_NAMESTRING           @"iPad mini 3"
#define IPAD_MINI4_NAMESTRING           @"iPad mini 4"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_4K_NAMESTRING           @"Apple TV 4K"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"

typedef enum {
    MDRecordUIDeviceUnknown,
    
    MDRecordUIDeviceiPhoneSimulator,
    MDRecordUIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    MDRecordUIDeviceiPhoneSimulatoriPad,
    
    MDRecordUIDevice1GiPhone,
    MDRecordUIDevice3GiPhone,
    MDRecordUIDevice3GSiPhone,
    MDRecordUIDevice4iPhone,
    MDRecordUIDevice4SiPhone,
    MDRecordUIDevice5iPhone,
    MDRecordUIDevice5CiPhone,
    MDRecordUIDevice5SiPhone,
    MDRecordUIDevice6iPhone,
    MDRecordUIDevice6PlusiPhone,
    MDRecordUIDevice6SiPhone,
    MDRecordUIDevice6SPlusiPhone,
    MDRecordUIDeviceSEiPhone,
    MDRecordUIDevice7iPhone,
    MDRecordUIDevice7PlusiPhone,
    MDRecordUIDevice8iPhone,
    MDRecordUIDevice8PlusiPhone,
    MDRecordUIDeviceXiPhone,
    MDRecordUIDeviceXSiPhone,
    MDRecordUIDeviceXSMaxiPhone,
    MDRecordUIDeviceXRiPhone,
    
    MDRecordUIDevice1GiPod,
    MDRecordUIDevice2GiPod,
    MDRecordUIDevice3GiPod,
    MDRecordUIDevice4GiPod,
    MDRecordUIDevice5GiPod,
    MDRecordUIDevice6GiPod,
    
    MDRecordUIDevice1GiPad,
    MDRecordUIDevice2GiPad,
    MDRecordUIDevice3GiPad,
    MDRecordUIDevice4GiPad,
    MDRecordUIDeviceAiriPad,
    MDRecordUIDeviceAir2iPad,
    MDRecordUIDevicePro9p7InchiPad,
    MDRecordUIDevicePro12p9InchiPad,
    MDRecordUIDevice5GiPad,
    MDRecordUIDevicePro10p5InchiPad,
    MDRecordUIDevicePro12p9Inch2GiPad,
    MDRecordUIDevice6GiPad,
    MDRecordUIDevicePro11InchiPad,
    MDRecordUIDevicePro12p9Inch3GiPad,
    
    MDRecordUIDeviceiPadmini,
    MDRecordUIDeviceiPadminiRetina,
    MDRecordUIDeviceiPadmini3,
    MDRecordUIDeviceiPadmini4,
    
    MDRecordUIDeviceAppleTV2,
    MDRecordUIDeviceAppleTV3,
    MDRecordUIDeviceAppleTV4,
    MDRecordUIDeviceAppleTV4K,
    MDRecordUIDeviceUnknownAppleTV,
    
    MDRecordUIDeviceUnknowniPhone,
    MDRecordUIDeviceUnknowniPod,
    MDRecordUIDeviceUnknowniPad,
    MDRecordUIDeviceIFPGA,
    
} MDRecordUIDevicePlatform;

@interface UIDevice (Hardware)
- (NSString *) platform;
- (NSString *) hwmodel;
- (NSUInteger) platformType;
- (NSString *) platformString;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;
- (NSString *) osLanguageAndCountry;
@end
