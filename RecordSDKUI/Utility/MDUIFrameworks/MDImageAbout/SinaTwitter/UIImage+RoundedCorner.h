// UIImage+RoundedCorner.h
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support making rounded corners
#import <UIKit/UIKit.h>
struct MDCornerRadius {
    CGFloat leftTop;
    CGFloat leftBottom;
    CGFloat rightTop;
    CGFloat rightBottom;
};
typedef struct MDCornerRadius MDCornerRadius;

@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;

//基于当前图片得到一张内切圆大小的图片
- (UIImage *)circleClipedImage;

- (UIImage*)imageWithRadius:(float) radius 
					  width:(float)width
					 height:(float)height;

- (UIImage *)scaleImageWithRadius:(float)radius
                  finalWidth:(CGFloat)fWidth
                 finalHeight:(CGFloat)fHeight;

- (UIImage *)clipImageWithFinalWidth:(CGFloat)fWidth finalHeight:(CGFloat)fHeight;

- (UIImage *)imagewithRadiusForUserTitlewidth:(float)width height:(float)height;
- (UIImage *)getEllipseImageWithImage:( UIImage *)originImage;

//切圆角
- (UIImage *)imageWithRadius:(CGSize)size cornerRadius:(MDCornerRadius)cornerRadius;

@end
