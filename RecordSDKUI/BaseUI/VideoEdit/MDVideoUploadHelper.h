//
//  MDVideoUploadHelper.h
//  MDChat
//
//  Created by wangxuan on 17/2/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MDRecordVideoResult;

@interface MDVideoUploadHelper : NSObject

@property (nonatomic, assign) NSInteger                     originVideoCoverIndex;
@property (nonatomic, strong) UIImage                       *originVideoCover;
@property (nonatomic, strong) MDRecordVideoResult           *videoInfo;
@property (nonatomic, assign) BOOL                          hasChooseCover;

- (void)prepareVideoResultWithURL:(NSURL *)url;

- (void)prepareAnimojiVideoResultWithURL:(NSURL *)url andResourceId:(NSString *)resourceId;

@end
