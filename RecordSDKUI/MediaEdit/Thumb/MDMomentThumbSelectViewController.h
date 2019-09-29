//
//  MDMomentThumbSelectViewController.h
//  MDChat
//
//  Created by Leery on 16/12/28.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDViewController.h"

@protocol MDMomentThumbSelectDelegate <NSObject>
- (void)momentCoverImage:(UIImage *)coverImage atThumbIndex:(NSInteger)index;
- (AVAsset *)momentCoverSourceAsset;
@end

@interface MDMomentThumbSelectViewController : MDViewController

@property (nonatomic ,weak) id<MDMomentThumbSelectDelegate>deleagte;
@property (nonatomic ,strong) NSMutableArray        *thumbDataArray;
@property (nonatomic ,strong) NSMutableArray        *thumbTimeArray;
@property (nonatomic ,assign) NSInteger             preLoadIndex;
@property (nonatomic, assign) CGFloat               maxThumbSize;

- (void)reloadCollectionView;
@end
