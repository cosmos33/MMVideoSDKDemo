//
//  MUAt8AlertBar.m
//  RecordSDK
//
//  Created by Aaron on 16/7/28.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt8AlertBar.h"
#import <POP/POP.h>

@interface MUAt8AlertBar()

@property (nonatomic, strong) UIView    *containerView;
@property (nonatomic, assign) CGPoint   point;

@end

@implementation MUAt8AlertBar

-(instancetype)initWithModel:(MUAt8AlertBarModel *)model {
    self = [super initWithFrame:model.maskFrame];
    if (self) {
        self.closeBlock = model.closeBlock;
        [self addSubview:[self bubbleWithModel:model]];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        self.containerView.hidden = YES;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.containerView.hidden = NO;
            [self performAnimation];
        });
    }
    return self;
}

-(UIView *)bubbleWithModel:(MUAt8AlertBarModel *)model {
    
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = kAt8AlertFont;
    label.textColor = model.textColor ?: kAt8AlertFontColor;
    label.text = model.title;
    
    label.numberOfLines = 0;
    
    NSDictionary *attributes = @{NSFontAttributeName:label.font};
    CGSize size = [model.title boundingRectWithSize:CGSizeMake(kAt8AlertLabelMaxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil].size;
    
    label.frame = CGRectMake(kAt8AlertTitleOffset, kAt8AlertTitleVerticalMargin, size.width, size.height);
    label.text = model.title;
    
    CGFloat bubbleWith = label.width+2*kAt8AlertTitleOffset;
    CGFloat bubbleHeight = label.height + 2*kAt8AlertTitleVerticalMargin;
    CGFloat bubbleX = 0.0;
    CGFloat bubbleY = 0.0;
    CGFloat limitOffsetX = bubbleWith/2.0-kAt8AlertAccessHeight-kAt8AlertCornerRadius;
    CGFloat limitOffsetY = bubbleHeight/2.0-kAt8AlertAccessHeight-kAt8AlertCornerRadius;

    switch (model.anchorType) {
        case MUAt8AnchorTypeBottom:
            model.anchorOffset = MAX(-limitOffsetX, MIN(model.anchorOffset, limitOffsetX));
            self.containerView = [[UIView alloc]initWithFrame:CGRectMake(model.anchorPoint.x-model.anchorOffset-bubbleWith/2.0, model.anchorPoint.y-bubbleHeight-kAt8AlertAccessHeight, bubbleWith, bubbleHeight+kAt8AlertAccessHeight)];
            break;
        case MUAt8AnchorTypeTop:
            model.anchorOffset = MAX(-limitOffsetX, MIN(model.anchorOffset, limitOffsetX));
            self.containerView = [[UIView alloc]initWithFrame:CGRectMake(model.anchorPoint.x-model.anchorOffset-bubbleWith/2.0, model.anchorPoint.y, bubbleWith, bubbleHeight+kAt8AlertAccessHeight)];
            bubbleY = kAt8AlertAccessHeight;
            label.top += kAt8AlertAccessHeight;
            break;
        case MUAt8AnchorTypeRight:
            model.anchorOffset = MAX(-limitOffsetY, MIN(model.anchorOffset, limitOffsetY));
            self.containerView = [[UIView alloc]initWithFrame:CGRectMake(model.anchorPoint.x-bubbleWith-kAt8AlertAccessHeight, model.anchorPoint.y-model.anchorOffset-bubbleHeight/2.0, bubbleWith+kAt8AlertAccessHeight, bubbleHeight)];
            break;
        case MUAt8AnchorTypeLeft:
            model.anchorOffset = MAX(-limitOffsetY, MIN(model.anchorOffset, limitOffsetY));
            self.containerView = [[UIView alloc]initWithFrame:CGRectMake(model.anchorPoint.x, model.anchorPoint.y-model.anchorOffset-bubbleHeight/2.0, bubbleWith+kAt8AlertAccessHeight, bubbleHeight)];
            bubbleX = kAt8AlertAccessHeight;
            label.left = kAt8AlertAccessHeight + kAt8AlertTitleOffset;
            break;
        default:
            break;
    }
    self.containerView.clipsToBounds = YES;
    
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIColor *backgroundColor = model.backgroundColor ?: RGBACOLOR(52, 98, 255, 0.9);
    shapeLayer.strokeColor = backgroundColor.CGColor;
    shapeLayer.fillColor = backgroundColor.CGColor;
    shapeLayer.lineWidth = 0.5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;

    //create path

    CGRect rect = CGRectMake(bubbleX, bubbleY, bubbleWith, bubbleHeight);
    //NSLog(@"rect: %@", [NSValue valueWithCGRect:rect]);
    CGSize radii = CGSizeMake(kAt8AlertCornerRadius, kAt8AlertCornerRadius);
    if (model.cornerRadius > 0) {
        radii = CGSizeMake(model.cornerRadius, model.cornerRadius);
    }
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
    
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    
    switch (model.anchorType) {
        case MUAt8AnchorTypeBottom: {
            self.point = CGPointMake(bubbleX+bubbleWith/2.0+model.anchorOffset, bubbleY+bubbleHeight+kAt8AlertAccessHeight);
            [path moveToPoint:CGPointMake(bubbleX+bubbleWith/2.0-kAt8AlertAccessHeight+model.anchorOffset, bubbleY+bubbleHeight)];
            [path addLineToPoint:self.point];
            [path addLineToPoint:CGPointMake(bubbleX+bubbleWith/2.0+kAt8AlertAccessHeight+model.anchorOffset, bubbleY+bubbleHeight)];
            [path closePath];
        }break;
        case MUAt8AnchorTypeTop: {
            self.point = CGPointMake(bubbleX+bubbleWith/2.0+model.anchorOffset, bubbleY-kAt8AlertAccessHeight);
            [path moveToPoint:CGPointMake(bubbleX+bubbleWith/2.0-kAt8AlertAccessHeight+model.anchorOffset, bubbleY)];
            [path addLineToPoint:self.point];
            [path addLineToPoint:CGPointMake(bubbleX+bubbleWith/2.0+kAt8AlertAccessHeight+model.anchorOffset, bubbleY)];
            [path closePath];
        }break;
        case MUAt8AnchorTypeLeft: {
            self.point = CGPointMake(bubbleX-kAt8AlertAccessHeight, bubbleY+bubbleHeight/2.0+model.anchorOffset);
            [path moveToPoint:CGPointMake(bubbleX, bubbleY+bubbleHeight/2.0-kAt8AlertAccessHeight+model.anchorOffset)];
            [path addLineToPoint:self.point];
            [path addLineToPoint:CGPointMake(bubbleX, bubbleY+bubbleHeight/2.0+kAt8AlertAccessHeight+model.anchorOffset)];
            [path closePath];
        }break;
        case MUAt8AnchorTypeRight: {
            self.point = CGPointMake(bubbleX+bubbleWith+kAt8AlertAccessHeight, bubbleY+bubbleHeight/2.0+model.anchorOffset);
            [path moveToPoint:CGPointMake(bubbleX+bubbleWith, bubbleY+bubbleHeight/2.0-kAt8AlertAccessHeight+model.anchorOffset)];
            [path addLineToPoint:self.point];
            [path addLineToPoint:CGPointMake(bubbleX+bubbleWith, bubbleY+bubbleHeight/2.0+kAt8AlertAccessHeight+model.anchorOffset)];
            [path closePath];
        }break;
        default:
            break;
    }
    
    shapeLayer.path = path.CGPath;

    [self.containerView.layer addSublayer:shapeLayer];
    [self.containerView addSubview:label];
    
    return self.containerView;
}

-(void)performAnimation {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    spring.fromValue = [NSValue valueWithCGRect:CGRectMake(self.containerView.origin.x+self.point.x, self.containerView.origin.y+self.point.y, 0, 0)];
    spring.toValue = [NSValue valueWithCGRect:CGRectMake(self.containerView.origin.x, self.containerView.origin.y, self.containerView.width, self.containerView.height)];
    spring.springBounciness = 10.0f;
    spring.springSpeed = 10.0;
    [self.containerView pop_addAnimation:spring forKey:@"frame"];
    [spring setCompletionBlock:^(POPAnimation *anim , BOOL finished) {
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self closeAction];
}

-(void)closeAction {
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self performCloseAnimation];
}

-(void)performCloseAnimation {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    spring.toValue = [NSValue valueWithCGRect:CGRectMake(self.containerView.origin.x+self.point.x, self.containerView.origin.y+self.point.y, 0, 0)];
    spring.fromValue = [NSValue valueWithCGRect:CGRectMake(self.containerView.origin.x, self.containerView.origin.y, self.containerView.width, self.containerView.height)];
    spring.springBounciness = 10.0f;
    spring.springSpeed = 10.0;
    [self.containerView pop_addAnimation:spring forKey:@"frame"];
    __weak MUAt8AlertBar *weakSelf = self;
    [spring setCompletionBlock:^(POPAnimation *anim , BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


@end
