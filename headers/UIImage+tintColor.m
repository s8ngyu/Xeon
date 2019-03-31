#import "UIImage+tintColor.h"

@implementation UIImage (tintColor)

- (UIImage *)tintColorWithUIColor:(UIColor *)color {
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

@end