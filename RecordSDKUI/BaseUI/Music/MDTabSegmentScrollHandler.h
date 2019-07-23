//
//  MDTabSegmentScrollHandler.h
//  MDChat
//
//  Created by YZK on 2018/6/21.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MDTabSegmentView;

@protocol MDTabSegmentScrollHandlerDelegate <NSObject>
- (void)scrollWithOldIndex:(NSInteger)index toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
@end

@interface MDTabSegmentScrollHandler : NSObject

@property (nonatomic, weak) id<MDTabSegmentScrollHandlerDelegate> delegate;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
