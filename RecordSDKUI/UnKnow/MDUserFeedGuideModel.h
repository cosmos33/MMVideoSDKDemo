//
//  MDUserFeedGuideModel.h
//  MDChat
//
//  Created by litianpeng on 2018/10/10.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDUserFeedGuideModel : NSObject
@property (nonatomic, copy) NSString *toastTitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *gotoString;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) NSInteger type;///< 0是跳转相册, 1 是goto. 最好声明称枚举
@property (nonatomic, assign) NSInteger modelType;///<0是新照片  1是新自拍 3是网络引导
@property (nonatomic, copy) NSString *statKey;///<后台策略ID
+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end

@interface MDUserFeedGuideShowModel : NSObject
@property (nonatomic, strong)   NSArray *photoArr;///<新照片
@property (nonatomic, copy)     NSString *toastStr;///<提示信息
@end
NS_ASSUME_NONNULL_END
