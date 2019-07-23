//
//  MDFaceDecorationItem.m
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationItem.h"
#import "MDFaceDecorationDownloader.h"
#import "MDFaceDecorationFileHelper.h"
#import "MDRecordHeader.h"

@implementation MDFaceDecorationItem

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        
        self.version = [dic integerForKey:@"version" defaultValue:0];
        self.identifier = [dic stringForKey:@"id" defaultValue:nil];
        self.title = [dic stringForKey:@"title" defaultValue:nil];
        self.zipUrlStr = [dic stringForKey:@"zip_url" defaultValue:nil];
        self.imgUrlStr = [dic stringForKey:@"image_url" defaultValue:nil];
        self.tag = [dic stringForKey:@"tag" defaultValue:nil];
        self.haveSound = [dic boolForKey:@"sound" defaultValue:NO];
        self.need3D = [dic boolForKey:@"is_3d" defaultValue:NO];
        self.isFacerig = [dic boolForKey:@"is_facerig" defaultValue:NO];
        self.needAR = [dic boolForKey:@"is_arkit" defaultValue:NO];

        NSString *resourcePath = [MDFaceDecorationFileHelper resourcePathWithItem:self];

        if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
            self.resourcePath = resourcePath;
        }
        
        self.isDownloading = NO;
    }
    return self;
}

- (NSDictionary *)dicWithFaceDecorationItem:(MDFaceDecorationItem *)faceDecorationItem
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObjectSafe:@(faceDecorationItem.version) forKey:@"version"];
    [dict setObjectSafe:faceDecorationItem.identifier forKey:@"id"];
    [dict setObjectSafe:faceDecorationItem.title forKey:@"title"];
    [dict setObjectSafe:faceDecorationItem.zipUrlStr forKey:@"zip_url"];
    [dict setObjectSafe:faceDecorationItem.imgUrlStr forKey:@"image_url"];
    [dict setObjectSafe:faceDecorationItem.tag forKey:@"tag"];
    [dict setBool:faceDecorationItem.haveSound forKey:@"sound"];
    [dict setBool:faceDecorationItem.isNeed3D forKey:@"is_3d"];
    [dict setBool:faceDecorationItem.isFacerig forKey:@"is_facerig"];

    return dict;
}

@end


// 人脸装饰底部分类选择数据信息
@implementation MDFaceDecorationClassItem : NSObject

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {

        self.name = [dic stringForKey:@"name" defaultValue:nil];
        self.identifier = [dic stringForKey:@"id" defaultValue:nil];
        self.imgUrlStr  = [dic stringForKey:@"image_url" defaultValue:nil];
        self.selectedImgUrlStr = [dic stringForKey:@"selected_image_url" defaultValue:nil];
    }
    return self;
}

- (NSDictionary *)dicWithFaceClassItem:(MDFaceDecorationClassItem *)faceClassItem
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObjectSafe:faceClassItem.name forKey:@"name"];
    [dict setObjectSafe:faceClassItem.identifier forKey:@"id"];
    [dict setObjectSafe:faceClassItem.imgUrlStr forKey:@"image_url"];
    [dict setObjectSafe:faceClassItem.selectedImgUrlStr forKey:@"selected_image_url"];
    
    return dict;
}

@end
