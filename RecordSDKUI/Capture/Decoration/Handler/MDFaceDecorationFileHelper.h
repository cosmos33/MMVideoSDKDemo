//
//  MDFaceDecorationFileHelper.h
//  MDChat
//
//  Created by wangxuan on 16/8/24.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDFaceDecorationItem;


@interface MDFaceDecorationFileHelper : NSObject

+ (NSString *)FaceDecorationBasePath;
+ (NSString *)resourcePathWithItem:(MDFaceDecorationItem *)item;
+ (NSString *)zipPathWithItem:(MDFaceDecorationItem *)item;

+ (BOOL)existResourceWithItem:(MDFaceDecorationItem *)item;
+ (void)removeAllComponentWithItem:(MDFaceDecorationItem *)item;
+ (void)removeResourceWithItem:(MDFaceDecorationItem *)item;

@end
