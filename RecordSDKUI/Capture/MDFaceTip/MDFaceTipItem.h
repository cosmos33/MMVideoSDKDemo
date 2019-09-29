//
//  MDFaceTipItem.h
//  MDChat
//
//  Created by sdk on 2017/6/22.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Eta/Eta.h>

@interface MDFaceTipItem : EtaModel

/**
 *  人脸提示一级文案
 */
@property (nonatomic, copy) NSString *content;

/**
 *  是否需要人脸检测逻辑
 */
@property (nonatomic, assign) BOOL shouldFaceTrack;

/**
 *  人脸检测触发后显示二级文案
 */
@property (nonatomic, copy) NSString *faceTrackContent;

/**
 *  是否完成显示
 */
@property (nonatomic, assign) BOOL finishFaceTrack;
@property (nonatomic, assign) BOOL finishShow;

@end
