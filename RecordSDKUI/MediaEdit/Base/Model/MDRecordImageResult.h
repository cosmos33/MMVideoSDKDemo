//
//  MDRecordImageResult.h
//  MDChat
//
//  Created by 符吉胜 on 2017/7/5.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDPhotoItem;

@interface MDRecordImageResult : NSObject

@property (nonatomic,strong) NSArray<MDPhotoItem *>         *photoItems;
//打点参数
@property (nonatomic, assign) BOOL fromAlbum;

@end



