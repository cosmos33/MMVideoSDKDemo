//
//  BBMediaGraffitiEditorViewController.h
//  BiBi
//
//  Created by YuAo on 12/11/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT BOOL BBUIImageContainsVisiblePixelData(UIImage *image);

@interface BBMediaGraffitiEditorViewController : UIViewController

@property (nonatomic,copy) UIImage *initialGraffitiCanvasImage;
@property (nonatomic,copy) UIImage *initialMosaicCanvasImage;
@property (nonatomic,assign) CGRect renderFrame;

@property (nonatomic,copy) void (^canvasImageUpdatedHandler)(UIImage *canvasImage, UIImage *mosaicCanvasImage);

@property (nonatomic,copy) void (^completionHandler)(void);

@end
