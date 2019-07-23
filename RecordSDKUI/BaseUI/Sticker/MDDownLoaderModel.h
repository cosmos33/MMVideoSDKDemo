//
//  MDDownLoaderModel.h
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDDownLoadState) {
    
    MDDownLoadStateNone,
    MDDownLoadStateLoading,
    MDDownLoadStateSuccess,
    MDDownLoadStateFailed,
};

@interface MDDownLoaderModel : NSObject

@property (nonatomic, copy) NSString                *url;
@property (nonatomic, assign) MDDownLoadState       state;
@property (nonatomic, copy) NSString                *downLoadFileSavePath;   //文件下载后保存地址
@property (nonatomic, copy) NSString                *resourcePath;           //文件下载后如果需要解压, 解压后地址, 如果不需要解压则和downLoadFileSavePath一致
@property (nonatomic, assign) NSInteger             version;                // 文件版本
@property (nonatomic, copy) NSString                *versionKey;            // 文件版本号key
@end
