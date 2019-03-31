#import "UIImage+tintColor.h"

@implementation UIImage (tintColor)

- (UIImage *)imageReplacedWithColor:(UIColor *)color {
    if (!color) {
        color = [UIColor whiteColor];
    }

    UIImage *newImage = self;

    newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(newImage.size, NO, newImage.scale);
    [color set];
    [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)imageTintedWithColor:(UIColor *)color {
     UIImage *image;
     if (color) {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0);
        CGRect rect = CGRectZero;
        rect.size = [self size];

        [self drawInRect:rect];
        [color set];
        UIRectFillUsingBlendMode(rect, kCGBlendModeScreen);

        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];

        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end