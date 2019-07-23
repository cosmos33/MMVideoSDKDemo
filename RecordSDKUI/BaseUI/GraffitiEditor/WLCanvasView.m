//
//  WLCanvasView.m
//  Pods
//
//  Created by YuAo on 11/26/14.
//
//

#import "WLCanvasView.h"

CGPoint WLCanvasViewGetMidPointWithPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface WLCanvasViewBrushConfiguration ()
@property (nonatomic,copy) UIColor *brushColor;
@property (nonatomic) CGFloat brushSize;
@property (nonatomic) WLCanvasViewBrushMode brushMode;
@end

@implementation WLCanvasViewBrushConfiguration

+ (instancetype)configurationWithBrushMode:(WLCanvasViewBrushMode)mode brushSize:(CGFloat)size brushColor:(UIColor *)color {
    WLCanvasViewBrushConfiguration *configuration = [[WLCanvasViewBrushConfiguration alloc] init];
    configuration.brushMode = mode;
    configuration.brushSize = size;
    configuration.brushColor = color;
    return configuration;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

@interface WLCanvasViewStroke : NSObject
@property (nonatomic,copy) UIBezierPath *path;
@property (nonatomic,copy) WLCanvasViewBrushConfiguration *brushConfiguration;
@end

@implementation WLCanvasViewStroke

+ (instancetype)strokeWithBrushConfiguration:(WLCanvasViewBrushConfiguration *)configuration {
    WLCanvasViewStroke *stroke = [[WLCanvasViewStroke alloc] init];
    stroke.path = [UIBezierPath bezierPath];
    stroke.brushConfiguration = configuration;
    return stroke;
}

@end

@interface WLCanvasViewBrushIndicatorView : UIView

@property (nonatomic,copy) WLCanvasViewBrushConfiguration *brushConfiguration;

@end

@implementation WLCanvasViewBrushIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setBrushConfiguration:(WLCanvasViewBrushConfiguration *)brushConfiguration {
    _brushConfiguration = brushConfiguration.copy;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize preferredSize = CGSizeMake(self.brushConfiguration.brushSize, self.brushConfiguration.brushSize);
    CGRect brushRect = CGRectMake((CGRectGetWidth(rect) - preferredSize.width)/2, (CGRectGetHeight(rect) - preferredSize.height)/2, preferredSize.width, preferredSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:brushRect];
    path.lineWidth = 2;
    [[UIColor clearColor] setFill];
    [[UIColor colorWithWhite:1.0 alpha:0.75] setStroke];
    [path stroke];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize preferredSize = CGSizeMake(self.brushConfiguration.brushSize, self.brushConfiguration.brushSize);
    return preferredSize;
}

@end

@interface WLCanvasView ()

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) CGPoint previousPreviousPoint;

@property (nonatomic,strong) WLCanvasViewStroke *currentStroke;

@property (nonatomic,weak) UIImageView *outputImageView;

@property (nonatomic,weak) WLCanvasViewBrushIndicatorView *brushIndicatorView;

@end

@implementation WLCanvasView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self canvasViewSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self canvasViewSetup];
    }
    return self;
}

- (void)canvasViewSetup {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.brushConfiguration = [WLCanvasViewBrushConfiguration configurationWithBrushMode:WLCanvasViewBrushModeDraw brushSize:10 brushColor:[UIColor blackColor]];
    
    UIImageView *outputImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    outputImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    outputImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:outputImageView];
    self.outputImageView = outputImageView;
    
    WLCanvasViewBrushIndicatorView *brushIndicatorView = [[WLCanvasViewBrushIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    brushIndicatorView.alpha = 0;
    brushIndicatorView.brushConfiguration = self.brushConfiguration;
    brushIndicatorView.hidden = !self.showsBrushTouch;
    [self addSubview:brushIndicatorView];
    self.brushIndicatorView = brushIndicatorView;
}

- (CGFloat)minimumRecognizableMovement {
    if (_minimumRecognizableMovement < 1) {
        return 1;
    }
    return _minimumRecognizableMovement;
}

- (void)setShowsBrushTouch:(BOOL)showsBrushTouch {
    _showsBrushTouch = showsBrushTouch;
    self.brushIndicatorView.hidden = !showsBrushTouch;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.outputImageView.image = image;
}

- (void)setContentAlpha:(CGFloat)contentAlpha {
    self.outputImageView.alpha = contentAlpha;
}

- (CGFloat)contentAlpha {
    return self.outputImageView.alpha;
}

- (UIBezierPath *)currentStrokePath {
    return self.currentStroke.path.copy;
}

- (void)render {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, round(self.graphicContextScale));
    
    if (self.image) {
        [self.image drawInRect:self.bounds];
    }
    
    [self.currentStroke.brushConfiguration.brushColor setStroke];
    
    UIBezierPath *path = self.currentStroke.path;
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = self.currentStroke.brushConfiguration.brushSize;
    switch (self.currentStroke.brushConfiguration.brushMode) {
        case WLCanvasViewBrushModeErase: {
            [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        } break;
        case WLCanvasViewBrushModeDraw: {
            if (self.clearsStrokesBeforeDrawing) {
                [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
            }
            [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
        } break;
        default:
            break;
    }
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

#pragma mark Touch event handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    self.previousPoint = [touch previousLocationInView:self];
    self.previousPreviousPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    self.brushIndicatorView.alpha = 1;
    
    if (self.brushTouchDownHandler) {
        self.brushTouchDownHandler();
    }
    
    [self drawWithTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    // if the finger has moved less than the min dist ...
    CGFloat dx = point.x - self.currentPoint.x;
    CGFloat dy = point.y - self.currentPoint.y;
    
    if ((dx * dx + dy * dy) < self.minimumRecognizableMovement * self.minimumRecognizableMovement) {
        // ... then ignore this movement
        return;
    }
    
    [self drawWithTouch:touch];
}

- (void)drawWithTouch:(UITouch *)touch {
    self.brushIndicatorView.center = [touch locationInView:self];
    // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
    self.previousPreviousPoint = self.previousPoint;
    self.previousPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    CGPoint mid1 = WLCanvasViewGetMidPointWithPoints(self.previousPoint, self.previousPreviousPoint);
    CGPoint mid2 = WLCanvasViewGetMidPointWithPoints(self.currentPoint, self.previousPoint);
    
    // to represent the finger movement, create a new path segment,
    // a quadratic bezier path from mid1 to mid2, using previous as a control point
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL,
                              self.previousPoint.x, self.previousPoint.y,
                              mid2.x, mid2.y);
    
    // compute the rect containing the new segment plus padding for drawn line
    
    //CGRect bounds = CGPathGetBoundingBox(subpath);
    //CGRect drawBox = CGRectInset(bounds, -2.0 * self.brushConfiguration.brushSize, -2.0 * self.brushConfiguration.brushSize);
    
    // append the quad curve to the accumulated path so far.
    self.currentStroke.path = [UIBezierPath bezierPathWithCGPath:subpath];
    CGPathRelease(subpath);
    
    [self render];
    
    if (self.brushMovedToPointHandler) {
        self.brushMovedToPointHandler([touch locationInView:self]);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.brushIndicatorView.alpha = 0;
    if (self.brushTouchUpHandler) {
        self.brushTouchUpHandler();
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.brushIndicatorView.alpha = 0;
    if (self.brushTouchUpHandler) {
        self.brushTouchUpHandler();
    }
}

- (void)setBrushConfiguration:(WLCanvasViewBrushConfiguration *)brushConfiguration {
    _brushConfiguration = brushConfiguration.copy;
    self.currentStroke = [WLCanvasViewStroke strokeWithBrushConfiguration:self.brushConfiguration];
    self.brushIndicatorView.brushConfiguration = brushConfiguration;
}

- (void)clear {
    self.currentStroke = [WLCanvasViewStroke strokeWithBrushConfiguration:self.brushConfiguration];
    self.image = nil;
}

@end
