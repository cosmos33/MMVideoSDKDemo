//
//  WLCanvasView.h
//  Pods
//
//  Created by YuAo on 11/26/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WLCanvasViewBrushMode) {
    WLCanvasViewBrushModeDraw,
    WLCanvasViewBrushModeErase
};

@interface WLCanvasViewBrushConfiguration : NSObject <NSCopying>

+ (instancetype)configurationWithBrushMode:(WLCanvasViewBrushMode)mode brushSize:(CGFloat)size brushColor:(UIColor *)color;

@property (nonatomic,copy,readonly) UIColor *brushColor;

@property (nonatomic,readonly) CGFloat brushSize;

@property (nonatomic,readonly) WLCanvasViewBrushMode brushMode;

@end

@interface WLCanvasView : UIView

@property (nonatomic,copy,readonly) UIBezierPath *currentStrokePath;

@property (nonatomic) CGFloat minimumRecognizableMovement;

@property (nonatomic) CGFloat contentAlpha;

@property (nonatomic) CGFloat graphicContextScale;

@property (nonatomic,copy) UIImage *image;

@property (nonatomic,copy) WLCanvasViewBrushConfiguration *brushConfiguration;

@property (nonatomic) BOOL clearsStrokesBeforeDrawing;

- (void)clear;

@property (nonatomic) BOOL showsBrushTouch;

@property (nonatomic,copy) void (^brushTouchDownHandler)(void);
@property (nonatomic,copy) void (^brushTouchUpHandler)(void);

@property (nonatomic,copy) void (^brushMovedToPointHandler)(CGPoint point);

@end
