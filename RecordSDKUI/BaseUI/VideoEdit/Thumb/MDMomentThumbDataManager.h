//
//  MDMomentThumbDataMAnager.h
//  MDChat
//
//  Created by Leery on 16/12/30.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol MDMomentThumbDataManagerDelegate <NSObject>
@optional
- (void)momentThumbDataReload;
@end

@interface MDMomentThumbDataManager : NSObject

@property (nonatomic ,strong) NSMutableArray                *momentThumbDataArray;
@property (nonatomic ,strong) NSMutableArray                *momentThumbTimeArray;
@property (nonatomic ,strong, readonly) AVAsset *asset;

@property (nonatomic ,strong) UIImage *defaultLargeCoverImage;
@property (nonatomic, assign) CGFloat maxThumbSize;

+ (MDMomentThumbDataManager *)momentThumbManager;

- (void)getMomentThumbGroupsByAsset:(AVAsset *)asset
                         frameCount:(NSUInteger)frameCount
                        addObserver:(id<MDMomentThumbDataManagerDelegate>)obj;

@end
