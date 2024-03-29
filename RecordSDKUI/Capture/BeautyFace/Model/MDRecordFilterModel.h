//
//  MDRecordModel.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/3.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const revoke_Id     = @"0";

@interface MDRecordFilterModel : NSObject

@property(nonatomic,copy) NSString      *identifier;
@property(nonatomic,copy) NSString      *title;
@property(nonatomic,copy) NSString      *tag;
@property(nonatomic,copy) NSString      *zipUrlString;
//滤镜本地路径
@property(nonatomic,copy) NSString      *filterPath;

@property(nonatomic,copy) NSString      *iconUrlString;
//本地配置图标路径（优先取这个）
@property(nonatomic,copy) NSString      *iconPath;

@property(nonatomic,assign)BOOL isSelected;

+ (instancetype)filterModelWithDicionary:(NSDictionary*)dictionary;

@end


@interface MDRecordMakeUpModel : NSObject

@property(nonatomic,copy)  NSString* makeUpId;
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,strong) NSNumber *value;
@property(nonatomic,strong) NSNumber *sliderType;

@end

@interface MDRMicroSurgeryModel : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *icon;
@property (nonatomic, readonly) NSString *highlight;
@property (nonatomic, readonly) NSNumber *value;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSNumber *index;
@property (nonatomic, readonly) NSNumber *sliderType;

- (instancetype)initModelWithDict:(NSDictionary *)dict;

@end



