//
//  MDMomentExpressionDownLoadManager.h
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDownLoaderModel.h"

@protocol MDDownLoderDelegate <NSObject>

- (void)downloaderStart:(id)sender downloadWithItem:(MDDownLoaderModel *)item;

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item downloadEnd:(BOOL)result;

@end

@interface MDDownLoadManager : NSObject

-(instancetype)initWithDelegate:(id<MDDownLoderDelegate>)delegate;

- (void)downloadItem:(MDDownLoaderModel *)item;

- (BOOL)isDownloadingItem:(MDDownLoaderModel *)item;

- (void)cancelDownloadingItem:(MDDownLoaderModel *)item;

@end
