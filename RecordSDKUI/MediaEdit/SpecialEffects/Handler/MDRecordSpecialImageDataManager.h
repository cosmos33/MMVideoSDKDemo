//
//  MDRecordSpecialImageDataManager.h
//  MDChat
//
//  Created by YZK on 2018/8/9.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MDRecordSpecialImageDataManagerDelegate <NSObject>

@optional
- (void)recordSpecialImageReload;
- (void)recordSpecialImageFinished;

@end

@interface MDRecordSpecialImageDataManager : NSObject

@property (nonatomic ,strong) NSMutableArray *momentThumbDataArray;
@property (nonatomic ,strong) NSMutableArray *momentThumbTimeArray;

- (void)getSpecialImageGroupsByAsset:(AVAsset *)asset
                          frameCount:(NSUInteger)frameCount
                            delegate:(id<MDRecordSpecialImageDataManagerDelegate>)delegate;

@end
