//
//  MDFaceDecorationItem.h
//  MDChat
//
//  Created by Jc on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// 人脸装饰数据信息
@interface MDFaceDecorationItem : NSObject

@property (nonatomic, assign) NSInteger version;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *zipUrlStr;
@property (nonatomic, copy) NSString *imgUrlStr;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) BOOL haveSound;
@property (nonatomic, assign, getter=isNeed3D)  BOOL need3D;
@property (nonatomic, assign, getter=isFacerig) BOOL isFacerig;
@property (nonatomic, assign, getter=isNeedAR)  BOOL needAR;
@property (nonatomic, copy) NSString *resourcePath;

@property (nonatomic, assign) BOOL clickedToBounce;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isPlaceholdItem;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)dicWithFaceDecorationItem:(MDFaceDecorationItem *)faceDecorationItem;

@end


// 人脸装饰底部分类选择数据信息
@interface MDFaceDecorationClassItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imgUrlStr;
@property (nonatomic, copy) NSString *selectedImgUrlStr;
@property (nonatomic, copy) NSString *identifier;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)dicWithFaceClassItem:(MDFaceDecorationClassItem *)faceClassItem;

@end

