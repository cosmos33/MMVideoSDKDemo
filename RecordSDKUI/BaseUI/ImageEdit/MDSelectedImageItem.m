//
//  MDSelectedImageItem.m
//  MDChat
//
//  Created by Allen on 10/29/13.
//  Copyright (c) 2013 sdk.com. All rights reserved.
//

#import "MDSelectedImageItem.h"
#import <MMFoundation/MMFoundation.h>

@implementation MDSelectedImageItem

- (id)initWithResourceString:(NSString *)string itemType:(MDSelectedImageItemType)aType
{
    self = [super init];
    if (self){
        self.resourceString = string;
        self.itemType = aType;
        self.needCompress = (aType == MDSelectedImageItemTypeLocalPath) ? YES : NO;
    }
    
    return self;
}

- (id)initWithGUIDString:(NSString *)aGUID
{
    return [self initWithResourceString:aGUID itemType:MDSelectedImgaeItemTypeGUID];
}

- (id)initWithLocalPath:(NSString *)aPath
{
    return [self initWithResourceString:aPath itemType:MDSelectedImageItemTypeLocalPath];
}

- (id)initWithImage:(UIImage *)img
{
    self = [super init];
    if (self){
        self.itemType = MDSelectedImageItemTypeLocalPath;
        self.needCompress = YES;
        self.originImage = img;
    }
    
    return self;
}

+ (id)itemWithGUIDString:(NSString *)aGUID
{
    return [[[[self class] alloc] initWithGUIDString:aGUID] autorelease];
}

+ (id)itemWithLocalPath:(NSString *)aPath
{
    return [[[[self class] alloc] initWithLocalPath:aPath] autorelease];
}

+ (id)itemWithImage:(UIImage *)img;
{
    return [[[[self class] alloc] initWithImage:img] autorelease];
}

- (void)dealloc
{
    self.resourceString = nil;
    self.originImage    = nil;
    self.nailImage      = nil;
    self.imgData        = nil;
    self.md5Hash        = nil;
    self.stickerID      = nil;
    self.filterName     = nil;
    self.localIdentifier = nil;
    self.faceInfoArray = nil;
    
    [super dealloc];
}

#pragma mark - 数据结构和dictionary互相转换，丢弃NSData和UIImage
+ (MDSelectedImageItem *)dictionaryToItem:(NSDictionary *)aDic
{
    MDSelectedImageItem *item = [[[MDSelectedImageItem alloc] init] autorelease];
    if (aDic) {
        item.resourceString = [aDic stringForKey:@"resource" defaultValue:@""];
        item.itemType = [aDic integerForKey:@"type" defaultValue:0];
        item.needCompress = [aDic boolForKey:@"compress" defaultValue:YES];
        item.md5Hash = [aDic stringForKey:@"md5" defaultValue:nil];
        item.stickerID = [aDic stringForKey:@"stickerID" defaultValue:nil];
    }
    return item;
}

+ (NSDictionary *)itemToDictionary:(MDSelectedImageItem *)anItem
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (anItem) {
        [dic setObjectSafe:anItem.resourceString forKey:@"resource"];
        [dic setObjectSafe:[NSNumber numberWithInteger:anItem.itemType] forKey:@"type"];
        [dic setObjectSafe:[NSNumber numberWithBool:anItem.needCompress] forKey:@"compress"];
        
        if (anItem.md5Hash){
            [dic setObject:anItem.md5Hash forKey:@"md5"];
        }
        
        if (anItem.stickerID){
            [dic setObject:anItem.stickerID forKey:@"stickerID"];
        }
    }
    return dic;
}

@end
