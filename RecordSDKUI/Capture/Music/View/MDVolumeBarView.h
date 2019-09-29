//
//  MDVolumeBarView.h
//  MDChat
//
//  Created by Fu.Chen on 2018/3/9.
//  Copyright © 2018年 Fu.Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MDVolumeBarViewDelegate<NSObject>
@required
- (void) progressDidChange:(CGFloat)aProgress;

@end

@interface MDVolumeBarView : UIView
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,weak) id<MDVolumeBarViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
@end


